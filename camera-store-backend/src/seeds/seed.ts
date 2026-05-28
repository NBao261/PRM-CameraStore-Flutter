import mongoose from 'mongoose';
import dotenv from 'dotenv';
import Brand from '../models/Brand';
import Category from '../models/Category';
import Product from '../models/Product';
import path from 'path';

// Load env vars
dotenv.config({ path: path.resolve(__dirname, '../../.env') });

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/camera_store';

const brandsData = [
  { name: 'Sony', slug: 'sony' },
  { name: 'Canon', slug: 'canon' },
  { name: 'Fujifilm', slug: 'fujifilm' },
  { name: 'Nikon', slug: 'nikon' },
];

const categoriesData = [
  { name: 'Máy ảnh Mirrorless', slug: 'mirrorless' },
  { name: 'Máy ảnh DSLR', slug: 'dslr' },
  { name: 'Ống kính (Lens)', slug: 'lens' },
  { name: 'Phụ kiện', slug: 'accessories' },
];

const seedDatabase = async () => {
  try {
    console.log('Connecting to MongoDB...');
    await mongoose.connect(MONGODB_URI);
    console.log('Connected to MongoDB');

    // Clear existing data
    console.log('Clearing existing data...');
    await Brand.deleteMany({});
    await Category.deleteMany({});
    await Product.deleteMany({});

    // Seed Brands
    console.log('Seeding Brands...');
    const insertedBrands = await Brand.insertMany(brandsData);
    const brandMap = insertedBrands.reduce((acc, brand) => {
      acc[brand.slug] = brand._id;
      return acc;
    }, {} as Record<string, any>);

    // Seed Categories
    console.log('Seeding Categories...');
    const insertedCategories = await Category.insertMany(categoriesData);
    const categoryMap = insertedCategories.reduce((acc, cat) => {
      acc[cat.slug] = cat._id;
      return acc;
    }, {} as Record<string, any>);

    // Seed Products
    console.log('Seeding Products...');
    const productsData = [
      {
        name: 'Sony Alpha a7 IV Mirrorless Camera',
        brand: brandMap['sony'],
        category: categoryMap['mirrorless'],
        images: ['https://product.hstatic.net/1000228168/product/1__1__d03d7c5031d24b6eba14dc27f4228965_master.jpg'],
        price: 59990000,
        salePrice: 57990000,
        description: 'Sony a7 IV là máy ảnh mirrorless full-frame đa dụng hoàn hảo, kết hợp độ phân giải 33MP với khả năng quay video 4K 60p.',
        specs: {
          megapixel: '33MP',
          sensor: 'Full-frame Exmor R CMOS',
          isoRange: '100-51200',
          video: '4K 60p',
          connectivity: 'Wi-Fi, Bluetooth',
          weight: '658g'
        },
        stock: 15,
        isActive: true,
        warranty: '24 Tháng'
      },
      {
        name: 'Fujifilm X-T5 Mirrorless Camera',
        brand: brandMap['fujifilm'],
        category: categoryMap['mirrorless'],
        images: ['https://product.hstatic.net/1000228168/product/2_70605a96dbf24beeb906cf68aeb1d8a3_master.jpg'],
        price: 43990000,
        salePrice: null,
        description: 'Fujifilm X-T5 trang bị cảm biến 40MP APS-C X-Trans CMOS 5 HR, hệ thống lấy nét tự động AI, hỗ trợ quay video 6.2K/30p.',
        specs: {
          megapixel: '40.2MP',
          sensor: 'APS-C X-Trans CMOS',
          isoRange: '125-12800',
          video: '6.2K 30p',
          connectivity: 'Wi-Fi, Bluetooth',
          weight: '557g'
        },
        stock: 8,
        isActive: true,
        warranty: '24 Tháng'
      },
      {
        name: 'Canon EOS R6 Mark II Mirrorless Camera',
        brand: brandMap['canon'],
        category: categoryMap['mirrorless'],
        images: ['https://product.hstatic.net/1000228168/product/r6_mark_ii_43b0dcd1d7394c8eac5871f7626efb21_master.png'],
        price: 60000000,
        salePrice: 58500000,
        description: 'Canon EOS R6 Mark II là cỗ máy tốc độ với khả năng chụp 40 fps và quay video 4K 60p (không crop).',
        specs: {
          megapixel: '24.2MP',
          sensor: 'Full-frame CMOS',
          isoRange: '100-102400',
          video: '4K 60p',
          connectivity: 'Wi-Fi, Bluetooth',
          weight: '670g'
        },
        stock: 5,
        isActive: true,
        warranty: '12 Tháng'
      },
      {
        name: 'Sony FE 24-70mm f/2.8 GM II Lens',
        brand: brandMap['sony'],
        category: categoryMap['lens'],
        images: ['https://product.hstatic.net/1000228168/product/lens-sony-fe-24-70mm-f2.8-gm-ii-01_master.jpg'],
        price: 49990000,
        salePrice: 47990000,
        description: 'Ống kính zoom chuẩn G Master thế hệ thứ 2, nhỏ gọn và nhẹ nhất trong phân khúc với chất lượng quang học vượt trội.',
        specs: {
          lensType: 'Zoom đa dụng',
          weight: '695g'
        },
        stock: 20,
        isActive: true,
        warranty: '12 Tháng'
      }
    ];

    await Product.insertMany(productsData);

    console.log('Seeding completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Error seeding database:', error);
    process.exit(1);
  }
};

seedDatabase();
