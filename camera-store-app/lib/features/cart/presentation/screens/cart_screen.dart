import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../widgets/cart_item_card.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(const CartLoadRequested());
  }

  String _formatPrice(double price) {
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return '${formatted}đ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Giỏ hàng',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocListener<CartBloc, CartState>(
        listenWhen: (prev, curr) => curr.status == CartStatus.error && curr.errorMessage != prev.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
            // Reload cart to get fresh state
            context.read<CartBloc>().add(const CartLoadRequested());
          }
        },
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state.status == CartStatus.loading && state.cart == null) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state.status == CartStatus.error && state.cart == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        state.errorMessage ?? 'Không thể tải giỏ hàng',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.read<CartBloc>().add(const CartLoadRequested()),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            final items = state.cart?.items ?? [];

            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 100,
                      color: AppColors.textHint.withOpacity(0.4),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Giỏ hàng trống',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Hãy thêm sản phẩm yêu thích vào giỏ hàng nhé!',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: 200,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Tiếp tục mua sắm'),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Dismissible(
                  key: ValueKey(item.product.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.only(right: 24),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text('Xóa sản phẩm?'),
                        content: Text('Bạn có chắc muốn xóa "${item.product.name}" khỏi giỏ hàng?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: TextButton.styleFrom(foregroundColor: AppColors.error),
                            child: const Text('Xóa'),
                          ),
                        ],
                      ),
                    ) ?? false;
                  },
                  onDismissed: (_) {
                    context.read<CartBloc>().add(CartItemRemoved(productId: item.product.id));
                  },
                  child: CartItemCard(
                    item: item,
                    onIncrement: () {
                      // Frontend stock validation
                      if (item.quantity >= item.product.stock) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Chỉ còn ${item.product.stock} sản phẩm trong kho'),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                        return;
                      }
                      context.read<CartBloc>().add(
                            CartItemUpdated(
                              productId: item.product.id,
                              quantity: item.quantity + 1,
                            ),
                          );
                    },
                    onDecrement: () {
                      if (item.quantity <= 1) {
                        // Confirm before removing
                        showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text('Xóa sản phẩm?'),
                            content: Text('Xóa "${item.product.name}" khỏi giỏ hàng?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx, true);
                                  context.read<CartBloc>().add(
                                        CartItemRemoved(productId: item.product.id),
                                      );
                                },
                                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                                child: const Text('Xóa'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        context.read<CartBloc>().add(
                              CartItemUpdated(
                                productId: item.product.id,
                                quantity: item.quantity - 1,
                              ),
                            );
                      }
                    },
                    onRemove: () {
                      context.read<CartBloc>().add(
                            CartItemRemoved(productId: item.product.id),
                          );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),

      // STICKY BOTTOM BAR
      bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          final items = state.cart?.items ?? [];
          if (items.isEmpty) return const SizedBox.shrink();

          return ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  border: Border(
                    top: BorderSide(color: Colors.grey.withOpacity(0.1)),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tổng cộng',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatPrice(state.totalAmount),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.accent, Color(0xFFEA580C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Navigate to Checkout (Week 4)
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Tính năng Checkout sẽ được triển khai ở Tuần 4!'),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.payment, size: 20, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Thanh toán',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
