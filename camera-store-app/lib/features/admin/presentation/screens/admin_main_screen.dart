import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/socket_service.dart';
import '../bloc/admin_chat_bloc.dart';
import '../bloc/admin_chat_event.dart';
import '../bloc/admin_chat_state.dart';
import 'admin_dashboard_screen.dart';
import 'admin_order_list_screen.dart';
import 'admin_chat_list_screen.dart';
import '../../../notification/presentation/screens/notification_screen.dart';
import '../../../notification/presentation/bloc/notification_bloc.dart';
import '../../../notification/presentation/bloc/notification_event.dart';
import '../../../notification/presentation/bloc/notification_state.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AdminDashboardScreen(),
    AdminOrderListScreen(),
    AdminChatListScreen(),
    NotificationScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Socket is already connected via main app, just join admin room
    SocketService().joinAdminRoom();
    // Load notifications to show badge immediately
    context.read<NotificationBloc>().add(NotificationLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            if (index == 2) {
              context.read<AdminChatBloc>().add(AdminChatMarkAsRead());
            }
          },
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textHint,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Đơn hàng',
            ),
            BottomNavigationBarItem(
              icon: BlocBuilder<AdminChatBloc, AdminChatState>(
                builder: (context, state) {
                  return Badge(
                    isLabelVisible: state.unreadCount > 0,
                    label: Text(state.unreadCount.toString()),
                    child: const Icon(Icons.chat_outlined),
                  );
                },
              ),
              activeIcon: const Icon(Icons.chat),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
                  final unreadCount = state.notifications.where((n) => !n.isRead).length;
                  return Badge(
                    isLabelVisible: unreadCount > 0,
                    label: Text(unreadCount.toString()),
                    child: const Icon(Icons.notifications_none_outlined),
                  );
                },
              ),
              activeIcon: const Icon(Icons.notifications),
              label: 'Thông báo',
            ),
          ],
        ),
      ),
    );
  }
}
