import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/shimmer_loading.dart';
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

  Future<void> _confirmClearAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xóa tất cả?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Toàn bộ sản phẩm trong giỏ hàng sẽ bị xóa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Xóa hết', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<CartBloc>().add(const CartClearedAll());
    }
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
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              final hasItems = (state.cart?.items ?? []).isNotEmpty;
              if (!hasItems) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Xóa tất cả',
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: () => _confirmClearAll(context),
              );
            },
          ),
        ],
      ),
      body: BlocListener<CartBloc, CartState>(
        listenWhen: (prev, curr) =>
            curr.status == CartStatus.error &&
            curr.errorMessage != prev.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
            context.read<CartBloc>().add(const CartLoadRequested());
          }
        },
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            // ── Full-page loading (first load) ──────────────────
            if (state.status == CartStatus.loading && state.cart == null) {
              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                itemCount: 3,
                itemBuilder: (_, __) => const CartItemSkeleton(),
              );
            }

            // ── Error (no cached data) ──────────────────────────
            if (state.status == CartStatus.error && state.cart == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        state.errorMessage ?? 'Không thể tải giỏ hàng',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 15),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context
                          .read<CartBloc>()
                          .add(const CartLoadRequested()),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            final items = state.cart?.items ?? [];

            // ── Empty State ─────────────────────────────────────
            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Illustration container
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.06),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shopping_cart_outlined,
                        size: 72,
                        color: AppColors.primary.withOpacity(0.35),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Giỏ hàng trống',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Thêm sản phẩm yêu thích\nvào giỏ hàng để tiếp tục nhé!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: 220,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text(
                          'Tiếp tục mua sắm',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // ── Item List ───────────────────────────────────────
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isUpdating =
                    state.updatingProductId == item.product.id;
                return Dismissible(
                  key: ValueKey(item.product.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.only(right: 24),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_outline,
                            color: Colors.white, size: 28),
                        SizedBox(height: 4),
                        Text('Xóa',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            title: const Text('Xóa sản phẩm?'),
                            content: Text(
                                'Bạn có chắc muốn xóa "${item.product.name}" khỏi giỏ hàng?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(ctx, false),
                                child: const Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(ctx, true),
                                style: TextButton.styleFrom(
                                    foregroundColor: AppColors.error),
                                child: const Text('Xóa'),
                              ),
                            ],
                          ),
                        ) ??
                        false;
                  },
                  onDismissed: (_) {
                    context.read<CartBloc>().add(
                        CartItemRemoved(productId: item.product.id));
                  },
                  child: CartItemCard(
                    item: item,
                    isSelected: state.selectedItemIds.contains(item.product.id),
                    onSelectionChanged: (bool? val) {
                      if (val != null) {
                        context.read<CartBloc>().add(
                          CartItemSelectionToggled(
                            productId: item.product.id,
                            isSelected: val,
                          ),
                        );
                      }
                    },
                    onIncrement: () {
                      if (item.quantity >= item.product.stock) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Chỉ còn ${item.product.stock} sản phẩm trong kho'),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
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
                        showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            title: const Text('Xóa sản phẩm?'),
                            content: Text(
                                'Xóa "${item.product.name}" khỏi giỏ hàng?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(ctx, false),
                                child: const Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx, true);
                                  context.read<CartBloc>().add(
                                        CartItemRemoved(
                                            productId: item.product.id),
                                      );
                                },
                                style: TextButton.styleFrom(
                                    foregroundColor: AppColors.error),
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
                          CartItemRemoved(productId: item.product.id));
                    },
                  ),
                );
              },
            );
          },
        ),
      ),

      // ── STICKY BOTTOM BAR ─────────────────────────────────────
      bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          final items = state.cart?.items ?? [];
          if (items.isEmpty) return const SizedBox.shrink();

          return ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  border: Border(
                    top: BorderSide(
                        color: AppColors.border.withOpacity(0.5)),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Item count summary & Select All
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: state.selectedItemIds.length == items.length && items.isNotEmpty,
                                  onChanged: (val) {
                                    if (val != null) {
                                      context.read<CartBloc>().add(CartAllItemsSelectionToggled(isSelected: val));
                                    }
                                  },
                                  activeColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Chọn tất cả',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${state.selectedTotalItems} sản phẩm',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (_calcSaving(state) > 0)
                                Text(
                                  'Tiết kiệm được ${_formatPrice(_calcSaving(state))}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Total price
                          Expanded(
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
                                const SizedBox(height: 2),
                                AnimatedSwitcher(
                                  duration:
                                      const Duration(milliseconds: 300),
                                  transitionBuilder: (child, anim) =>
                                      FadeTransition(
                                          opacity: anim, child: child),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _formatPrice(state.selectedTotalAmount),
                                      key: ValueKey(state.selectedTotalAmount),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.primary,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Checkout button
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.accent,
                                    AppColors.accentDark
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.accent.withOpacity(0.35),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: state.selectedItemIds.isEmpty
                                    ? null
                                    : () {
                                        HapticFeedback.mediumImpact();
                                        Navigator.of(context).pushNamed('/checkout');
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  disabledBackgroundColor: Colors.transparent,
                                  disabledForegroundColor: Colors.white.withOpacity(0.5),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(100),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Thanh toán',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded,
                                        size: 20, color: Colors.white),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
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

  /// Calculate total saving (original price - sale price) across all items
  double _calcSaving(CartState state) {
    if (state.cart == null) return 0;
    double saving = 0;
    for (final item in state.cart!.items) {
      if (item.product.hasDiscount) {
        saving +=
            (item.product.price - item.product.salePrice!) * item.quantity;
      }
    }
    return saving;
  }
}
