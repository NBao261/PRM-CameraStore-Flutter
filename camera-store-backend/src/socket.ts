import { Server as SocketIOServer } from 'socket.io';
import { Server } from 'http';

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
    });

    socket.on('send_message', (data) => {
      io.to(data.conversationId).emit('new_message', data);
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
