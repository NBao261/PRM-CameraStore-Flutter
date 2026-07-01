import { Response, NextFunction } from 'express';
import ChatMessage from '../models/ChatMessage';
import User from '../models/User';
import { ApiResponse } from '../utils/response';
import { ValidationError } from '../utils/errors';
import { IAuthRequest } from '../types';
import { getIO } from '../socket';

// GET /api/admin/chat/conversations
export const getConversationList = async (req: IAuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    // Get all distinct conversationIds
    const conversations = await ChatMessage.aggregate([
      { $sort: { createdAt: -1 } },
      {
        $group: {
          _id: '$conversationId',
          lastMessage: { $first: '$content' },
          lastSenderRole: { $first: '$senderRole' },
          lastMessageAt: { $first: '$createdAt' },
          senderId: { $first: '$sender' },
          messageCount: { $sum: 1 },
        },
      },
      { $sort: { lastMessageAt: -1 } },
    ]);

    // Extract user IDs from conversationId (format: conv_{userId})
    const enriched = await Promise.all(
      conversations.map(async (conv) => {
        const userId = conv._id.replace('conv_', '');
        const user = await User.findById(userId).select('fullName email phone avatar');
        return {
          conversationId: conv._id,
          user: user || { fullName: 'Unknown', email: '', phone: '' },
          lastMessage: conv.lastMessage,
          lastSenderRole: conv.lastSenderRole,
          lastMessageAt: conv.lastMessageAt,
          messageCount: conv.messageCount,
        };
      })
    );

    ApiResponse.success(res, enriched);
  } catch (error) {
    next(error);
  }
};

// GET /api/admin/chat/conversations/:conversationId
export const getConversationMessages = async (req: IAuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { conversationId } = req.params;
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 50;
    const skip = (page - 1) * limit;

    const total = await ChatMessage.countDocuments({ conversationId });
    const messages = await ChatMessage.find({ conversationId })
      .populate('sender', 'fullName avatar role')
      .sort({ createdAt: 1 })
      .skip(skip)
      .limit(limit);

    ApiResponse.success(res, {
      messages,
      pagination: { page, limit, total, totalPages: Math.ceil(total / limit) },
    });
  } catch (error) {
    next(error);
  }
};

// POST /api/admin/chat/conversations/:conversationId
export const sendAdminMessage = async (req: IAuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { conversationId } = req.params;
    const { content } = req.body;

    if (!content || content.trim() === '') {
      throw new ValidationError('Tin nhắn không được để trống');
    }

    const message = await ChatMessage.create({
      sender: req.user!.id,
      content: content.trim(),
      senderRole: 'support',
      conversationId,
    });

    const populated = await ChatMessage.findById(message._id)
      .populate('sender', 'fullName avatar role');

    // Emit to socket room for real-time
    try {
      const io = getIO();
      io.to(conversationId).emit('new_message', populated);
    } catch (_) {}

    ApiResponse.created(res, populated);
  } catch (error) {
    next(error);
  }
};
