import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';
import config from '../config/env';
import User from '../models/User';

async function seedAdmin() {
  try {
    await mongoose.connect(config.mongodbUri);
    console.log('Connected to MongoDB');

    const existingAdmin = await User.findOne({ email: 'admin@camerastore.com' });

    if (existingAdmin) {
      console.log('Admin account already exists, skipping seed.');
    } else {
      const hashedPassword = await bcrypt.hash('admin123', 10);
      await User.create({
        fullName: 'Camera Store Admin',
        email: 'admin@camerastore.com',
        phone: '0900000000',
        password: hashedPassword,
        role: 'admin',
        isVerified: true,
        isBlocked: false,
      });
      console.log('✅ Admin account created:');
      console.log('   Email: admin@camerastore.com');
      console.log('   Password: admin123');
    }
  } catch (error) {
    console.error('Error seeding admin:', error);
  } finally {
    await mongoose.disconnect();
    console.log('Disconnected from MongoDB');
  }
}

seedAdmin();
