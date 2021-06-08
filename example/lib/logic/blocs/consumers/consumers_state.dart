part of 'consumers_bloc.dart';

class ConsumersState extends Equatable {
  final Map<String, Consumer> consumers;
  final Map<String, RTCVideoRenderer> renderers;

  const ConsumersState({this.consumers = const <String, Consumer>{}, this.renderers = const <String, RTCVideoRenderer>{}});

  @override
  List<Object> get props => [consumers, renderers];
}
