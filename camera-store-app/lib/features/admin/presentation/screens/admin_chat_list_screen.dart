import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/admin_chat_bloc.dart';
import '../bloc/admin_chat_event.dart';
import '../bloc/admin_chat_state.dart';
import 'admin_chat_detail_screen.dart';

class AdminChatListScreen extends StatefulWidget {
  const AdminChatListScreen({super.key});

  @override
  State<AdminChatListScreen> createState() => _AdminChatListScreenState();
}

class _AdminChatListScreenState extends State<AdminChatListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminChatBloc>().add(const AdminChatLoadConversations());
  }

  String _timeAgo(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inMinutes < 1) return 'Vừa xong';
      if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
      if (diff.inHours < 24) return '${diff.inHours} giờ trước';
      if (diff.inDays < 7) return '${diff.inDays} ngày trước';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Chat khách hàng',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context
                .read<AdminChatBloc>()
                .add(const AdminChatLoadConversations()),
          ),
        ],
      ),
      body: BlocBuilder<AdminChatBloc, AdminChatState>(
        builder: (context, state) {
          if (state.status == AdminChatStatus.loading &&
              state.conversations.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state.conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 64,
                      color: AppColors.textHint.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có cuộc trò chuyện nào',
                    style: TextStyle(
                        color: AppColors.textHint, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<AdminChatBloc>()
                  .add(const AdminChatLoadConversations());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.conversations.length,
              itemBuilder: (context, index) {
                final conv = state.conversations[index];
                return _buildConversationItem(conv);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildConversationItem(Map<String, dynamic> conv) {
    final user = conv['user'] as Map? ?? {};
    final lastMessage = conv['lastMessage'] as String? ?? '';
    final lastSenderRole = conv['lastSenderRole'] as String? ?? '';
    final conversationId = conv['conversationId'] as String? ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<AdminChatBloc>(),
              child: AdminChatDetailScreen(
                conversationId: conversationId,
                userName: user['fullName'] as String? ?? 'Khách hàng',
              ),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.info.withValues(alpha: 0.12),
              child: Text(
                (user['fullName'] as String? ?? 'U')
                    .substring(0, 1)
                    .toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.info,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['fullName'] as String? ?? 'Khách hàng',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastSenderRole == 'support'
                        ? 'Bạn: $lastMessage'
                        : lastMessage,
                    style: TextStyle(
                      fontSize: 13,
                      color: lastSenderRole == 'user'
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: lastSenderRole == 'user'
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _timeAgo(conv['lastMessageAt'] as String?),
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textHint),
                ),
                const SizedBox(height: 6),
                Text(
                  '${conv['messageCount'] ?? 0}',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textHint),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
