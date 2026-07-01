import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/store_model.dart';

class StoreRemoteDataSource {
  final ApiClient _apiClient;

  StoreRemoteDataSource(this._apiClient);

  Future<List<StoreModel>> getStores() async {
    final response = await _apiClient.dio.get(ApiEndpoints.stores);
    final List data = response.data['data'] ?? [];
    return data.map((json) => StoreModel.fromJson(json)).toList();
  }
}
