import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(const ChatLoadHistory());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final position = _scrollController.position.maxScrollExtent;
        if (animate) {
          _scrollController.animateTo(
            position,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(position);
        }
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    context.read<ChatBloc>().add(ChatSendMessage(content: text));
    _messageController.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        context.read<AuthBloc>().state.user?.id ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent,
                size: 20,
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hỗ trợ trực tuyến',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Camera Store Support',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ── Chat Messages List ──────────────────────────
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listenWhen: (prev, curr) =>
                  curr.messages.length > prev.messages.length,
              listener: (context, state) {
                _scrollToBottom();
              },
              builder: (context, state) {
                // Loading
                if (state.status == ChatStatus.loading &&
                    state.messages.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                // Error
                if (state.status == ChatStatus.error &&
                    state.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.wifi_off_rounded,
                          size: 64,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.errorMessage ?? 'Không thể tải tin nhắn',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => context
                              .read<ChatBloc>()
                              .add(const ChatLoadHistory()),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                // Empty state
                if (state.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 56,
                            color: AppColors.info.withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Bắt đầu trò chuyện',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 48),
                          child: Text(
                            'Gửi tin nhắn để được hỗ trợ\ntừ đội ngũ Camera Store',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Message list
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[index];
                    final isMine = message.senderId == currentUserId;

                    // Date separator
                    Widget? dateSeparator;
                    if (index == 0 ||
                        !_isSameDay(
                          state.messages[index - 1].createdAt,
                          message.createdAt,
                        )) {
                      dateSeparator = _buildDateSeparator(message.createdAt);
                    }

                    return Column(
                      children: [
                        if (dateSeparator != null) dateSeparator,
                        ChatBubble(
                          message: message,
                          isMine: isMine,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // ── Error banner ────────────────────────────────
          BlocBuilder<ChatBloc, ChatState>(
            buildWhen: (prev, curr) =>
                prev.status != curr.status && curr.status == ChatStatus.error,
            builder: (context, state) {
              if (state.status == ChatStatus.error &&
                  state.messages.isNotEmpty) {
                return Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppColors.errorLight,
                  child: Text(
                    state.errorMessage ?? 'Lỗi gửi tin nhắn',
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // ── Input Bar ───────────────────────────────────
          _buildInputBar(),
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
                controller: _messageController,
                focusNode: _focusNode,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                minLines: 1,
                decoration: const InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  hintStyle: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          BlocBuilder<ChatBloc, ChatState>(
            buildWhen: (prev, curr) => prev.status != curr.status,
            builder: (context, state) {
              final isSending = state.status == ChatStatus.sending;
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
                        color: AppColors.accent.withValues(alpha: 0.35),
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
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    String text;

    if (_isSameDay(date, now)) {
      text = 'Hôm nay';
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      text = 'Hôm qua';
    } else {
      text =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider(indent: 24, endIndent: 12)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceDim,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Expanded(child: Divider(indent: 12, endIndent: 24)),
        ],
      ),
    );
  }
}
