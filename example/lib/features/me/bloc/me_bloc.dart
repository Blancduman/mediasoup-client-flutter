import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'me_event.dart';
part 'me_state.dart';

class MeBloc extends Bloc<MeEvent, MeState> {
  MeBloc({required String id, required String displayName}) : super(MeState(
    webcamInProgress: false,
    shareInProgress: false,
    id: id,
    displayName: displayName,
  ));

  @override
  Stream<MeState> mapEventToState(
    MeEvent event,
  ) async* {
    if (event is MeSetWebcamInProgress) {
      yield* _mapMeSetWebCamInProgressToState(event);
    }
  }

  Stream<MeState> _mapMeSetWebCamInProgressToState(MeSetWebcamInProgress event) async* {
    yield MeState.copy(state, webcamInProgress: event.progress);
  }
}
