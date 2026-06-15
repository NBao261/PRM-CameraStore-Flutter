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
        images: [
          '/public/images/products/sony-a7iv-1.jpg',
          '/public/images/products/sony-a7iv-2.jpg',
        ],
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
        images: [
          '/public/images/products/fujifilm-xt5-1.jpg',
          '/public/images/products/fujifilm-xt5-2.jpg',
        ],
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
        images: [
          '/public/images/products/canon-r6-1.jpg',
          '/public/images/products/canon-r6-2.jpg',
        ],
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
        images: [
          '/public/images/products/sony-lens-1.jpg',
          '/public/images/products/sony-lens-2.jpg',
        ],
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
      },
      {
        name: 'Nikon Z6 II Mirrorless Camera',
        brand: brandMap['nikon'],
        category: categoryMap['mirrorless'],
        images: [
          '/public/images/products/nikon-z6ii-1.jpg',
          '/public/images/products/nikon-z6ii-2.jpg',
        ],
        price: 49990000,
        salePrice: 47990000,
        description: 'Nikon Z6 II là máy ảnh mirrorless đa dụng mạnh mẽ với 2 bộ xử lý EXPEED 6 và khả năng quay video 4K tuyệt vời.',
        specs: {
          megapixel: '24.5MP',
          sensor: 'Full-frame BSI CMOS',
          isoRange: '100-51200',
          video: '4K 30p',
          connectivity: 'Wi-Fi, Bluetooth',
          weight: '705g'
        },
        stock: 12,
        isActive: true,
        warranty: '24 Tháng'
      },
      {
        name: 'Canon EOS 5D Mark IV DSLR',
        brand: brandMap['canon'],
        category: categoryMap['dslr'],
        images: [
          '/public/images/products/canon-5d4-1.jpg',
          '/public/images/products/canon-5d4-2.jpg',
        ],
        price: 65990000,
        salePrice: null,
        description: 'Máy ảnh DSLR Full-frame huyền thoại của Canon với cảm biến 30.4MP, hệ thống lấy nét Dual Pixel CMOS AF.',
        specs: {
          megapixel: '30.4MP',
          sensor: 'Full-frame CMOS',
          isoRange: '100-32000',
          video: '4K 30p',
          connectivity: 'Wi-Fi, GPS',
          weight: '890g'
        },
        stock: 4,
        isActive: true,
        warranty: '24 Tháng'
      },
      {
        name: 'Fujifilm XF 35mm f/1.4 R Lens',
        brand: brandMap['fujifilm'],
        category: categoryMap['lens'],
        images: [
          '/public/images/products/fuji-35-1.jpg',
        ],
        price: 13500000,
        salePrice: 12900000,
        description: 'Ống kính tiêu chuẩn kinh điển của Fujifilm, mang lại hiệu ứng bokeh mượt mà và chất lượng quang học xuất sắc.',
        specs: {
          lensType: 'Prime',
          weight: '187g'
        },
        stock: 25,
        isActive: true,
        warranty: '12 Tháng'
      },
      {
        name: 'Sony NP-FZ100 Rechargeable Battery',
        brand: brandMap['sony'],
        category: categoryMap['accessories'],
        images: [
          '/public/images/products/sony-battery-1.jpg',
        ],
        price: 1990000,
        salePrice: null,
        description: 'Pin sạc Lithium-Ion dung lượng cao chính hãng dành cho các dòng máy ảnh Sony Alpha.',
        specs: {
          battery: '2280 mAh',
          weight: '83g'
        },
        stock: 50,
        isActive: true,
        warranty: '6 Tháng'
      },
      {
        name: 'Canon LP-E6NH Battery Pack',
        brand: brandMap['canon'],
        category: categoryMap['accessories'],
        images: [
          '/public/images/products/canon-battery-1.jpg',
        ],
        price: 2650000,
        salePrice: 2500000,
        description: 'Pin sạc chính hãng Canon dung lượng 2130mAh, tương thích với EOS R5, R6, và các dòng máy dùng LP-E6.',
        specs: {
          battery: '2130 mAh',
          weight: '80g'
        },
        stock: 30,
        isActive: true,
        warranty: '6 Tháng'
      },
      {
        name: 'Nikon NIKKOR Z 50mm f/1.8 S Lens',
        brand: brandMap['nikon'],
        category: categoryMap['lens'],
        images: [
          '/public/images/products/nikon-50-1.jpg',
        ],
        price: 14500000,
        salePrice: null,
        description: 'Ống kính tiêu chuẩn dòng S-Line của Nikon dành cho hệ thống ngàm Z, độ sắc nét hoàn hảo từ tâm đến rìa.',
        specs: {
          lensType: 'Prime',
          weight: '415g'
        },
        stock: 18,
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
