import Cart from '../models/Cart';
import { NotFoundError } from '../utils/errors';

export class CartService {
  async getCart(userId: string) {
    let cart = await Cart.findOne({ user: userId }).populate('items.product');
    if (!cart) {
      cart = await Cart.create({ user: userId, items: [] });
    }
    return cart;
  }

  async addToCart(userId: string, productId: string, quantity: number = 1) {
    let cart = await Cart.findOne({ user: userId });

    if (!cart) {
      cart = await Cart.create({ user: userId, items: [{ product: productId, quantity }] });
    } else {
      const itemIndex = cart.items.findIndex((item) => item.product.toString() === productId);
      if (itemIndex > -1) {
        cart.items[itemIndex].quantity += quantity;
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
      cart.items.splice(itemIndex, 1);
    } else {
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
