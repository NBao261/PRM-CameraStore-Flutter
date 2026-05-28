import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import User, { IUser } from '../models/User';
import config from '../config/env';
import { ConflictError, NotFoundError, UnauthorizedError, ForbiddenError } from '../utils/errors';

export class AuthService {
  async register(data: { fullName: string; email: string; phone: string; password: string }) {
    const existingUser = await User.findOne({ email: data.email });
    if (existingUser) {
      throw new ConflictError('Email đã tồn tại trong hệ thống');
    }

    const hashedPassword = await bcrypt.hash(data.password, 10);
    const user = await User.create({ ...data, password: hashedPassword });

    return { id: user._id, fullName: user.fullName, email: user.email };
  }

  async login(email: string, password: string) {
    const user = await User.findOne({ email });
    if (!user) {
      throw new UnauthorizedError('Email hoặc mật khẩu không đúng');
    }

    if (user.isBlocked) {
      throw new ForbiddenError('Tài khoản đã bị khóa');
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      throw new UnauthorizedError('Email hoặc mật khẩu không đúng');
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

  private generateToken(user: IUser): string {
    return jwt.sign(
      { id: user._id, email: user.email, role: user.role },
      config.jwtSecret,
      { expiresIn: config.jwtExpiresIn as jwt.SignOptions['expiresIn'] }
    );
  }
}

export const authService = new AuthService();
