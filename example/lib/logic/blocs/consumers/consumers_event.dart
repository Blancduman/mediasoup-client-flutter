part of 'consumers_bloc.dart';

abstract class ConsumersEvent extends Equatable {
  const ConsumersEvent();
}

class ConsumerAdd extends ConsumersEvent {
  final Consumer consumer;

  const ConsumerAdd({this.consumer});

  @override
  List<Object> get props => [consumer];
}

class ConsumerRemove extends ConsumersEvent {
  final String consumerId;

  const ConsumerRemove({this.consumerId});

  @override
  List<Object> get props => [consumerId];
}

class ConsumerPaused extends ConsumersEvent {
  final String consumerId;

  const ConsumerPaused({this.consumerId});

  @override
  List<Object> get props => [consumerId];
}

class ConsumerResumed extends ConsumersEvent {
  final String consumerId;

  const ConsumerResumed({this.consumerId});

  @override
  List<Object> get props => [consumerId];
}