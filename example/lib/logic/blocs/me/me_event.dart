part of 'me_bloc.dart';

abstract class MeEvent extends Equatable {
  const MeEvent();
}

class MeSetWebcamInProgress extends MeEvent {
  final bool progress;

  const MeSetWebcamInProgress({this.progress});

  @override
  List<Object> get props => [];
}
