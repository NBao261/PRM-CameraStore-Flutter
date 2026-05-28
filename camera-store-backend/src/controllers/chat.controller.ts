import { Response, NextFunction } from 'express';
import ChatMessage from '../models/ChatMessage';
import { ApiResponse } from '../utils/response';
import { ValidationError } from '../utils/errors';
import { IAuthRequest } from '../types';

// POST /api/chat
export const sendMessage = async (req: IAuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { content } = req.body;
    if (!content || content.trim() === '') {
      throw new ValidationError('Tin nhắn không được để trống');
    }

    const message = await ChatMessage.create({
      sender: req.user!.id,
      content: content.trim(),
      senderRole: 'user',
      conversationId: `conv_${req.user!.id}`,
    });

    ApiResponse.created(res, message);
  } catch (error) {
    next(error);
  }
};

// GET /api/chat/history
export const getChatHistory = async (req: IAuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const conversationId = `conv_${req.user!.id}`;
    const messages = await ChatMessage.find({ conversationId })
      .populate('sender', 'fullName avatar role')
      .sort({ createdAt: 1 });

    ApiResponse.success(res, messages);
  } catch (error) {
    next(error);
  }
};
