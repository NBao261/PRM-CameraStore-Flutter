import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/fly_to_cart_animation.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../cart/presentation/bloc/cart_state.dart';
import '../../domain/entities/product_entity.dart';

class ProductCard extends StatefulWidget {
  final ProductEntity product;
  final VoidCallback onTap;
  final GlobalKey? cartIconKey;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.cartIconKey,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isPressed = false;
  final GlobalKey _addToCartKey = GlobalKey();

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
              // Product Image Section — fixed aspect ratio for uniform sizing
              AspectRatio(
                aspectRatio: 1.0,
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
                      padding: const EdgeInsets.all(12),
                      child: widget.product.firstImage.isNotEmpty
                          ? Hero(
                              tag: 'product-image-${widget.product.id}',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  widget.product.firstImage,
                                  fit: BoxFit.contain,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.textHint,
                                      ),
                                    );
                                  },
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
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                      const SizedBox(height: 2),
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_hasAnySpecs()) ...[
                        const SizedBox(height: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildSpecBadges().take(1).map((badge) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: badge,
                            );
                          }).toList(),
                        ),
                      ],
                      if (widget.product.reviewCount > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            ...List.generate(5, (i) => Icon(
                              i < widget.product.averageRating.round()
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 12,
                              color: i < widget.product.averageRating.round()
                                  ? Colors.amber.shade600
                                  : AppColors.textHint,
                            )),
                            const SizedBox(width: 4),
                            Text(
                              '(${widget.product.reviewCount})',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textHint,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
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
                                  // Stock validation
                                  final cartState =
                                      context.read<CartBloc>().state;
                                  final currentQty = cartState
                                      .getQuantityForProduct(widget.product.id);
                                  if (currentQty >= widget.product.stock) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(
                                                Icons.warning_amber_rounded,
                                                color: Colors.white,
                                                size: 18),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Chỉ còn ${widget.product.stock} sản phẩm trong kho!',
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: AppColors.error,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                    return;
                                  }
                                  // Trigger fly-to-cart animation
                                  if (widget.cartIconKey != null) {
                                    FlyToCartAnimation.trigger(
                                      context: context,
                                      startGlobalKey: _addToCartKey,
                                      targetGlobalKey: widget.cartIconKey!,
                                    );
                                  }
                                  context.read<CartBloc>().add(
                                        CartItemAdded(
                                            productId: widget.product.id),
                                      );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.check_circle,
                                              color: Colors.white, size: 18),
                                          const SizedBox(width: 8),
                                          Expanded(
                                              child: Text(
                                                  'Đã thêm "${widget.product.name}" vào giỏ!')),
                                        ],
                                      ),
                                      backgroundColor: AppColors.success,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                // 48dp touch target (touch-psychology.md)
                                child: SizedBox(
                                  key: _addToCartKey,
                                  width: 40,
                                  height: 40,
                                  child: const Center(
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

  bool _hasAnySpecs() {
    final specs = widget.product.specs;
    return specs.megapixel.isNotEmpty ||
        specs.sensor.isNotEmpty ||
        specs.video.isNotEmpty ||
        specs.lensType.isNotEmpty ||
        specs.battery.isNotEmpty ||
        specs.weight.isNotEmpty ||
        (widget.product.categoryName?.isNotEmpty ?? false);
  }

  List<Widget> _buildSpecBadges() {
    final specs = widget.product.specs;
    final badges = <Widget>[];

    if (specs.megapixel.isNotEmpty) {
      badges.add(_buildSpecBadge(Icons.camera_outlined, specs.megapixel));
    }
    if (specs.sensor.isNotEmpty) {
      badges.add(_buildSpecBadge(Icons.sensor_window_outlined, specs.sensor));
    }
    if (specs.video.isNotEmpty && specs.sensor.isEmpty) {
      badges.add(_buildSpecBadge(Icons.videocam_outlined, specs.video));
    }
    if (specs.lensType.isNotEmpty) {
      badges.add(_buildSpecBadge(Icons.lens_outlined, specs.lensType));
    }
    if (specs.battery.isNotEmpty) {
      badges.add(
          _buildSpecBadge(Icons.battery_charging_full_outlined, specs.battery));
    }
    if (specs.weight.isNotEmpty) {
      badges.add(_buildSpecBadge(Icons.monitor_weight_outlined, specs.weight));
    }

    // If no specs available, try to show category
    if (badges.isEmpty &&
        widget.product.categoryName != null &&
        widget.product.categoryName!.isNotEmpty) {
      badges.add(_buildSpecBadge(
          Icons.category_outlined, widget.product.categoryName!));
    }

    return badges.take(2).toList();
  }

  Widget _buildSpecBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
