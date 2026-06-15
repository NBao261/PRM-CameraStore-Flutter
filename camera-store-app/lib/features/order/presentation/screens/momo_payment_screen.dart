import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/config/app_config.dart';
import '../../domain/entities/order_entity.dart';

class MoMoPaymentScreen extends StatefulWidget {
  final OrderEntity order;

  const MoMoPaymentScreen({super.key, required this.order});

  @override
  State<MoMoPaymentScreen> createState() => _MoMoPaymentScreenState();
}

class _MoMoPaymentScreenState extends State<MoMoPaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            // Check if the URL is the redirect URL from MoMo
            if (request.url.contains('payment-result')) {
              _handlePaymentResult(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.order.payUrl!));
  }

  Future<void> _handlePaymentResult(String url) async {
    final uri = Uri.parse(url);
    final resultCode = uri.queryParameters['resultCode'];

    if (resultCode == '0') {
      try {
        // Since MoMo IPN can't reach localhost, we sync via frontend callback
        final callbackUrl = Uri.parse('${AppConfig.apiBaseUrl}/payment/momo/callback?${uri.query}');
        final response = await http.get(callbackUrl);
        
        if (mounted) {
          if (response.statusCode == 200) {
            Navigator.of(context).pushReplacementNamed(
              AppRouter.orderSuccess,
              arguments: widget.order,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Lỗi cập nhật trạng thái đơn hàng trên máy chủ')),
            );
            Navigator.of(context).pop();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi kết nối máy chủ: $e')),
          );
          Navigator.of(context).pop();
        }
      }
    } else {
      // Failed or canceled
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thanh toán thất bại hoặc đã bị hủy'),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.of(context).pop(); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán MoMo'),
        backgroundColor: const Color(0xFFA50064), // MoMo pink color
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFA50064)),
            ),
        ],
      ),
    );
  }
}
