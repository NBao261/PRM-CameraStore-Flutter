import { Server as SocketIOServer } from 'socket.io';
import { Server } from 'http';
import ChatMessage from './models/ChatMessage';

let io: SocketIOServer;

export const initSocket = (server: Server) => {
  io = new SocketIOServer(server, {
    cors: { origin: '*', methods: ['GET', 'POST'] },
  });

  io.on('connection', (socket) => {
    console.log(`🟢 Socket connected: ${socket.id}`);

    // Join a user-specific room for notifications
    socket.on('join_user', (userId: string) => {
      socket.join(`user_${userId}`);
      console.log(`User ${userId} joined room user_${userId}`);
    });

    // Chat rooms
    socket.on('join_conversation', (conversationId: string) => {
      socket.join(conversationId);
      console.log(`Socket ${socket.id} joined conversation ${conversationId}`);
    });

    // Send chat message — persist to DB then broadcast
    socket.on('send_message', async (data: {
      senderId: string;
      content: string;
      senderRole: 'user' | 'support';
      conversationId: string;
    }) => {
      try {
        const message = await ChatMessage.create({
          sender: data.senderId,
          content: data.content.trim(),
          senderRole: data.senderRole,
          conversationId: data.conversationId,
        });

        const populated = await ChatMessage.findById(message._id)
          .populate('sender', 'fullName avatar role');

        // Broadcast to the conversation room
        io.to(data.conversationId).emit('new_message', populated);
      } catch (err) {
        console.error('Error saving chat message via socket:', err);
        socket.emit('message_error', { error: 'Failed to send message' });
      }
    });

    // Typing indicator
    socket.on('typing', (data: { conversationId: string; userId: string; isTyping: boolean }) => {
      socket.to(data.conversationId).emit('user_typing', {
        userId: data.userId,
        isTyping: data.isTyping,
      });
    });

    socket.on('disconnect', () => {
      console.log(`🔴 Socket disconnected: ${socket.id}`);
    });
  });

  return io;
};

export const getIO = () => {
  if (!io) {
    throw new Error('Socket.io not initialized!');
  }
  return io;
};
