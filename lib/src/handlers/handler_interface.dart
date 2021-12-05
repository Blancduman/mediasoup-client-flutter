import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mediasoup_client_flutter/src/producer.dart';
import 'package:mediasoup_client_flutter/src/sctp_parameters.dart';
import 'package:mediasoup_client_flutter/src/transport.dart';
import 'package:mediasoup_client_flutter/src/common/enhanced_event_emitter.dart';
import 'package:mediasoup_client_flutter/src/rtp_parameters.dart';
import 'package:mediasoup_client_flutter/src/handlers/unified_plan.dart';

class SCTP_NUM_STREAMS {
  static const int OS = 1024;
  static const int MIS = 1024;
}

class RTCOAuthCredential {
  final String accessToken;
  final String macKey;

  const RTCOAuthCredential({
    required this.accessToken,
    required this.macKey,
  });
}

enum RTCIceCredentialType {
  oauth,
  password,
}

extension RTCIceCredentialTypeToString on RTCIceCredentialType {
  static const Map<String, RTCIceCredentialType> types = {
    'oauth': RTCIceCredentialType.oauth,
    'password': RTCIceCredentialType.password,
  };

  static const Map<RTCIceCredentialType, String> values = {
    RTCIceCredentialType.oauth: 'oauth',
    RTCIceCredentialType.password: 'password',
  };

  operator [](String i) => types[i];
  String get value => values[this]!;
}

enum RTCIceTransportPolicy {
  all,
  relay,
}

extension RTCIceTransportPolicyToString on RTCIceTransportPolicy {
  static const Map<String, RTCIceTransportPolicy> types = {
    'all': RTCIceTransportPolicy.all,
    'relay': RTCIceTransportPolicy.relay,
  };

  static const Map<RTCIceTransportPolicy, String> values = {
    RTCIceTransportPolicy.all: 'all',
    RTCIceTransportPolicy.relay: 'relay',
  };

  operator [](String i) => types[i];
  String get value => values[this]!;
}

class RTCIceServer {
  /// String or RTCOAuthCredential.
  final credential;
  final RTCIceCredentialType credentialType;
  final List<String> urls;
  final String username;

  RTCIceServer({
    this.credential,
    required this.credentialType,
    this.urls = const [],
    required this.username,
  });

  Map<String, dynamic> toMap() {
    return {
      if (credential != null) 'credential': credential,
      'credentialType': credentialType.value,
      'urls': urls,
      'username': username,
    };
  }
}

class HandlerRunOptions {
  Direction direction;
  IceParameters iceParameters;
  List<IceCandidate> iceCandidates;
  DtlsParameters dtlsParameters;
  SctpParameters? sctpParameters;
  List<RTCIceServer> iceServers;
  RTCIceTransportPolicy? iceTransportPolicy;
  var additionalSettings;
  Map<String, dynamic> proprietaryConstraints;
  var extendedRtpCapabilities;

  HandlerRunOptions({
    required this.direction,
    required this.iceParameters,
    required this.iceCandidates,
    required this.dtlsParameters,
    this.sctpParameters,
    required this.iceServers,
    this.iceTransportPolicy,
    this.additionalSettings,
    required this.proprietaryConstraints,
    this.extendedRtpCapabilities,
  });
}

class HandlerSendResult {
  final String localId;
  final RtpParameters rtpParameters;
  final RTCRtpSender? rtpSender;

  const HandlerSendResult({
    required this.localId,
    required this.rtpParameters,
    this.rtpSender,
  });
}

class HandlerSendOptions {
  final MediaStreamTrack track;
  final List<RtpEncodingParameters> encodings;
  final ProducerCodecOptions? codecOptions;
  final RtpCodecCapability? codec;
  final MediaStream stream;

  const HandlerSendOptions({
    required this.track,
    this.encodings = const [],
    this.codecOptions,
    this.codec,
    required this.stream,
  });
}

class HandlerSendDataChannelResult {
  final RTCDataChannel dataChannel;
  final SctpStreamParameters sctpStreamParameters;

  const HandlerSendDataChannelResult({
    required this.dataChannel,
    required this.sctpStreamParameters,
  });
}

class HandlerReceiveResult {
  final String localId;
  final MediaStreamTrack track;
  final RTCRtpReceiver? rtpReceiver;
  final MediaStream stream;

  const HandlerReceiveResult({
    required this.localId,
    required this.track,
    this.rtpReceiver,
    required this.stream,
  });
}

class HandlerReceiveOptions {
  final String trackId;
  final RTCRtpMediaType kind;
  final RtpParameters rtpParameters;

  HandlerReceiveOptions({
    required this.trackId,
    required this.kind,
    required this.rtpParameters,
  });
}

class HandlerReceiveDataChannelOptions {
  final SctpStreamParameters sctpStreamParameters;
  final String label;
  final String protocol;

  HandlerReceiveDataChannelOptions({
    required this.sctpStreamParameters,
    required this.label,
    required this.protocol,
  });
}

class ReplaceTrackOptions {
  final String localId;
  final MediaStreamTrack track;

  const ReplaceTrackOptions({
    required this.localId,
    required this.track,
  });
}

class HandlerReceiveDataChannelResult {
  final RTCDataChannel dataChannel;

  const HandlerReceiveDataChannelResult({required this.dataChannel});
}

class SetMaxSpatialLayerOptions {
  final String localId;
  final int spatialLayer;

  const SetMaxSpatialLayerOptions({
    required this.localId,
    required this.spatialLayer,
  });
}

class SetRtpEncodingParametersOptions {
  final String localId;
  final RtpEncodingParameters params;

  const SetRtpEncodingParametersOptions({
    required this.localId,
    required this.params,
  });
}

abstract class HandlerInterface extends EnhancedEventEmitter {
  HandlerInterface() : super();

  static HandlerInterface handlerFactory() => UnifiedPlan();

  ///@emits @connect - (
  ///    { dtlsParameters: DtlsParameters },
  ///    callback: Function,
  ///    errback: Function
  ///  )
  ///@emits @connectionstatechange - (connectionState: ConnectionState)
  String get name;
  Future<void> close();
  Future<RtpCapabilities> getNativeRtpCapabilities();
  // Future<SctpCapabilities> getNativeSctpCapabilities();
  SctpCapabilities getNativeSctpCapabilities();
  void run({required HandlerRunOptions options});
  Future<void> updateIceServers(List<RTCIceServer> iceServers);
  Future<void> restartIce(IceParameters iceParameters);
  // TODO: RTCStatsReport
  Future<List<StatsReport>> getTransportStats();
  Future<HandlerSendResult> send(HandlerSendOptions options);
  Future<void> stopSending(String localId);
  Future<void> replaceTrack(ReplaceTrackOptions options);
  Future<void> setMaxSpatialLayer(SetMaxSpatialLayerOptions options);
  Future<void> setRtpEncodingParameters(
      SetRtpEncodingParametersOptions options);
  Future<List<StatsReport>> getSenderStats(String localId);
  Future<HandlerSendDataChannelResult> sendDataChannel(
      SendDataChannelArguments options);
  Future<HandlerReceiveResult> receive(HandlerReceiveOptions options);
  Future<void> stopReceiving(
    String localId,
  );
  Future<List<StatsReport>> getReceiverStats(String localId);
  Future<HandlerReceiveDataChannelResult> receiveDataChannel(
    HandlerReceiveDataChannelOptions options,
  );
}
