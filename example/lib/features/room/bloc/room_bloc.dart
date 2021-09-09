import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:random_string/random_string.dart';

part 'room_event.dart';
part 'room_state.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  RoomBloc(String? url)
      : super(
          RoomState(
            url: url != null && url.isNotEmpty
                ? url.replaceAll('roomid', 'roomId')
                : 'https://v3demo.mediasoup.org/?roomId=${randomAlpha(8).toLowerCase()}',
          ),
        );

  @override
  Stream<RoomState> mapEventToState(
    RoomEvent event,
  ) async* {
    if (event is RoomSetActiveSpeakerId) {
      yield* _mapRoomSetActiveSpeakerIdToState(event);
    }
  }

  Stream<RoomState> _mapRoomSetActiveSpeakerIdToState(
      RoomSetActiveSpeakerId event) async* {
    yield state.newActiveSpeaker(activeSpeakerId: event.speakerId);
  }
}
