import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  ChatRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ChatMessageEntity>> getChatHistory() async {
    try {
      return await _remoteDataSource.getChatHistory();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ChatMessageEntity> sendMessage(String content) async {
    try {
      return await _remoteDataSource.sendMessage(content);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Failure _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }
    final responseData = e.response?.data;
    String message = responseData?['message'] as String? ?? 'Đã có lỗi xảy ra';
    return ServerFailure(message);
  }
}
