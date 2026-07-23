import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import User, { IUser } from '../models/User';
import config from '../config/env';
import { ConflictError, NotFoundError, UnauthorizedError, ForbiddenError } from '../utils/errors';

import Otp from '../models/Otp';
import emailService from './email.service';

export class AuthService {
  async register(data: { fullName: string; email: string; phone: string; password: string }) {
    const existingEmail = await User.findOne({ email: data.email });
    if (existingEmail) {
      throw new ConflictError('Email đã tồn tại trong hệ thống');
    }

    const existingPhone = await User.findOne({ phone: data.phone });
    if (existingPhone) {
      throw new ConflictError('Số điện thoại đã được sử dụng');
    }

    // Generate 6-digit OTP
    const otpCode = Math.floor(100000 + Math.random() * 900000).toString();

    // Hash password before saving to OTP temporary data
    const hashedPassword = await bcrypt.hash(data.password, 10);
    const registrationData = { ...data, password: hashedPassword };

    // Set expiration to 5 minutes from now
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000);

    // Save or update OTP record for this email
    await Otp.findOneAndUpdate(
      { email: data.email },
      {
        otp: otpCode,
        data: registrationData,
        expiresAt,
      },
      { upsert: true, new: true }
    );

    // Send email
    await emailService.sendOtpEmail(data.email, otpCode);

    return { message: 'Mã OTP đã được gửi đến email của bạn' };
  }

  async verifyOtp(email: string, otp: string) {
    const otpRecord = await Otp.findOne({ email });
    
    if (!otpRecord) {
      throw new UnauthorizedError('Mã OTP không tồn tại hoặc đã hết hạn');
    }

    if (otpRecord.otp !== otp) {
      throw new UnauthorizedError('Mã OTP không chính xác');
    }

    // OTP is valid, create user
    const userData = otpRecord.data;
    
    // Just to be sure the email wasn't taken while waiting for OTP
    const existingEmail = await User.findOne({ email: userData.email });
    if (existingEmail) {
      throw new ConflictError('Email đã tồn tại trong hệ thống');
    }

    const user = await User.create({ ...userData, isVerified: true });

    // Delete OTP record
    await Otp.deleteOne({ email });

    return { message: 'Xác thực OTP thành công. Bạn có thể đăng nhập ngay bây giờ.' };
  }

  async login(email: string, password: string) {
    const user = await User.findOne({ email });
    if (!user) {
      throw new UnauthorizedError('Tài khoản hoặc mật khẩu không đúng');
    }

    if (user.isVerified === false) {
      throw new UnauthorizedError('Tài khoản chưa được xác thực OTP');
    }

    if (user.isBlocked) {
      throw new ForbiddenError('Tài khoản đã bị khóa');
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      throw new UnauthorizedError('Tài khoản hoặc mật khẩu không đúng');
    }

    const token = this.generateToken(user);

    return {
      token,
      user: {
        id: user._id,
        fullName: user.fullName,
        email: user.email,
        phone: user.phone,
        avatar: user.avatar,
        address: user.address,
        role: user.role,
      },
    };
  }

  async getProfile(userId: string) {
    const user = await User.findById(userId).select('-password');
    if (!user) {
      throw new NotFoundError('Không tìm thấy người dùng');
    }
    return user;
  }

  async updateProfile(userId: string, data: { fullName?: string; phone?: string; address?: string; avatar?: string }) {
    const user = await User.findByIdAndUpdate(userId, data, {
      new: true,
      runValidators: true,
    }).select('-password');

    if (!user) {
      throw new NotFoundError('Không tìm thấy người dùng');
    }
    return user;
  }

  async changePassword(userId: string, data: { oldPassword?: string; newPassword?: string }) {
    if (!data.oldPassword || !data.newPassword) {
      throw new ConflictError('Vui lòng cung cấp mật khẩu cũ và mới');
    }

    const user = await User.findById(userId);
    if (!user) {
      throw new NotFoundError('Không tìm thấy người dùng');
    }

    const isMatch = await bcrypt.compare(data.oldPassword, user.password);
    if (!isMatch) {
      throw new UnauthorizedError('Mật khẩu cũ không chính xác');
    }

    user.password = await bcrypt.hash(data.newPassword, 10);
    await user.save();

    return { message: 'Đổi mật khẩu thành công' };
  }

  async forgotPassword(email: string) {
    const user = await User.findOne({ email });
    if (!user) {
      throw new NotFoundError('Email không tồn tại trong hệ thống');
    }

    // Generate a 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();

    // Set expiration time to 5 minutes from now
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + 5);

    // Remove any existing OTP for this email
    await Otp.deleteMany({ email });

    // Save OTP to DB
    await Otp.create({
      email,
      otp,
      data: { purpose: 'reset_password' },
      expiresAt,
    });

    // Send email
    await emailService.sendForgotPasswordEmail(email, otp);

    return { message: 'Mã xác thực khôi phục mật khẩu đã được gửi đến email của bạn' };
  }

  async resetPassword(data: { email: string; otp: string; newPassword?: string }) {
    const { email, otp, newPassword } = data;

    if (!newPassword) {
      throw new ConflictError('Vui lòng cung cấp mật khẩu mới');
    }

    // Find valid OTP
    const otpRecord = await Otp.findOne({ email, otp });
    if (!otpRecord) {
      throw new UnauthorizedError('Mã xác thực không hợp lệ hoặc đã hết hạn');
    }

    if (otpRecord.data?.purpose !== 'reset_password') {
      throw new UnauthorizedError('Mã xác thực không đúng mục đích');
    }

    const user = await User.findOne({ email });
    if (!user) {
      throw new NotFoundError('Không tìm thấy người dùng');
    }

    user.password = await bcrypt.hash(newPassword, 10);
    await user.save();

    // Delete OTP after successful reset
    await Otp.deleteMany({ email });

    return { message: 'Đặt lại mật khẩu thành công' };
  }

  private generateToken(user: IUser): string {
    return jwt.sign(
      { id: user._id, email: user.email, role: user.role },
      config.jwtSecret,
      { expiresIn: config.jwtExpiresIn as jwt.SignOptions['expiresIn'] }
    );
  }
}

export const authService = new AuthService();
