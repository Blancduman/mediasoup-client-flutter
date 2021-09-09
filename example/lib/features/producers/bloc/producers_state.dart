part of 'producers_bloc.dart';

class ProducersState extends Equatable {
  final Producer? mic;
  final Producer? webcam;
  final Producer? screen;

  const ProducersState({
    this.mic,
    this.webcam,
    this.screen,
  });

  static ProducersState copy(ProducersState old, {
    Producer? mic,
    Producer? webcam,
    Producer? screen,
  }) {
    return ProducersState(
      mic: mic ?? old.mic,
      webcam: webcam ?? old.webcam,
      screen: screen ?? old.screen,
    );
  }

  static ProducersState removeMic(ProducersState old) {
    return ProducersState(
      mic: null,
      webcam: old.webcam,
      screen: old.screen,
    );
  }

  static ProducersState removeWebcam(ProducersState old) {
    return ProducersState(
      mic: old.mic,
      webcam: null,
      screen: old.screen,
    );
  }

  static ProducersState removeScreen(ProducersState old) {
    return ProducersState(
      mic: old.mic,
      webcam: old.webcam,
      screen: null,
    );
  }

  @override
  List<Object?> get props => [mic, webcam, screen];
}
