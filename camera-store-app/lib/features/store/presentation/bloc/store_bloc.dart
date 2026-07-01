import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/store_repository.dart';
import 'store_event.dart';
import 'store_state.dart';

class StoreBloc extends Bloc<StoreEvent, StoreState> {
  final StoreRepository _repository;

  StoreBloc(this._repository) : super(const StoreState()) {
    on<StoreLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    StoreLoadRequested event,
    Emitter<StoreState> emit,
  ) async {
    emit(state.copyWith(status: StoreStatus.loading));
    try {
      final stores = await _repository.getStores();
      emit(state.copyWith(
        status: StoreStatus.loaded,
        stores: stores,
        selectedStore: stores.isNotEmpty ? stores.first : null,
      ));
    } on Failure catch (e) {
      emit(state.copyWith(status: StoreStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(
        status: StoreStatus.error,
        errorMessage: 'Không thể tải danh sách cửa hàng',
      ));
    }
  }
}
