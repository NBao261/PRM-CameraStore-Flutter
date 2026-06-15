import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/cart_icon_badge.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../widgets/product_card.dart';
import '../widgets/filter_bottom_sheet.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  final GlobalKey _cartIconKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const ProductLoadRequested());
    context.read<ProductBloc>().add(CategoriesLoadRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<ProductBloc>().add(ProductSearchChanged(query));
    });
    setState(() {}); // Update to show/hide clear icon
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
    FocusScope.of(context).unfocus();
  }

  void _showFilterSheet() {
    final state = context.read<ProductBloc>().state;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(
        categories: state.categories,
        selectedCategory: state.selectedCategory,
        minPrice: state.minPrice,
        maxPrice: state.maxPrice,
        sortOption: state.sortOption,
        onApply: ({category, minPrice, maxPrice, sortOption}) {
          context.read<ProductBloc>().add(
                ProductFilterApplied(
                  category: category,
                  minPrice: minPrice,
                  maxPrice: maxPrice,
                  sort: sortOption,
                ),
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              title: const Text(
                AppStrings.appName,
                style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1),
              ),
              backgroundColor: AppColors.primary.withValues(alpha: 0.85),
              foregroundColor: Colors.white,
              elevation: 0,
              actions: [
                CartIconBadge(cartIconKey: _cartIconKey),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthLogoutRequested());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Header with Search bar + Filter button
          Container(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 70, 20, 24),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                )
              ],
            ),
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(100), // Pill shape
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: _onSearchChanged,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                hintText: 'Tìm kiếm máy ảnh...',
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(left: 12),
                                  child: Icon(Icons.search,
                                      color: AppColors.textHint),
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8),
                                        child: IconButton(
                                          icon: const Icon(Icons.cancel,
                                              color: AppColors.textSecondary),
                                          onPressed: _clearSearch,
                                        ),
                                      )
                                    : null,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 20),
                                hintStyle:
                                    const TextStyle(color: AppColors.textHint),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        BlocBuilder<ProductBloc, ProductState>(
                          buildWhen: (prev, curr) =>
                              prev.hasActiveFilters != curr.hasActiveFilters,
                          builder: (context, state) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                gradient: state.hasActiveFilters
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFFF97316),
                                          Color(0xFFEA580C)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: state.hasActiveFilters
                                    ? null
                                    : Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: state.hasActiveFilters
                                    ? [
                                        BoxShadow(
                                          color: AppColors.accent
                                              .withValues(alpha: 0.4),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _showFilterSheet,
                                  borderRadius: BorderRadius.circular(100),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    child: const Icon(
                                      Icons.tune,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    if (state.brands.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 38,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.brands.length + 1,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return _buildBrandChip(
                                label: 'Tất cả',
                                isSelected: state.selectedBrand == null,
                                onTap: () {
                                  context.read<ProductBloc>().add(
                                        ProductFilterApplied(
                                          category: state.selectedCategory,
                                          brand: null,
                                          minPrice: state.minPrice,
                                          maxPrice: state.maxPrice,
                                          sort: state.sortOption,
                                        ),
                                      );
                                },
                              );
                            }
                            final brand = state.brands[index - 1];
                            return _buildBrandChip(
                              label: brand.name,
                              isSelected: state.selectedBrand == brand.id,
                              onTap: () {
                                context.read<ProductBloc>().add(
                                      ProductFilterApplied(
                                        category: state.selectedCategory,
                                        brand: brand.id,
                                        minPrice: state.minPrice,
                                        maxPrice: state.maxPrice,
                                        sort: state.sortOption,
                                      ),
                                    );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),

          // Product Grid
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state.status == ProductStatus.loading) {
                  return const ProductGridSkeleton(itemCount: 6);
                }

                if (state.status == ProductStatus.error) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.errorMessage ?? 'Đã có lỗi xảy ra',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: 200,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                context
                                    .read<ProductBloc>()
                                    .add(const ProductLoadRequested());
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Thử lại'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 80,
                          color: AppColors.textHint.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Không tìm thấy sản phẩm nào',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Thử thay đổi từ khóa hoặc bộ lọc',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context
                        .read<ProductBloc>()
                        .add(const ProductLoadRequested());
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.53,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      final product = state.products[index];
                      return ProductCard(
                        product: product,
                        cartIconKey: _cartIconKey,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/product-detail',
                            arguments: product.id,
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandChip(
      {required String label,
      required bool isSelected,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.white : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primary : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
