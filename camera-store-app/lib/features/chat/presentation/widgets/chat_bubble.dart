import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/chat_message_entity.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageEntity message;
  final bool isMine;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMine,
  });

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMine)
            Padding(
              padding: const EdgeInsets.only(left: 40, bottom: 4),
              child: Text(
                message.senderName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
            ),
          Row(
            mainAxisAlignment:
                isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start, // Align top of bubble
            children: [
              if (!isMine) ...[
                // Support avatar
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.info.withValues(alpha: 0.15),
                  child: const Icon(
                    Icons.support_agent,
                    size: 18,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment:
                      isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.72,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: isMine
                            ? const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryLight
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isMine ? null : AppColors.surfaceDim,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(isMine ? 18 : 4),
                          bottomRight: Radius.circular(isMine ? 4 : 18),
                        ),
                      ),
                      child: Text(
                        message.content,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.4,
                          color: isMine ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        _formatTime(message.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
