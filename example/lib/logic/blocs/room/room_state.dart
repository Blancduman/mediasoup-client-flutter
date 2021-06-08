part of 'room_bloc.dart';

class RoomState extends Equatable {
  final String activeSpeakerId;
  final String state;
  final String url;
  const RoomState({this.activeSpeakerId, this.state, this.url});

  static RoomState newActiveSpeaker(RoomState old, {
    String activeSpeakerId,
  }) {
    return RoomState(url: old.url, state: old.state, activeSpeakerId: activeSpeakerId);
  }

  @override
  List<Object> get props => [activeSpeakerId, state, url];
}
