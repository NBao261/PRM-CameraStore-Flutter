import { Response, NextFunction } from 'express';
import ChatMessage from '../models/ChatMessage';
import { ApiResponse } from '../utils/response';
import { ValidationError } from '../utils/errors';
import { IAuthRequest } from '../types';
import { getIO } from '../socket';

// POST /api/chat
export const sendMessage = async (req: IAuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { content } = req.body;
    if (!content || content.trim() === '') {
      throw new ValidationError('Tin nhắn không được để trống');
    }

    const conversationId = `conv_${req.user!.id}`;

    const message = await ChatMessage.create({
      sender: req.user!.id,
      content: content.trim(),
      senderRole: 'user',
      conversationId,
    });

    const populated = await ChatMessage.findById(message._id)
      .populate('sender', 'fullName avatar role');

    // Emit to socket room so other participants see it in real-time
    try {
      const io = getIO();
      io.to(conversationId).emit('new_message', populated);
    } catch (_) {
      // Socket not initialized — still return success from REST
    }

    ApiResponse.created(res, populated);
  } catch (error) {
    next(error);
  }
};

// GET /api/chat/history?page=1&limit=50
export const getChatHistory = async (req: IAuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const conversationId = `conv_${req.user!.id}`;
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
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    next(error);
  }
};
