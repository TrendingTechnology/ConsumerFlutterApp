import 'package:LaCoro/presentation/core/bloc/base_bloc.dart';
import 'package:domain/use_cases/get_all_stores.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoreListBloc extends Bloc<BaseEvent, BaseState> {
  final GetAllStores _getAllStores;

  StoreListBloc(this._getAllStores);

  @override
  BaseState get initialState => InitialState();

  @override
  Stream<BaseState> mapEventToState(BaseEvent event) async* {
    if (event is GetAllStoresEvent) {
      yield LoadingState();
      final storeList = await _getAllStores.call(event.city)..shuffle();
      yield SuccessState(data: storeList);
    } else {
      yield ErrorState();
    }
  }
}

/// Store list events
class GetAllStoresEvent extends BaseEvent {
  final String city;

  GetAllStoresEvent(this.city);
}
