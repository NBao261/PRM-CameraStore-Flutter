import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/cart_item_entity.dart';

class CartItemCard extends StatelessWidget {
  final CartItemEntity item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  String _formatPrice(double price) {
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return '${formatted}đ';
  }

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final unitPrice = product.hasDiscount ? product.salePrice! : product.price;
    final lineTotal = unitPrice * item.quantity;
    final isAtMaxStock = item.quantity >= product.stock;
    final isLowStock = product.stock <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Product Image ────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 96,
              height: 96,
              color: AppColors.surfaceDim,
              child: AppNetworkImage(
                imageUrl: product.firstImage,
                width: 96,
                height: 96,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // ── Product Info ─────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand
                if (product.brandName != null)
                  Text(
                    product.brandName!.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textHint,
                      letterSpacing: 0.8,
                    ),
                  ),
                const SizedBox(height: 4),

                // Name
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Stock badge — only show when low stock (≤ 3)
                if (isLowStock)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Còn ${product.stock} sản phẩm',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                SizedBox(height: isLowStock ? 8 : 4),

                // Price row
                Row(
                  children: [
                    Text(
                      _formatPrice(unitPrice),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: product.hasDiscount
                            ? AppColors.accent
                            : AppColors.primary,
                      ),
                    ),
                    if (product.hasDiscount) ...[
                      const SizedBox(width: 6),
                      Text(
                        _formatPrice(product.price),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // ── Quantity Controller + Line Total ──
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDim,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _QuantityButton(
                            icon: item.quantity <= 1
                                ? Icons.delete_outline
                                : Icons.remove,
                            color: item.quantity <= 1
                                ? AppColors.error
                                : AppColors.textSecondary,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              onDecrement();
                            },
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: Padding(
                              key: ValueKey(item.quantity),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          _QuantityButton(
                            icon: Icons.add,
                            color: isAtMaxStock
                                ? AppColors.textHint.withOpacity(0.3)
                                : AppColors.primary,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              if (isAtMaxStock) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Chỉ còn ${product.stock} sản phẩm trong kho'),
                                    backgroundColor: AppColors.warning,
                                  ),
                                );
                                return;
                              }
                              onIncrement();
                            },
                          ),
                        ],
                      ),
                    ),

                    // Line Total — Expanded to prevent overflow on long prices
                    Expanded(
                      child: Text(
                        _formatPrice(lineTotal),
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 48dp touch target button
class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuantityButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Icon(icon, size: 20, color: color),
          ),
        ),
      ),
    );
  }
}
