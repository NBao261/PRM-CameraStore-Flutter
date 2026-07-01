import mongoose from 'mongoose';
import dotenv from 'dotenv';
import StoreLocation from '../models/StoreLocation';
import path from 'path';

dotenv.config({ path: path.resolve(__dirname, '../../.env') });

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/camera_store';

const storesData = [
  {
    name: 'Camera Store',
    address: '123 Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP.HCM',
    phone: '028 1234 5678',
    openingHours: '8:00 – 21:00',
    latitude: 10.7739,
    longitude: 106.7030,
  },
];

const seedStores = async () => {
  try {
    console.log('Connecting to MongoDB...');
    await mongoose.connect(MONGODB_URI);
    console.log('Connected to MongoDB');

    console.log('Clearing existing store locations...');
    await StoreLocation.deleteMany({});

    console.log('Seeding Store Location...');
    await StoreLocation.insertMany(storesData);

    console.log('✅ Store location seeded successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Error seeding stores:', error);
    process.exit(1);
  }
};

seedStores();
