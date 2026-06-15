import Product from '../models/Product';

export class ProductService {
  async getProducts(query: {
    search?: string;
    category?: string;
    brand?: string;
    minPrice?: string;
    maxPrice?: string;
    sort?: string;
  }) {
    const filter: any = { isActive: true };

    if (query.search)   filter.name = { $regex: query.search, $options: 'i' };
    if (query.category) filter.category = query.category;
    if (query.brand)    filter.brand = query.brand;
    if (query.minPrice || query.maxPrice) {
      filter.price = {};
      if (query.minPrice) filter.price.$gte = Number(query.minPrice);
      if (query.maxPrice) filter.price.$lte = Number(query.maxPrice);
    }

    let sortOption: any = { createdAt: -1 };
    if (query.sort === 'price_asc') sortOption = { price: 1 };
    else if (query.sort === 'price_desc') sortOption = { price: -1 };
    else if (query.sort === 'name_asc') sortOption = { name: 1 };
    else if (query.sort === 'name_desc') sortOption = { name: -1 };

    return Product.find(filter)
      .populate('brand', 'name slug')
      .populate('category', 'name slug')
      .sort(sortOption);
  }

  async getProductById(id: string) {
    const product = await Product.findById(id)
      .populate('brand', 'name slug')
      .populate('category', 'name slug');

    if (!product) {
      const { NotFoundError } = await import('../utils/errors');
      throw new NotFoundError('Không tìm thấy sản phẩm');
    }
    return product;
  }
}

export const productService = new ProductService();
