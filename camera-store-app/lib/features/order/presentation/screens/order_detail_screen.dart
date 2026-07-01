import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/order_entity.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<OrderBloc>()
        .add(OrderDetailLoadRequested(widget.orderId));
  }

  Future<void> _onRefresh() async {
    context
        .read<OrderBloc>()
        .add(OrderDetailLoadRequested(widget.orderId));
  }

  String _formatPrice(double price) {
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return '${formatted}đ';
  }

  String _paymentLabel(String method) {
    switch (method) {
      case 'cod':
        return 'Thanh toán khi nhận hàng (COD)';
      case 'bank_transfer':
        return 'Chuyển khoản ngân hàng';
      case 'e_wallet':
        return 'Ví điện tử';
      default:
        return method;
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return const Color(0xFFF59E0B);
      case OrderStatus.confirmed:
        return const Color(0xFF3B82F6);
      case OrderStatus.shipping:
        return const Color(0xFF8B5CF6);
      case OrderStatus.delivered:
        return const Color(0xFF10B981);
      case OrderStatus.cancelled:
        return const Color(0xFFEF4444);
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusDescription(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Đơn hàng đang chờ xác nhận từ hệ thống.';
      case OrderStatus.confirmed:
        return 'Người bán đang chuẩn bị hàng cho bạn.';
      case OrderStatus.shipping:
        return 'Đơn hàng đã được giao cho đơn vị vận chuyển.';
      case OrderStatus.delivered:
        return 'Giao hàng thành công. Cảm ơn bạn đã mua sắm!';
      case OrderStatus.cancelled:
        return 'Đơn hàng đã bị hủy.';
      default:
        return '';
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.hourglass_empty_rounded;
      case OrderStatus.confirmed:
        return Icons.inventory_2_outlined;
      case OrderStatus.shipping:
        return Icons.local_shipping_outlined;
      case OrderStatus.delivered:
        return Icons.check_circle_outline_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
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
                'Chi tiết đơn hàng',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: -0.5,
                  color: Colors.white,
                ),
              ),
              backgroundColor: AppColors.primary.withValues(alpha: 0.85),
              surfaceTintColor: Colors.transparent,
              iconTheme: const IconThemeData(color: Colors.white),
              elevation: 0,
              centerTitle: true,
            ),
          ),
        ),
      ),
      body: BlocConsumer<OrderBloc, OrderState>(
        listenWhen: (previous, current) {
          // Listen for transition from loading to loaded if we were cancelling
          if (previous.status == OrderBlocStatus.loading &&
              current.status == OrderBlocStatus.loaded &&
              current.currentOrder?.status == OrderStatus.cancelled) {
            return true;
          }
          // Listen for errors
          if (previous.status == OrderBlocStatus.loading &&
              current.status == OrderBlocStatus.error) {
            return true;
          }
          return false;
        },
        listener: (context, state) {
          if (state.status == OrderBlocStatus.loaded &&
              state.currentOrder?.status == OrderStatus.cancelled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Hủy đơn hàng thành công'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state.status == OrderBlocStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Có lỗi xảy ra'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == OrderBlocStatus.loading ||
              state.currentOrder == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state.status == OrderBlocStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? 'Không thể tải chi tiết đơn hàng',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _onRefresh,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final order = state.currentOrder!;
          final statusColor = _getStatusColor(order.status);
          final shortId = order.id.substring(order.id.length - 8).toUpperCase();

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + 80,
                20,
                MediaQuery.of(context).padding.bottom + 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Status Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          statusColor,
                          statusColor.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getStatusIcon(order.status),
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.statusLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getStatusDescription(order.status),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Order Header info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mã đơn: #$shortId',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm')
                            .format(order.createdAt),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2. Shipping Address
                  _buildSectionTitle('Địa chỉ nhận hàng'),
                  const SizedBox(height: 12),
                  _buildCardContainer(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.shippingInfo.fullName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                order.shippingInfo.phone,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                order.shippingInfo.address,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                              if (order.shippingInfo.note != null &&
                                  order.shippingInfo.note!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Ghi chú: ${order.shippingInfo.note}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textHint,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Payment Method
                  _buildSectionTitle('Phương thức thanh toán'),
                  const SizedBox(height: 12),
                  _buildCardContainer(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.payment_outlined,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _paymentLabel(order.paymentMethod),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. Items List
                  _buildSectionTitle('Sản phẩm (${order.items.length})'),
                  const SizedBox(height: 12),
                  _buildCardContainer(
                    padding: EdgeInsets.zero,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: order.items.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        color: AppColors.divider,
                      ),
                      itemBuilder: (context, index) {
                        final item = order.items[index];
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: item.imageUrl.isNotEmpty
                                    ? Image.network(
                                        item.imageUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 60,
                                          height: 60,
                                          color: AppColors.background,
                                          child: const Icon(
                                            Icons.camera_alt_outlined,
                                            color: AppColors.textHint,
                                            size: 24,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width: 60,
                                        height: 60,
                                        color: AppColors.background,
                                        child: const Icon(
                                          Icons.camera_alt_outlined,
                                          color: AppColors.textHint,
                                          size: 24,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatPrice(item.price),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.accent,
                                          ),
                                        ),
                                        Text(
                                          'x${item.quantity}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textSecondary,
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
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 5. Summary
                  _buildSectionTitle('Tổng cộng'),
                  const SizedBox(height: 12),
                  _buildCardContainer(
                    child: Column(
                      children: [
                        _buildSummaryRow(
                          'Tạm tính',
                          _formatPrice(order.subtotal),
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryRow(
                          'Phí vận chuyển',
                          order.shippingFee == 0
                              ? 'Miễn phí'
                              : _formatPrice(order.shippingFee),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1, color: AppColors.divider),
                        ),
                        _buildSummaryRow(
                          'Thành tiền',
                          _formatPrice(order.total),
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                  if (order.status == OrderStatus.pending) ...[
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                title: const Text('Hủy đơn hàng'),
                                content: const Text('Bạn có chắc chắn muốn hủy đơn hàng này không? Hành động này không thể hoàn tác.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(dialogContext).pop(),
                                    child: const Text('Không'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop();
                                      context.read<OrderBloc>().add(OrderCancelRequested(order.id));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.error,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Có, hủy đơn'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Hủy đơn hàng',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildCardContainer({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 15,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
            color: isTotal ? AppColors.accent : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
