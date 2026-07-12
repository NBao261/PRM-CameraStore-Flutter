import mongoose from 'mongoose';
import Coupon from '../models/Coupon';
import config from '../config/env';

/**
 * Seed script to create sample coupon codes.
 * Run: npx ts-node src/scripts/seedCoupons.ts
 */
async function seedCoupons() {
  await mongoose.connect(config.mongodbUri);
  console.log('Connected to MongoDB');

  const coupons = [
    {
      code: 'WELCOME10',
      type: 'percent' as const,
      value: 10,
      minOrderAmount: 1000000,   // 1 triệu
      maxDiscount: 500000,       // tối đa giảm 500k
      expiresAt: new Date('2027-12-31'),
      usageLimit: 100,
      usedCount: 0,
      isActive: true,
    },
    {
      code: 'SUMMER20',
      type: 'percent' as const,
      value: 20,
      minOrderAmount: 5000000,   // 5 triệu
      maxDiscount: 2000000,      // tối đa giảm 2 triệu
      expiresAt: new Date('2027-08-31'),
      usageLimit: 50,
      usedCount: 0,
      isActive: true,
    },
    {
      code: 'FLAT500K',
      type: 'fixed' as const,
      value: 500000,             // giảm cố định 500k
      minOrderAmount: 3000000,   // 3 triệu
      expiresAt: new Date('2027-12-31'),
      usageLimit: 200,
      usedCount: 0,
      isActive: true,
    },
    {
      code: 'VIP30',
      type: 'percent' as const,
      value: 30,
      minOrderAmount: 10000000,  // 10 triệu
      maxDiscount: 5000000,      // tối đa giảm 5 triệu
      expiresAt: new Date('2027-06-30'),
      usageLimit: 20,
      usedCount: 0,
      isActive: true,
    },
    {
      code: 'FREESHIP',
      type: 'fixed' as const,
      value: 100000,             // giảm 100k (tương đương free ship)
      minOrderAmount: 500000,    // 500k
      expiresAt: new Date('2027-12-31'),
      usageLimit: 500,
      usedCount: 0,
      isActive: true,
    },
  ];

  for (const couponData of coupons) {
    const exists = await Coupon.findOne({ code: couponData.code });
    if (exists) {
      console.log(`⏭ Coupon "${couponData.code}" already exists, skipping.`);
    } else {
      await Coupon.create(couponData);
      console.log(`✅ Created coupon: ${couponData.code} (${couponData.type} ${couponData.value}${couponData.type === 'percent' ? '%' : 'đ'})`);
    }
  }

  console.log('\n🎟️  Done seeding coupons!');
  await mongoose.disconnect();
}

seedCoupons().catch((err) => {
  console.error('Seed error:', err);
  process.exit(1);
});
