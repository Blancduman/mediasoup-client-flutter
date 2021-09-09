

import 'package:mediasoup_client_flutter/src/common/index.dart';

class NumSctpStreams {
  /*
	 * Initially requested number of outgoing SCTP streams.
	 */
  final int os;
  /*
	 * Maximum number of incoming SCTP streams.
	 */
  final int mis;

  NumSctpStreams({
    required this.os,
    required this.mis,
  });

  Map<String, int> toMap() {
    return {
      'OS': os,
      'MIS': mis,
    };
  }
}

class SctpCapabilities {
  final NumSctpStreams numStreams;
  SctpCapabilities({required this.numStreams});

  Map<String, dynamic> toMap() {
    return {
      'numStreams': numStreams.toMap(),
    };
  }
}

class SctpParameters {
  /*
	 * Must always equal 5000.
	 */
  final int port;
  /*
	 * Initially requested number of outgoing SCTP streams.
	 */
  final int os;
  /*
	 * Maximum number of incoming SCTP streams.
	 */
  final int mis;
  /*
	 * Maximum allowed size for SCTP messages.
	 */
  final int maxMessageSize;

  SctpParameters({
    this.port = 5000,
    required this.os,
    required this.mis,
    required this.maxMessageSize,
  });

  Map<String, int> toMap() {
    return {
      'port': port,
      'OS': os,
      'MIS': mis,
      'maxMessageSize': maxMessageSize,
    };
  }

  static SctpParameters fromMap(Map data) {
    return SctpParameters(
      port: data['port'],
      os: data['OS'],
      mis: data['MIS'],
      maxMessageSize: data['maxMessageSize'],
    );
  }
}

/*
 * SCTP stream parameters describe the reliability of a certain SCTP stream.
 * If ordered is true then maxPacketLifeTime and maxRetransmits must be
 * false.
 * If ordered if false, only one of maxPacketLifeTime or maxRetransmits
 * can be true.
 */
class SctpStreamParameters {
  /*
	 * SCTP stream id.
	 */
  final int streamId;
  /*
	 * Whether data messages must be received in order. if true the messages will
	 * be sent reliably. Default true.
	 */
  bool? ordered;
  /*
	 * When ordered is false indicates the time (in milliseconds) after which a
	 * SCTP packet will stop being retransmitted.
	 */
  final int? maxPacketLifeTime;
  /*
	 * When ordered is false indicates the maximum number of times a packet will
	 * be retransmitted.
	 */
  final int? maxRetransmits;
  /*
	 * DataChannel priority.
	 */
  final Priority? priority;
  /*
	 * A label which can be used to distinguish this DataChannel from remote_stream.
	 */
  final String? label;
  /*
	 * Name of the sub-protocol used by this DataChannel.
	 */
  final String? protocol;

  SctpStreamParameters({
    required this.streamId,
    this.ordered,
    this.maxPacketLifeTime,
    this.maxRetransmits,
    this.priority,
    this.label,
    this.protocol,
  });

  static SctpStreamParameters copy(SctpStreamParameters old) {
    return SctpStreamParameters(
      streamId: old.streamId,
      ordered: old.ordered,
      maxPacketLifeTime: old.maxPacketLifeTime,
      maxRetransmits: old.maxRetransmits,
      priority: old.priority,
      label: old.label,
      protocol: old.protocol,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'streamId': streamId,
      'ordered': ordered,
      'maxPacketLifeTime': maxPacketLifeTime,
      'maxRetransmits': maxRetransmits,
      'priority': priority?.value,
      'label': label,
      'protocol': protocol,
    };
  }
}

