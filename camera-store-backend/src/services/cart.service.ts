import Cart from '../models/Cart';
import Product from '../models/Product';
import { NotFoundError, ValidationError } from '../utils/errors';

export class CartService {
  async getCart(userId: string) {
    let cart = await Cart.findOne({ user: userId }).populate('items.product');
    if (!cart) {
      cart = await Cart.create({ user: userId, items: [] });
      // populate after create returns empty items, so no need to populate
    }
    return cart;
  }

  async addToCart(userId: string, productId: string, quantity: number = 1) {
    // Validate quantity
    if (!quantity || quantity < 1) {
      throw new ValidationError('Số lượng phải lớn hơn 0');
    }

    // Validate product exists and is active
    const product = await Product.findById(productId);
    if (!product) {
      throw new NotFoundError('Sản phẩm không tồn tại');
    }
    if (!product.isActive) {
      throw new ValidationError('Sản phẩm đã ngừng kinh doanh');
    }

    // Validate stock
    if (product.stock <= 0) {
      throw new ValidationError('Sản phẩm đã hết hàng');
    }

    let cart = await Cart.findOne({ user: userId });

    if (!cart) {
      // Check stock for new cart
      if (quantity > product.stock) {
        throw new ValidationError(`Chỉ còn ${product.stock} sản phẩm trong kho`);
      }
      cart = await Cart.create({ user: userId, items: [{ product: productId, quantity }] });
    } else {
      const itemIndex = cart.items.findIndex((item) => item.product.toString() === productId);
      const currentQty = itemIndex > -1 ? cart.items[itemIndex].quantity : 0;
      const newQty = currentQty + quantity;

      // Check stock
      if (newQty > product.stock) {
        throw new ValidationError(
          `Không đủ hàng. Trong kho còn ${product.stock}, bạn đã có ${currentQty} trong giỏ`
        );
      }

      if (itemIndex > -1) {
        cart.items[itemIndex].quantity = newQty;
      } else {
        cart.items.push({ product: productId as any, quantity });
      }
      await cart.save();
    }

    await cart.populate('items.product');
    return cart;
  }

  async updateCartItem(userId: string, productId: string, quantity: number) {
    const cart = await Cart.findOne({ user: userId });
    if (!cart) {
      throw new NotFoundError('Giỏ hàng không tồn tại');
    }

    const itemIndex = cart.items.findIndex((item) => item.product.toString() === productId);
    if (itemIndex === -1) {
      throw new NotFoundError('Sản phẩm không có trong giỏ hàng');
    }

    if (quantity <= 0) {
      // Remove item if quantity is 0 or negative
      cart.items.splice(itemIndex, 1);
    } else {
      // Validate stock before updating
      const product = await Product.findById(productId);
      if (product && quantity > product.stock) {
        throw new ValidationError(`Chỉ còn ${product.stock} sản phẩm trong kho`);
      }
      cart.items[itemIndex].quantity = quantity;
    }

    await cart.save();
    await cart.populate('items.product');
    return cart;
  }

  async removeFromCart(userId: string, productId: string) {
    const cart = await Cart.findOne({ user: userId });
    if (!cart) {
      throw new NotFoundError('Giỏ hàng không tồn tại');
    }

    const itemExists = cart.items.some((item) => item.product.toString() === productId);
    if (!itemExists) {
      throw new NotFoundError('Sản phẩm không có trong giỏ hàng');
    }

    cart.items = cart.items.filter((item) => item.product.toString() !== productId);
    await cart.save();
    await cart.populate('items.product');
    return cart;
  }

  async clearCart(userId: string) {
    const cart = await Cart.findOne({ user: userId });
    if (cart) {
      cart.items = [];
      await cart.save();
    }
  }
}

export const cartService = new CartService();
