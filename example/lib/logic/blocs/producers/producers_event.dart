part of 'producers_bloc.dart';

abstract class ProducersEvent extends Equatable {
  const ProducersEvent();
}

class ProducerAdd extends ProducersEvent {
  final Producer producer;

  const ProducerAdd({this.producer});

  @override
  List<Object> get props => throw UnimplementedError();
}

class ProducerRemove extends ProducersEvent {
  final String source;

  const ProducerRemove({this.source});

  @override
  List<Object> get props => [source];
}

class ProducerPaused extends ProducersEvent {
  final String source;

  const ProducerPaused({this.source});

  @override
  List<Object> get props => [source];
}

class ProducerResumed extends ProducersEvent {
  final String source;

  const ProducerResumed({this.source});

  @override
  List<Object> get props => [source];
}