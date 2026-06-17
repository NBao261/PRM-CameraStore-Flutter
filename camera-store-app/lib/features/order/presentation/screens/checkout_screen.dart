import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../cart/presentation/bloc/cart_state.dart';
import '../../domain/entities/order_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedPayment = 'cod';

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'value': 'cod',
      'label': 'Thanh toán khi nhận hàng (COD)',
      'icon': Icons.local_shipping_outlined,
      'color': AppColors.success,
    },
    {
      'value': 'bank_transfer',
      'label': 'Chuyển khoản ngân hàng',
      'icon': Icons.account_balance_outlined,
      'color': AppColors.info,
    },
    {
      'value': 'e_wallet',
      'label': 'Ví điện tử (MoMo, ZaloPay)',
      'icon': Icons.wallet_outlined,
      'color': AppColors.accent,
    },
  ];

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState.user != null) {
      _nameController.text = authState.user!.fullName;
      _phoneController.text = authState.user!.phone ?? '';
      _addressController.text = authState.user!.address ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return '${formatted}đ';
  }

  void _submitOrder() {
    if (!_formKey.currentState!.validate()) return;

    final selectedProductIds =
        context.read<CartBloc>().state.selectedItemIds.toList();

    HapticFeedback.mediumImpact();
    context.read<OrderBloc>().add(
          OrderCreateRequested(
            shippingInfo: ShippingInfo(
              fullName: _nameController.text.trim(),
              phone: _phoneController.text.trim(),
              address: _addressController.text.trim(),
              note: _noteController.text.trim(),
            ),
            paymentMethod: _selectedPayment,
            productIds: selectedProductIds.isNotEmpty ? selectedProductIds : null,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state.status == OrderBlocStatus.created) {
          // Reload cart (now empty)
          context.read<CartBloc>().add(const CartLoadRequested());
          // Navigate to MoMo payment or Success
          if (state.createdOrder?.payUrl != null && state.createdOrder!.payUrl!.isNotEmpty) {
            Navigator.of(context).pushReplacementNamed(
              '/momo_payment',
              arguments: state.createdOrder,
            );
          } else {
            Navigator.of(context).pushReplacementNamed(
              AppRouter.orderSuccess,
              arguments: state.createdOrder,
            );
          }
        } else if (state.status == OrderBlocStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.errorMessage ?? 'Đặt hàng thất bại')),
                ],
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Thanh toán',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, orderState) {
            return Stack(
              children: [
                BlocBuilder<CartBloc, CartState>(
                  builder: (context, cartState) {
                    if (cartState.cart == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 140),
                      child: Column(
                        children: [
                          // ── Order Summary ──
                          _buildSection(
                            title: 'Đơn hàng của bạn',
                            icon: Icons.shopping_bag_outlined,
                            child: Column(
                              children: [
                                ...cartState.cart!.items
                                    .where((item) => cartState.selectedItemIds
                                        .contains(item.product.id))
                                    .map((item) {
                                  final effectivePrice =
                                      (item.product.salePrice ?? 0) > 0
                                          ? item.product.salePrice!
                                          : item.product.price;
                                  return _buildOrderItem(
                                    item.product.name,
                                    item.quantity,
                                    effectivePrice,
                                  );
                                }),
                                const Divider(height: 24),
                                _buildPriceRow('Tạm tính', cartState.selectedTotalAmount),
                                const SizedBox(height: 6),
                                _buildPriceRow('Phí vận chuyển', 0, isFree: true),
                                const Divider(height: 20),
                                _buildPriceRow(
                                  'Tổng cộng',
                                  cartState.selectedTotalAmount,
                                  isTotal: true,
                                ),
                              ],
                            ),
                          ),

                          // ── Shipping Info ──
                          _buildSection(
                            title: 'Thông tin giao hàng',
                            icon: Icons.location_on_outlined,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  _buildTextField(
                                    controller: _nameController,
                                    label: 'Họ tên người nhận',
                                    hint: 'Nguyễn Văn A',
                                    icon: Icons.person_outline,
                                    validator: (v) => v == null || v.trim().isEmpty
                                        ? 'Vui lòng nhập tên người nhận'
                                        : null,
                                  ),
                                  const SizedBox(height: 14),
                                  _buildTextField(
                                    controller: _phoneController,
                                    label: 'Số điện thoại',
                                    hint: '0912 345 678',
                                    icon: Icons.phone_outlined,
                                    keyboardType: TextInputType.phone,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Vui lòng nhập số điện thoại';
                                      }
                                      final cleaned = v.replaceAll(RegExp(r'\s+'), '');
                                      if (!RegExp(r'^(0|\+84)[0-9]{9,10}$')
                                          .hasMatch(cleaned)) {
                                        return 'Số điện thoại không hợp lệ';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  _buildTextField(
                                    controller: _addressController,
                                    label: 'Địa chỉ giao hàng',
                                    hint: '123 Đường ABC, Quận 1, TP.HCM',
                                    icon: Icons.home_outlined,
                                    maxLines: 2,
                                    validator: (v) => v == null || v.trim().isEmpty
                                        ? 'Vui lòng nhập địa chỉ giao hàng'
                                        : null,
                                  ),
                                  const SizedBox(height: 14),
                                  _buildTextField(
                                    controller: _noteController,
                                    label: 'Ghi chú (tùy chọn)',
                                    hint: 'Giao giờ hành chính, gọi trước khi giao...',
                                    icon: Icons.note_outlined,
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ── Payment Method ──
                          _buildSection(
                            title: 'Phương thức thanh toán',
                            icon: Icons.payment_outlined,
                            child: Column(
                              children: _paymentMethods
                                  .map((method) => _buildPaymentOption(method))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // ── Loading Overlay ──
                if (orderState.status == OrderBlocStatus.loading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.4),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 30,
                                ),
                              ],
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  color: AppColors.accent,
                                  strokeWidth: 3,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'Đang tạo đơn hàng...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),

        // ── Bottom Bar ──
        bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
          builder: (context, cartState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tổng thanh toán',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatPrice(cartState.selectedTotalAmount),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: BlocBuilder<OrderBloc, OrderState>(
                      builder: (context, orderState) {
                        final isLoading =
                            orderState.status == OrderBlocStatus.loading;
                        return Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.accent, AppColors.accentDark],
                            ),
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withOpacity(0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _submitOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle_outline,
                                    size: 20, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  isLoading ? 'Đang xử lý...' : 'Đặt hàng',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Section Builder ──
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: AppColors.accent),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }

  // ── Order Item ──
  Widget _buildOrderItem(String name, int qty, double price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'x$qty',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatPrice(price * qty),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Price Row ──
  Widget _buildPriceRow(String label, double amount,
      {bool isTotal = false, bool isFree = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          isFree ? 'Miễn phí' : _formatPrice(amount),
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
            color: isFree
                ? AppColors.success
                : (isTotal ? AppColors.accent : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  // ── Text Field ──
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textHint.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        filled: true,
        fillColor: AppColors.surfaceDim,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  // ── Payment Option ──
  Widget _buildPaymentOption(Map<String, dynamic> method) {
    final isSelected = _selectedPayment == method['value'];
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedPayment = method['value']);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? (method['color'] as Color).withOpacity(0.08)
              : AppColors.surfaceDim,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (method['color'] as Color)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (method['color'] as Color).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                method['icon'] as IconData,
                size: 22,
                color: method['color'] as Color,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                method['label'] as String,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? (method['color'] as Color)
                      : AppColors.textHint,
                  width: isSelected ? 6 : 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
