import 'package:equatable/equatable.dart';
import '../../domain/entities/store_entity.dart';

enum StoreStatus { initial, loading, loaded, error }

class StoreState extends Equatable {
  final StoreStatus status;
  final List<StoreEntity> stores;
  final String? errorMessage;
  final StoreEntity? selectedStore;

  const StoreState({
    this.status = StoreStatus.initial,
    this.stores = const [],
    this.errorMessage,
    this.selectedStore,
  });

  StoreState copyWith({
    StoreStatus? status,
    List<StoreEntity>? stores,
    String? errorMessage,
    StoreEntity? selectedStore,
  }) {
    return StoreState(
      status: status ?? this.status,
      stores: stores ?? this.stores,
      errorMessage: errorMessage,
      selectedStore: selectedStore ?? this.selectedStore,
    );
  }

  @override
  List<Object?> get props => [status, stores, errorMessage, selectedStore];
}
