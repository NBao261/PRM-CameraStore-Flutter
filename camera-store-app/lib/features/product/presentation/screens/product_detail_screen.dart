import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/cart_icon_badge.dart';
import '../../../../core/widgets/fly_to_cart_animation.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product_entity.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductEntity? _product;
  bool _isLoading = true;
  String? _error;
  int _currentImageIndex = 0;
  int _quantity = 1;
  final PageController _pageController = PageController();
  final GlobalKey _cartIconKey = GlobalKey();
  final GlobalKey _addToCartBtnKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    try {
      final apiClient = ApiClient();
      final dataSource = ProductRemoteDataSource(apiClient);
      final repo = ProductRepositoryImpl(dataSource);
      final product = await repo.getProductById(widget.productId);
      setState(() {
        _product = product;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.primary,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_error != null || _product == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.primary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              const Text('Không thể tải thông tin sản phẩm'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _loadProduct();
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final product = _product!;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true, // For glassmorphism bottom bar to overlap list
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400, // Taller hero
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.white.withOpacity(0.5),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: CartIconBadge(cartIconKey: _cartIconKey),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF1F5F9), Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.only(top: 80, bottom: 16),
                child: product.images.isNotEmpty
                    ? Stack(
                        children: [
                          Column(
                            children: [
                              // ── Image PageView ──────────────────
                              Expanded(
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: product.images.length,
                                  onPageChanged: (index) {
                                    setState(() => _currentImageIndex = index);
                                  },
                                  itemBuilder: (context, index) {
                                    final isFirst = index == 0;
                                    final imageWidget = Image.network(
                                      product.images[index],
                                      fit: BoxFit.contain,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.textHint,
                                          ),
                                        );
                                      },
                                      errorBuilder: (_, __, ___) => const Center(
                                        child: Icon(Icons.camera_alt_outlined,
                                            size: 80, color: AppColors.textHint),
                                      ),
                                    );
                                    // Hero only on first image for smooth transition
                                    if (isFirst) {
                                      return Hero(
                                        tag: 'product-image-${product.id}',
                                        child: imageWidget,
                                      );
                                    }
                                    return imageWidget;
                                  },
                                ),
                              ),
                              // ── Dot Indicators ─────────────────
                              if (product.images.length > 1)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      product.images.length,
                                      (index) => AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        width: _currentImageIndex == index ? 24 : 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          color: _currentImageIndex == index
                                              ? AppColors.accent
                                              : AppColors.textHint.withOpacity(0.3),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          // ── Discount Badge ──────────────────
                          if (product.hasDiscount)
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accent.withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '-${product.discountPercent}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      )
                    : const Center(
                        child: Icon(Icons.camera_alt_outlined,
                            size: 80, color: AppColors.textHint),
                      ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 20,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 100), // Extra bottom padding for glassmorphism
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.brandName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        product.brandName!.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Status & Warranty Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: product.inStock 
                              ? AppColors.success.withOpacity(0.1) 
                              : AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              product.inStock ? Icons.check_circle : Icons.cancel,
                              size: 16,
                              color: product.inStock
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              product.inStock
                                  ? 'Còn hàng (${product.stock})'
                                  : 'Hết hàng',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: product.inStock
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (product.warranty != null && product.warranty!.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.verified_user_outlined,
                                  size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                product.warranty!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  _buildSpecsSection(product.specs),
                  const SizedBox(height: 40),
                  
                  const Text(
                    'Mô tả sản phẩm',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product.description.isNotEmpty
                        ? product.description
                        : 'Chưa có mô tả cho sản phẩm này.',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 60), // extra padding for scrolling
                ],
              ),
            ),
          ),
        ],
      ),
      
      // GLASSMORPHISM STICKY BOTTOM BAR
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Row 1: Price + Quantity Selector ───────────────────────
                  Row(
                    children: [
                      // Price
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (product.hasDiscount)
                              Text(
                                product.originalPrice,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textHint,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            Text(
                              product.displayPrice,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                                color: product.hasDiscount
                                    ? AppColors.accent
                                    : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Quantity Selector
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          children: [
                            _QuantityButton(
                              icon: Icons.remove,
                              onTap: _quantity > 1
                                  ? () => setState(() => _quantity--)
                                  : null,
                            ),
                            SizedBox(
                              width: 36,
                              child: Text(
                                '$_quantity',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            _QuantityButton(
                              icon: Icons.add,
                              onTap: _quantity < product.stock
                                  ? () => setState(() => _quantity++)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // ── Row 2: Add to Cart button (full width) ──────────────
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.accent, AppColors.accentDark],
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
                        onPressed: product.inStock
                            ? () {
                                HapticFeedback.mediumImpact();
                                final cartState = context.read<CartBloc>().state;
                                final currentQty = cartState.getQuantityForProduct(product.id);
                                if (currentQty + _quantity > product.stock) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Chỉ còn ${product.stock - currentQty} sản phẩm có thể thêm!',
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
                                FlyToCartAnimation.trigger(
                                  context: context,
                                  startGlobalKey: _addToCartBtnKey,
                                  targetGlobalKey: _cartIconKey,
                                );
                                context.read<CartBloc>().add(
                                  CartItemAdded(productId: product.id, quantity: _quantity),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.check_circle, color: Colors.white, size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text('Đã thêm $_quantity "${product.name}" vào giỏ hàng!')),
                                      ],
                                    ),
                                    backgroundColor: AppColors.success,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          key: _addToCartBtnKey,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_cart_outlined, size: 20, color: Colors.white),
                            const SizedBox(width: 8),
                            const Text(
                              'Thêm vào giỏ',
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
      ),
    );
  }

  Widget _buildSpecsSection(ProductSpecs specs) {
    final specsList = <MapEntry<IconData, MapEntry<String, String>>>[];
    if (specs.megapixel.isNotEmpty) specsList.add(MapEntry(Icons.camera, MapEntry('Độ phân giải', specs.megapixel)));
    if (specs.sensor.isNotEmpty) specsList.add(MapEntry(Icons.sensor_window, MapEntry('Cảm biến', specs.sensor)));
    if (specs.isoRange.isNotEmpty) specsList.add(MapEntry(Icons.iso, MapEntry('ISO', specs.isoRange)));
    if (specs.lensType.isNotEmpty) specsList.add(MapEntry(Icons.camera, MapEntry('Ống kính', specs.lensType)));
    if (specs.video.isNotEmpty) specsList.add(MapEntry(Icons.videocam, MapEntry('Video', specs.video)));
    if (specs.connectivity.isNotEmpty) specsList.add(MapEntry(Icons.wifi, MapEntry('Kết nối', specs.connectivity)));
    if (specs.battery.isNotEmpty) specsList.add(MapEntry(Icons.battery_full, MapEntry('Pin', specs.battery)));
    if (specs.weight.isNotEmpty) specsList.add(MapEntry(Icons.scale, MapEntry('Trọng lượng', specs.weight)));

    if (specsList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thông số kỹ thuật',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: specsList.map((entry) {
            return Container(
              width: (MediaQuery.of(context).size.width - 48 - 12) / 2, // 2 columns, padding 24
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(entry.key, size: 18, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.value.key,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textHint,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.value.value,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Helper Widget for Quantity Button ─────────────────
class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QuantityButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isEnabled ? Colors.white : AppColors.textHint,
        ),
      ),
    );
  }
}
