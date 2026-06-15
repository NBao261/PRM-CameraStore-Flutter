import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/product_entity.dart';

class FilterBottomSheet extends StatefulWidget {
  final List<CategoryEntity> categories;
  final String? selectedCategory;
  final double? minPrice;
  final double? maxPrice;
  final String? sortOption;
  final Function({String? category, double? minPrice, double? maxPrice, String? sortOption})
      onApply;

  const FilterBottomSheet({
    super.key,
    required this.categories,
    this.selectedCategory,
    this.minPrice,
    this.maxPrice,
    this.sortOption,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}
class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _selectedCategory;
  String? _sortOption;
  double? _minPrice;
  double? _maxPrice;

  final List<Map<String, dynamic>> _priceRanges = [
    {'label': 'Tất cả', 'min': null, 'max': null},
    {'label': 'Dưới 5 triệu', 'min': null, 'max': 5000000.0},
    {'label': '5 - 10 triệu', 'min': 5000000.0, 'max': 10000000.0},
    {'label': '10 - 20 triệu', 'min': 10000000.0, 'max': 20000000.0},
    {'label': '20 - 50 triệu', 'min': 20000000.0, 'max': 50000000.0},
    {'label': 'Trên 50 triệu', 'min': 50000000.0, 'max': null},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _sortOption = widget.sortOption;
    _minPrice = widget.minPrice;
    _maxPrice = widget.maxPrice;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bộ lọc',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = null;
                      _sortOption = null;
                      _minPrice = null;
                      _maxPrice = null;
                    });
                  },
                  child: const Text(
                    'Xóa bộ lọc',
                    style: TextStyle(color: AppColors.accent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Category section
            if (widget.categories.isNotEmpty) ...[
              const Text(
                'Danh mục',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildCategoryChip(null, 'Tất cả'),
                  ...widget.categories.map(
                    (cat) => _buildCategoryChip(cat.id, cat.name),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Sort section
            const Text(
              'Sắp xếp',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSortChip(null, 'Mới nhất'),
                _buildSortChip('name_asc', 'Tên A-Z'),
                _buildSortChip('name_desc', 'Tên Z-A'),
                _buildSortChip('price_asc', 'Giá tăng dần'),
                _buildSortChip('price_desc', 'Giá giảm dần'),
              ],
            ),
            const SizedBox(height: 24),

            // Price range
            const Text(
              'Khoảng giá',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _priceRanges.map((range) {
                final isSelected = _minPrice == range['min'] && _maxPrice == range['max'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _minPrice = range['min'] as double?;
                      _maxPrice = range['max'] as double?;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Text(
                      range['label'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Apply button
            ElevatedButton(
              onPressed: () {
                widget.onApply(
                  category: _selectedCategory,
                  minPrice: _minPrice,
                  maxPrice: _maxPrice,
                  sortOption: _sortOption,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Áp dụng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String? categoryId, String label) {
    final isSelected = _selectedCategory == categoryId;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = categoryId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(String? sortValue, String label) {
    final isSelected = _sortOption == sortValue;
    return GestureDetector(
      onTap: () => setState(() => _sortOption = sortValue),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
