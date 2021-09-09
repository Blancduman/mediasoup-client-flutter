part of 'me_bloc.dart';

class MeState extends Equatable {
  final String displayName;
  final String id;
  final bool shareInProgress;
  final bool webcamInProgress;

  const MeState({
    required this.displayName,
    required this.id,
    required this.shareInProgress,
    required this.webcamInProgress,
  });

  static MeState copy(MeState old, {
    String? displayName,
    String? id,
    bool? shareInProgress,
    bool? webcamInProgress,
  }) {
    return MeState(
      displayName: displayName ?? old.displayName,
      id: id ?? old.id,
      shareInProgress: shareInProgress != null ? shareInProgress : old.shareInProgress,
      webcamInProgress: webcamInProgress != null ? webcamInProgress : old.webcamInProgress,
    );
}

  @override
  List<Object> get props => [
        displayName,
        id,
        shareInProgress,
        webcamInProgress,
      ];
}
