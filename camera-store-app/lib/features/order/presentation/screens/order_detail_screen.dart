import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/order_entity.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';
import '../../../../core/routes/app_router.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  /// Set of product IDs that user has already reviewed for this order
  final Set<String> _reviewedProducts = {};
  /// Map productId → rating the user gave
  final Map<String, int> _reviewRatings = {};

  @override
  void initState() {
    super.initState();
    context
        .read<OrderBloc>()
        .add(OrderDetailLoadRequested(widget.orderId));
    _loadExistingReviews();
  }

  Future<void> _loadExistingReviews() async {
    try {
      final apiClient = ApiClient();
      final response = await apiClient.dio.get('/reviews/order/${widget.orderId}');
      final data = response.data['data'] as List? ?? [];
      if (mounted) {
        setState(() {
          for (final r in data) {
            final pid = r['product'] as String? ?? '';
            if (pid.isNotEmpty) {
              _reviewedProducts.add(pid);
              _reviewRatings[pid] = (r['rating'] as num?)?.toInt() ?? 5;
            }
          }
        });
      }
    } catch (_) {
      // silently ignore — button stays active as fallback
    }
  }

  Future<void> _onRefresh() async {
    context
        .read<OrderBloc>()
        .add(OrderDetailLoadRequested(widget.orderId));
    _loadExistingReviews();
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
      appBar: AppBar(
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
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
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

                  // ── Order Tracking Timeline ──
                  if (order.status != OrderStatus.cancelled)
                    _buildTrackingTimeline(order),
                  if (order.status == OrderStatus.cancelled)
                    _buildCancelledBanner(order),
                  const SizedBox(height: 20),

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
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: order.items.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        color: AppColors.divider,
                      ),
                      itemBuilder: (context, index) {
                        final item = order.items[index];
                        return InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.productDetail,
                              arguments: item.productId,
                            );
                          },
                          child: Padding(
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
                        if (order.discountAmount > 0) ...[
                          const SizedBox(height: 12),
                          _buildSummaryRow(
                            'Giảm giá (${order.couponCode ?? ""})',
                            '-${_formatPrice(order.discountAmount)}',
                            isDiscount: true,
                          ),
                        ],
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
                  // ── Review Button (only for delivered orders) ──
                  if (order.status == OrderStatus.delivered) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle('Đánh giá sản phẩm'),
                    const SizedBox(height: 12),
                    _buildCardContainer(
                      child: Column(
                        children: order.items.map((item) {
                          final isReviewed = _reviewedProducts.contains(item.productId);
                          final rating = _reviewRatings[item.productId];
                          return InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRouter.productDetail,
                                arguments: item.productId,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: item.imageUrl.isNotEmpty
                                      ? Image.network(
                                          item.imageUrl,
                                          width: 44,
                                          height: 44,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            width: 44,
                                            height: 44,
                                            color: AppColors.background,
                                            child: const Icon(Icons.camera_alt_outlined, size: 18, color: AppColors.textHint),
                                          ),
                                        )
                                      : Container(
                                          width: 44,
                                          height: 44,
                                          color: AppColors.background,
                                          child: const Icon(Icons.camera_alt_outlined, size: 18, color: AppColors.textHint),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (isReviewed)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF10B981)),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Đã đánh giá',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF10B981),
                                          ),
                                        ),
                                        if (rating != null) ...[
                                          const SizedBox(width: 4),
                                          Icon(Icons.star_rounded, size: 14, color: Colors.amber.shade600),
                                          Text(
                                            '$rating',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.amber.shade700,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  )
                                else
                                  ElevatedButton.icon(
                                    onPressed: () => _showReviewDialog(order.id, item.productId, item.name),
                                    icon: const Icon(Icons.rate_review_outlined, size: 16),
                                    label: const Text('Đánh giá', style: TextStyle(fontSize: 13)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.accent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      minimumSize: const Size(0, 34),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                        }).toList(),
                      ),
                    ),
                  ],
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
                  // ── Confirm Received (shipping → delivered) ──
                  if (order.status == OrderStatus.shipping) ...[
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: const Row(
                                  children: [
                                    Icon(Icons.check_circle_outline_rounded,
                                        color: Color(0xFF10B981)),
                                    SizedBox(width: 10),
                                    Text('Xác nhận nhận hàng'),
                                  ],
                                ),
                                content: const Text(
                                  'Bạn xác nhận đã nhận được hàng?\n\nSau khi xác nhận, bạn có thể đánh giá sản phẩm.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(dialogContext).pop(),
                                    child: const Text('Chưa nhận'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.of(dialogContext).pop();
                                      // Call confirm-received API
                                      try {
                                        final apiClient = ApiClient();
                                        await apiClient.dio.put('/orders/${order.id}/confirm-received');
                                        // Reload order
                                        if (context.mounted) {
                                          context.read<OrderBloc>().add(
                                            OrderDetailLoadRequested(order.id),
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Row(
                                                children: [
                                                  const Icon(Icons.check_circle, color: Colors.white, size: 18),
                                                  const SizedBox(width: 8),
                                                  const Expanded(child: Text('Xác nhận nhận hàng thành công!')),
                                                ],
                                              ),
                                              backgroundColor: Color(0xFF10B981),
                                            ),
                                          );
                                        }
                                      } on DioException catch (e) {
                                        final msg = (e.response?.data is Map)
                                            ? e.response?.data['message'] as String? ?? 'Có lỗi xảy ra'
                                            : 'Lỗi kết nối server';
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(msg),
                                              backgroundColor: AppColors.error,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF10B981),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text('Đã nhận hàng'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.done_all_rounded),
                        label: const Text(
                          'Đã nhận hàng',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
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

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, bool isDiscount = false}) {
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
            color: isDiscount
                ? AppColors.error
                : (isTotal ? AppColors.accent : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  void _showReviewDialog(String orderId, String productId, String productName) {
    int selectedRating = 5;
    final commentController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(dialogContext).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Đánh giá: $productName',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  // Star selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setModalState(() => selectedRating = index + 1);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            index < selectedRating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 40,
                            color: index < selectedRating
                                ? Colors.amber.shade600
                                : AppColors.textHint,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  // Comment input
                  TextFormField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Viết nhận xét của bạn (không bắt buộc)',
                      hintStyle: TextStyle(
                        color: AppColors.textHint.withOpacity(0.7),
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              setModalState(() => isSubmitting = true);
                              try {
                                final apiClient = ApiClient();
                                await apiClient.dio.post('/reviews', data: {
                                  'orderId': orderId,
                                  'productId': productId,
                                  'rating': selectedRating,
                                  'comment': commentController.text.trim(),
                                });
                                if (dialogContext.mounted) {
                                  Navigator.of(dialogContext).pop();
                                }
                                if (mounted) {
                                  setState(() {
                                    _reviewedProducts.add(productId);
                                    _reviewRatings[productId] = selectedRating;
                                  });
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                    const SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.check_circle, color: Colors.white, size: 18),
                                          SizedBox(width: 8),
                                          Expanded(child: Text('Đánh giá thành công!')),
                                        ],
                                      ),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                }
                              } on DioException catch (e) {
                                final msg = (e.response?.data is Map)
                                    ? e.response?.data['message'] as String? ?? 'Không thể gửi đánh giá'
                                    : 'Lỗi kết nối server';
                                if (mounted) {
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                    SnackBar(
                                      content: Text(msg),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              } finally {
                                if (dialogContext.mounted) {
                                  setModalState(() => isSubmitting = false);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Gửi đánh giá',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// 4-step tracking stepper (pending → confirmed → shipping → delivered)
  Widget _buildTrackingTimeline(OrderEntity order) {
    final steps = [
      _TrackingStep(
        status: OrderStatus.pending,
        icon: Icons.hourglass_empty_rounded,
        label: 'Chờ xác nhận',
        color: const Color(0xFFF59E0B),
      ),
      _TrackingStep(
        status: OrderStatus.confirmed,
        icon: Icons.inventory_2_outlined,
        label: 'Đã xác nhận',
        color: const Color(0xFF3B82F6),
      ),
      _TrackingStep(
        status: OrderStatus.shipping,
        icon: Icons.local_shipping_outlined,
        label: 'Đang giao hàng',
        color: const Color(0xFF8B5CF6),
      ),
      _TrackingStep(
        status: OrderStatus.delivered,
        icon: Icons.check_circle_outline_rounded,
        label: 'Đã giao',
        color: const Color(0xFF10B981),
      ),
    ];

    // Map status → step index
    final statusOrder = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.shipping,
      OrderStatus.delivered,
    ];
    final currentIdx = statusOrder.indexOf(order.status);

    // Build a map from status → changedAt from history
    final historyMap = <OrderStatus, DateTime>{};
    for (final entry in order.statusHistory) {
      historyMap[entry.status] = entry.changedAt;
    }

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Theo dõi đơn hàng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(steps.length, (i) {
            final step = steps[i];
            final isDone = i < currentIdx;
            final isCurrent = i == currentIdx;
            final isPending = i > currentIdx;
            final ts = historyMap[step.status];

            final dotColor = isDone
                ? const Color(0xFF10B981)
                : isCurrent
                    ? step.color
                    : AppColors.divider;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: dot + line
                SizedBox(
                  width: 32,
                  child: Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isPending
                              ? AppColors.background
                              : dotColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isPending ? AppColors.divider : dotColor,
                            width: isCurrent ? 2.5 : 1.5,
                          ),
                        ),
                        child: Icon(
                          isDone ? Icons.check_rounded : step.icon,
                          size: 16,
                          color: isPending ? AppColors.textHint : dotColor,
                        ),
                      ),
                      if (i < steps.length - 1)
                        Container(
                          width: 2,
                          height: 36,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: isDone
                              ? const Color(0xFF10B981).withValues(alpha: 0.4)
                              : AppColors.divider,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Right: label + timestamp
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 6,
                      bottom: i < steps.length - 1 ? 28 : 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isCurrent
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isPending
                                ? AppColors.textHint
                                : isCurrent
                                    ? step.color
                                    : AppColors.textPrimary,
                          ),
                        ),
                        if (ts != null) ...
                          [
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('dd/MM/yyyy HH:mm').format(ts),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textHint,
                              ),
                            ),
                          ],
                        if (isCurrent && ts == null)
                          const Text(
                            'Đang xử lý...',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textHint,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCancelledBanner(OrderEntity order) {
    final cancelEntry = order.statusHistory
        .where((e) => e.status == OrderStatus.cancelled)
        .lastOrNull;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cancel_outlined,
              color: AppColors.error,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Đơn hàng đã bị hủy',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.error,
                  ),
                ),
                if (cancelEntry != null)
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(cancelEntry.changedAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingStep {
  final OrderStatus status;
  final IconData icon;
  final String label;
  final Color color;

  const _TrackingStep({
    required this.status,
    required this.icon,
    required this.label,
    required this.color,
  });
}
