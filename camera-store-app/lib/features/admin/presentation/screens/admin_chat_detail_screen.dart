import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/admin_chat_bloc.dart';
import '../bloc/admin_chat_event.dart';
import '../bloc/admin_chat_state.dart';

class AdminChatDetailScreen extends StatefulWidget {
  final String conversationId;
  final String userName;

  const AdminChatDetailScreen({
    super.key,
    required this.conversationId,
    required this.userName,
  });

  @override
  State<AdminChatDetailScreen> createState() => _AdminChatDetailScreenState();
}

class _AdminChatDetailScreenState extends State<AdminChatDetailScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<AdminChatBloc>().add(
          AdminChatLoadMessages(conversationId: widget.conversationId),
        );
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    context.read<AdminChatBloc>().add(
          AdminChatSendMessage(
            conversationId: widget.conversationId,
            content: text,
          ),
        );
    _msgController.clear();
    _focusNode.requestFocus();
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white24,
              child: Text(
                widget.userName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 14),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.userName,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ── Messages ──────────────────────────────────
          Expanded(
            child: BlocConsumer<AdminChatBloc, AdminChatState>(
              listenWhen: (prev, curr) =>
                  curr.messages.length > prev.messages.length,
              listener: (context, state) => _scrollToBottom(),
              builder: (context, state) {
                if (state.status == AdminChatStatus.loading &&
                    state.messages.isEmpty) {
                  return const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (state.messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Chưa có tin nhắn nào',
                      style: TextStyle(color: AppColors.textHint),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: 12),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final msg = state.messages[index];
                    final isAdmin =
                        (msg['senderRole'] as String?) == 'support';
                    return _buildBubble(msg, isAdmin);
                  },
                );
              },
            ),
          ),

          // ── Error banner ──────────────────────────────
          BlocBuilder<AdminChatBloc, AdminChatState>(
            buildWhen: (prev, curr) => prev.status != curr.status,
            builder: (context, state) {
              if (state.status == AdminChatStatus.error &&
                  state.errorMessage != null) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  color: AppColors.errorLight,
                  child: Text(
                    state.errorMessage!,
                    style: const TextStyle(
                        color: AppColors.error, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // ── Input bar ─────────────────────────────────
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildBubble(Map<String, dynamic> msg, bool isAdmin) {
    final sender = msg['sender'] as Map?;
    final content = msg['content'] as String? ?? '';
    final time = _formatTime(msg['createdAt'] as String?);
    final senderName = sender?['fullName'] as String? ?? widget.userName;
    final senderAvatar = sender?['avatar'] as String?;
    final initial = senderName.isNotEmpty ? senderName[0].toUpperCase() : '?';

    Widget userAvatar() {
      if (senderAvatar != null && senderAvatar.isNotEmpty) {
        return CircleAvatar(
          radius: 16,
          backgroundImage: NetworkImage(senderAvatar),
          onBackgroundImageError: (_, __) {},
          backgroundColor: AppColors.info.withValues(alpha: 0.15),
        );
      }
      return CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.info.withValues(alpha: 0.15),
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.info,
          ),
        ),
      );
    }

    Widget adminAvatar() {
      return CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
        child: const Icon(
          Icons.support_agent,
          size: 18,
          color: AppColors.primary,
        ),
      );
    }

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.65,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isAdmin ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: isAdmin ? const Radius.circular(16) : const Radius.circular(4),
          bottomRight: isAdmin ? const Radius.circular(4) : const Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: isAdmin ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 10,
              color: isAdmin ? Colors.white60 : AppColors.textHint,
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Column(
        crossAxisAlignment:
            isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isAdmin)
            Padding(
              padding: const EdgeInsets.only(left: 40, bottom: 4),
              child: Text(
                senderName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
            ),
          Row(
            mainAxisAlignment:
                isAdmin ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isAdmin) ...[
                userAvatar(),
                const SizedBox(width: 8),
              ],
              bubble,
              if (isAdmin) ...[
                const SizedBox(width: 8),
                adminAvatar(),
              ],
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceDim,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _msgController,
                focusNode: _focusNode,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                minLines: 1,
                decoration: const InputDecoration(
                  hintText: 'Trả lời khách hàng...',
                  hintStyle: TextStyle(
                      color: AppColors.textHint, fontSize: 15),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                ),
                style: const TextStyle(
                    fontSize: 15, color: AppColors.textPrimary),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          BlocBuilder<AdminChatBloc, AdminChatState>(
            buildWhen: (prev, curr) => prev.status != curr.status,
            builder: (context, state) {
              final isSending = state.status == AdminChatStatus.sending;
              return GestureDetector(
                onTap: isSending ? null : _sendMessage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, AppColors.accentDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            AppColors.accent.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: isSending
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          ),
                        )
                      : const Icon(Icons.send_rounded,
                          color: Colors.white, size: 22),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
