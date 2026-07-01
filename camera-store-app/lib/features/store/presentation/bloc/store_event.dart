import 'package:equatable/equatable.dart';

abstract class StoreEvent extends Equatable {
  const StoreEvent();

  @override
  List<Object?> get props => [];
}

class StoreLoadRequested extends StoreEvent {
  const StoreLoadRequested();
}
