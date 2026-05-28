import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
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

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 90,
              height: 90,
              color: AppColors.background,
              child: product.firstImage.isNotEmpty
                  ? Image.network(
                      product.firstImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.camera_alt_outlined, color: AppColors.textHint),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.camera_alt_outlined, color: AppColors.textHint),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.brandName != null)
                  Text(
                    product.brandName!.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textHint,
                      letterSpacing: 0.5,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Stock info
                Text(
                  'Kho: ${product.stock}',
                  style: TextStyle(
                    fontSize: 11,
                    color: product.stock <= 3 ? AppColors.error : AppColors.textHint,
                    fontWeight: product.stock <= 3 ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 6),
                // Price
                Row(
                  children: [
                    Text(
                      _formatPrice(unitPrice),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: product.hasDiscount ? AppColors.accent : AppColors.primary,
                      ),
                    ),
                    if (product.hasDiscount) ...[
                      const SizedBox(width: 6),
                      Text(
                        _formatPrice(product.price),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                // Quantity Controller + Line Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity Controller
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildQuantityButton(
                            icon: item.quantity <= 1 ? Icons.delete_outline : Icons.remove,
                            color: item.quantity <= 1 ? AppColors.error : AppColors.textSecondary,
                            onTap: onDecrement,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          _buildQuantityButton(
                            icon: Icons.add,
                            color: isAtMaxStock
                                ? AppColors.textHint.withOpacity(0.4)
                                : AppColors.primary,
                            onTap: isAtMaxStock
                                ? () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Chỉ còn ${product.stock} sản phẩm trong kho'),
                                        backgroundColor: AppColors.error,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10)),
                                      ),
                                    );
                                  }
                                : onIncrement,
                          ),
                        ],
                      ),
                    ),
                    // Line Total
                    Text(
                      _formatPrice(lineTotal),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
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

  Widget _buildQuantityButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
