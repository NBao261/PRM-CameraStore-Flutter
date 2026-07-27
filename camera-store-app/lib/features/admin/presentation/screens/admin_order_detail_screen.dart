import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/admin_order_bloc.dart';
import '../bloc/admin_order_event.dart';
import '../bloc/admin_order_state.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const AdminOrderDetailScreen({super.key, required this.order});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  late Map<String, dynamic> _order;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  String _formatCurrency(num value) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(value)}đ';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFFBBC04);
      case 'confirmed':
        return const Color(0xFF4285F4);
      case 'shipping':
        return const Color(0xFFFF9800);
      case 'delivered':
        return const Color(0xFF34A853);
      case 'cancelled':
        return const Color(0xFFEA4335);
      default:
        return AppColors.textHint;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'shipping':
        return 'Đang giao';
      case 'delivered':
        return 'Đã giao';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminOrderBloc, AdminOrderState>(
      listenWhen: (prev, curr) {
        // Only react to this screen's order update
        if (curr.updatedOrder != null &&
            curr.updatedOrder!['_id'] == _order['_id'] &&
            curr.updatedOrder != prev.updatedOrder) {
          return true;
        }
        if (curr.status == AdminOrderStatus.error &&
            curr.errorMessage != null &&
            curr.errorMessage != prev.errorMessage) {
          return true;
        }
        return false;
      },
      listener: (context, state) {
        if (state.updatedOrder != null &&
            state.updatedOrder!['_id'] == _order['_id']) {
          // Update local order data so UI re-renders with new status/history
          setState(() {
            _order = state.updatedOrder!;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '✅ Đã chuyển sang: ${_getStatusLabel(state.updatedOrder!['status'] as String? ?? '')}'),
              backgroundColor: const Color(0xFF34A853),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        if (state.status == AdminOrderStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final user = _order['user'] as Map?;
    final items = _order['items'] as List? ?? [];
    final shippingInfo = _order['shippingInfo'] as Map? ?? {};
    final status = _order['status'] as String? ?? '';
    final statusHistory = _order['statusHistory'] as List? ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Đơn #${(_order['_id'] as String? ?? '').substring(0, 8)}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status Badge ─────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: _getStatusColor(status).withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 14, color: _getStatusColor(status)),
                  const SizedBox(width: 10),
                  Text(
                    _getStatusLabel(status),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _getStatusColor(status),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Order Progress Stepper ────────────────────
            _buildProgressStepper(status),
            const SizedBox(height: 16),

            // ── Customer Info ────────────────────────────
            _SectionCard(
              title: 'Thông tin khách hàng',
              icon: Icons.person_outline,
              child: Column(
                children: [
                  _InfoRow(label: 'Họ tên', value: user?['fullName'] ?? 'N/A'),
                  _InfoRow(label: 'Email', value: user?['email'] ?? 'N/A'),
                  _InfoRow(label: 'SĐT', value: user?['phone'] ?? 'N/A'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Shipping Info ────────────────────────────
            _SectionCard(
              title: 'Thông tin giao hàng',
              icon: Icons.local_shipping_outlined,
              child: Column(
                children: [
                  _InfoRow(
                      label: 'Người nhận',
                      value: shippingInfo['fullName'] ?? 'N/A'),
                  _InfoRow(label: 'SĐT', value: shippingInfo['phone'] ?? 'N/A'),
                  _InfoRow(
                      label: 'Địa chỉ',
                      value: shippingInfo['address'] ?? 'N/A'),
                  if (shippingInfo['note'] != null &&
                      (shippingInfo['note'] as String).isNotEmpty)
                    _InfoRow(label: 'Ghi chú', value: shippingInfo['note']),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Products ─────────────────────────────────
            _SectionCard(
              title: 'Sản phẩm (${items.length})',
              icon: Icons.shopping_bag_outlined,
              child: Column(
                children: items.map<Widget>((item) {
                  final i = Map<String, dynamic>.from(item as Map);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            i['imageUrl'] ?? '',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 50,
                              height: 50,
                              color: AppColors.surfaceDim,
                              child: const Icon(Icons.image,
                                  color: AppColors.textHint),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                i['name'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'x${i['quantity']}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatCurrency(i['price'] ?? 0),
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // ── Total ────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _InfoRow(
                      label: 'Tạm tính',
                      value: _formatCurrency(_order['subtotal'] ?? 0)),
                  _InfoRow(
                      label: 'Phí vận chuyển',
                      value: _formatCurrency(_order['shippingFee'] ?? 0)),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng cộng',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      Text(
                        _formatCurrency(_order['total'] ?? 0),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Status Timeline ──────────────────────────
            _SectionCard(
              title: 'Lịch sử trạng thái',
              icon: Icons.history,
              child: statusHistory.isEmpty
                  ? const Text('Chưa có lịch sử',
                      style: TextStyle(color: AppColors.textHint))
                  : Column(
                      children: statusHistory.map<Widget>((h) {
                        final hist = Map<String, dynamic>.from(h as Map);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(Icons.circle,
                                  size: 10,
                                  color: _getStatusColor(
                                      hist['status'] as String? ?? '')),
                              const SizedBox(width: 10),
                              Text(
                                _getStatusLabel(
                                    hist['status'] as String? ?? ''),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              const Spacer(),
                              Text(
                                _formatDate(hist['changedAt'] as String?),
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.textHint),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 24),

            // ── Action Buttons ───────────────────────────
            _buildActionButtons(context, status),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStepper(String currentStatus) {
    const steps = ['pending', 'confirmed', 'shipping', 'delivered'];
    final stepLabels = {
      'pending': 'Chờ xác nhận',
      'confirmed': 'Đã xác nhận',
      'shipping': 'Đang giao',
      'delivered': 'Đã giao',
    };
    final stepIcons = {
      'pending': Icons.hourglass_empty_rounded,
      'confirmed': Icons.check_circle_outline_rounded,
      'shipping': Icons.local_shipping_outlined,
      'delivered': Icons.verified_rounded,
    };

    if (currentStatus == 'cancelled') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFEA4335).withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: const Color(0xFFEA4335).withValues(alpha: 0.25)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel_outlined, color: Color(0xFFEA4335)),
            SizedBox(width: 10),
            Text('Đơn hàng đã bị hủy',
                style: TextStyle(
                    color: Color(0xFFEA4335), fontWeight: FontWeight.w700)),
          ],
        ),
      );
    }

    final currentIndex = steps.indexOf(currentStatus);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line
            final stepIndex = i ~/ 2;
            final isCompleted = stepIndex < currentIndex;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 3,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.primary
                      : AppColors.surfaceDim,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }

          final stepIndex = i ~/ 2;
          final stepKey = steps[stepIndex];
          final isCompleted = stepIndex < currentIndex;
          final isCurrent = stepIndex == currentIndex;
          final color = isCompleted || isCurrent
              ? AppColors.primary
              : AppColors.textHint;

          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.primary
                      : isCurrent
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.surfaceDim,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted || isCurrent
                        ? AppColors.primary
                        : AppColors.surfaceDim,
                    width: 2,
                  ),
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_rounded
                      : stepIcons[stepKey]!,
                  size: 18,
                  color: isCompleted
                      ? Colors.white
                      : isCurrent
                          ? AppColors.primary
                          : AppColors.textHint,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                stepLabels[stepKey]!,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight:
                      isCurrent ? FontWeight.w700 : FontWeight.w400,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, String status) {
    final bloc = context.read<AdminOrderBloc>();
    final orderId = _order['_id'] as String? ?? '';

    if (status == 'delivered' || status == 'cancelled') {
      return const SizedBox.shrink();
    }

    return BlocBuilder<AdminOrderBloc, AdminOrderState>(
      builder: (context, state) {
        final isUpdating = state.status == AdminOrderStatus.updating;

        return Column(
          children: [
            if (status == 'pending') ...[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: isUpdating
                      ? null
                      : () => bloc.add(AdminOrderUpdateStatus(
                            orderId: orderId,
                            newStatus: 'confirmed',
                          )),
                  icon: isUpdating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    isUpdating ? 'Đang cập nhật...' : 'Xác nhận đơn hàng',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            if (status == 'confirmed')
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: isUpdating
                      ? null
                      : () => bloc.add(AdminOrderUpdateStatus(
                            orderId: orderId,
                            newStatus: 'shipping',
                          )),
                  icon: isUpdating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.local_shipping_outlined),
                  label: Text(
                    isUpdating ? 'Đang cập nhật...' : 'Bắt đầu giao hàng',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            if (status == 'shipping')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      color: Color(0xFF8B5CF6),
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Đang giao hàng — Khách hàng sẽ tự xác nhận đã nhận hàng.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8B5CF6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (status != 'shipping') ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: isUpdating
                      ? null
                      : () => _showCancelDialog(context, bloc, orderId),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Hủy đơn hàng',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEA4335),
                    side: const BorderSide(color: Color(0xFFEA4335)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void _showCancelDialog(
      BuildContext context, AdminOrderBloc bloc, String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận hủy đơn'),
        content:
            const Text('Bạn có chắc chắn muốn hủy đơn hàng này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              bloc.add(AdminOrderUpdateStatus(
                orderId: orderId,
                newStatus: 'cancelled',
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEA4335),
              foregroundColor: Colors.white,
            ),
            child: const Text('Hủy đơn'),
          ),
        ],
      ),
    );
  }
}

// ── Reusable Widgets ────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
