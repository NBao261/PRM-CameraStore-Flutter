import nodemailer from 'nodemailer';
import env from '../config/env';

class EmailService {
  private transporter: nodemailer.Transporter;

  constructor() {
    this.transporter = nodemailer.createTransport({
      service: 'gmail', // or configured host
      auth: {
        user: env.smtpUser || process.env.SMTP_USER || '',
        pass: env.smtpPass || process.env.SMTP_PASS || '',
      },
    });
  }

  async sendOtpEmail(to: string, otp: string): Promise<void> {
    const mailOptions = {
      from: `"Camera Store" <${env.smtpUser || process.env.SMTP_USER}>`,
      to,
      subject: 'Xác thực tài khoản Camera Store',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #eee; border-radius: 10px;">
          <h2 style="color: #F97316; text-align: center;">Xác Thực Tài Khoản</h2>
          <p>Xin chào,</p>
          <p>Bạn đã yêu cầu đăng ký tài khoản tại Camera Store. Vui lòng sử dụng mã OTP dưới đây để hoàn tất việc đăng ký:</p>
          <div style="text-align: center; margin: 30px 0;">
            <span style="font-size: 32px; font-weight: bold; letter-spacing: 5px; color: #1E293B; background: #F1F5F9; padding: 15px 25px; border-radius: 8px;">${otp}</span>
          </div>
          <p>Mã OTP này sẽ hết hạn sau <strong>5 phút</strong>.</p>
          <p>Nếu bạn không thực hiện yêu cầu này, vui lòng bỏ qua email này.</p>
          <br>
          <p>Trân trọng,<br><strong>Đội ngũ Camera Store</strong></p>
        </div>
      `,
    };

    try {
      await this.transporter.sendMail(mailOptions);
    } catch (error) {
      console.error('Error sending OTP email:', error);
      throw new Error('Không thể gửi email xác thực. Vui lòng kiểm tra lại email hoặc thử lại sau.');
    }
  }
}

export default new EmailService();
