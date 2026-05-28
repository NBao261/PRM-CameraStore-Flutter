import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../domain/entities/product_entity.dart';

class ProductCard extends StatefulWidget {
  final ProductEntity product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isPressed ? 0.02 : 0.06),
                blurRadius: _isPressed ? 8 : 20,
                offset: Offset(0, _isPressed ? 2 : 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Section
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: widget.product.firstImage.isNotEmpty
                          ? Hero(
                              tag: 'product-image-${widget.product.id}',
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                                child: Image.network(
                                  widget.product.firstImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(
                                      Icons.camera_alt_outlined,
                                      size: 40,
                                      color: AppColors.textHint,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.camera_alt_outlined,
                                size: 40,
                                color: AppColors.textHint,
                              ),
                            ),
                    ),
                    if (!widget.product.inStock)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Hết hàng',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    if (widget.product.hasDiscount && widget.product.inStock)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '-${((1 - widget.product.salePrice! / widget.product.price) * 100).round()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Product Info Section
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.product.brandName != null)
                        Text(
                          widget.product.brandName!.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textHint,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.product.hasDiscount)
                                  Text(
                                    widget.product.originalPrice,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textHint,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                Text(
                                  widget.product.displayPrice,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: widget.product.hasDiscount
                                        ? AppColors.accent
                                        : AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Quick Add to Cart Button (Thumb zone)
                          if (widget.product.inStock)
                            Material(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  context.read<CartBloc>().add(
                                    CartItemAdded(productId: widget.product.id),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.check_circle, color: Colors.white, size: 18),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text('Đã thêm "${widget.product.name}" vào giỏ!')),
                                        ],
                                      ),
                                      backgroundColor: AppColors.success,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                // 48dp touch target (touch-psychology.md)
                                child: const SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: Center(
                                    child: Icon(
                                      Icons.add_shopping_cart_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
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
            ],
          ),
        ),
      ),
    );
  }
}
