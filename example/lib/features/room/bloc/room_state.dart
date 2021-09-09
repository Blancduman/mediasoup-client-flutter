part of 'room_bloc.dart';

class RoomState extends Equatable {
  final String? activeSpeakerId;
  final String? state;
  final String url;
  const RoomState({this.activeSpeakerId, this.state, required this.url});

  RoomState newActiveSpeaker({
    String? activeSpeakerId,
  }) {
    return RoomState(url: url, state: state, activeSpeakerId: activeSpeakerId);
  }

  @override
  List<Object?> get props => [activeSpeakerId, state, url];
}
