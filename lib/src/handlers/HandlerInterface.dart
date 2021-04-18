import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mediasoup_client_flutter/src/Producer.dart';
import 'package:mediasoup_client_flutter/src/SctpParameters.dart';
import 'package:mediasoup_client_flutter/src/Transport.dart';
import 'package:mediasoup_client_flutter/src/common/EnhancedEventEmitter.dart';
import 'package:mediasoup_client_flutter/src/RtpParameters.dart';

class RTCOAuthCredential {
  String accessToken;
  String macKey;
}

enum RTCIceCredentialType {
  oauth, password,
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
  String get value => values[this];
}

enum RTCIceTransportPolicy {
  all, relay,
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
  String get value => values[this];
}

class RTCIceServer {
  /// String or RTCOAuthCredential.
  var credential;
  RTCIceCredentialType credentialType;
  List<String> urls;
  String username;

  RTCIceServer({this.credential, this.credentialType, this.urls, this.username,});
}

class HandlerRunOptions {
  Direction direction;
  IceParameters iceParameters;
  List<IceCandidate> iceCandidates;
  DtlsParameters dtlsParameters;
  SctpParameters sctpParameters;
  RTCIceServer iceServer;
  RTCIceTransportPolicy iceTransportPolicy;
  var additionalSettings;
  var proprietaryConstraints;
  var extendedRtpCapabilities;

  HandlerRunOptions({
    this.direction,
    this.iceParameters,
    this.iceCandidates,
    this.dtlsParameters,
    this.sctpParameters,
    this.iceServer,
    this.iceTransportPolicy,
    this.additionalSettings,
    this.proprietaryConstraints,
    this.extendedRtpCapabilities,
  });
}

class HandlerSendResult {
  String localId;
  RtpParameters rtpParameters;
  RTCRtpSender rtpSender;

  HandlerSendResult({this.localId, this.rtpParameters, this.rtpSender,});
}

class HandlerSendOptions {
  MediaStreamTrack track;
  List<RtpEncodingParameters> encodings;
  ProducerCodecOptions codecOptions;
  RtpCodecCapability codec;

  HandlerSendOptions({
    this.track,
    this.encodings,
    this.codecOptions,
    this.codec,
  });
}

class HandlerSendDataChannelResult {
  RTCDataChannel dataChannel;
  SctpStreamParameters sctpStreamParameters;

  HandlerSendDataChannelResult({this.dataChannel, this.sctpStreamParameters,});
}

class HandlerReceiveResult {
  String localId;
  MediaStreamTrack track;
  RTCRtpReceiver rtpReceiver;

  HandlerReceiveResult({
    this.localId,
    this.track,
    this.rtpReceiver,
  });
}

class HandlerReceiveOptions {
  String trackId;
  RTCRtpMediaType kind;
  RtpParameters rtpParameters;

  HandlerReceiveOptions({
    this.trackId,
    this.kind,
    this.rtpParameters,
  });
}

class HandlerReceiveDataChannelOptions {
  SctpStreamParameters sctpStreamParameters;
  String label;
  String protocol;

  HandlerReceiveDataChannelOptions({
    this.sctpStreamParameters,
    this.label,
    this.protocol,
  });
}

class HandlerReceiveDataChannelResult {
  RTCDataChannel dataChannel;

  HandlerReceiveDataChannelResult({this.dataChannel});
}

abstract class HandlerInterface extends EnhancedEventEmitter {
  ///@emits @connect - (
  ///    { dtlsParameters: DtlsParameters },
  ///    callback: Function,
  ///    errback: Function
  ///  )
  ///@emits @connectionstatechange - (connectionState: ConnectionState)
  String get name;
  void close();
  Future<RtpCapabilities> getNativeRtpCapabilities();
  // Future<SctpCapabilities> getNativeSctpCapabilities();
  SctpCapabilities getNativeSctpCapabilities();
  void run({HandlerRunOptions options});
  Future<void> updateIceServers({List<RTCIceServer> iceServers});
  Future<void> restartIce({IceParameters iceParameters});
  // TODO: RTCStatsReport
  Future<List<StatsReport>> getTransportStats();
  Future<HandlerSendResult> send({HandlerSendOptions options});
  Future<void> stopSending({String localId});
  Future<void> replaceTrack({
    String localId, MediaStreamTrack track,
  });
  Future<void> setMaxSpatialLayer({
    String localId, int spatialLayer,
  });
  Future<void> setRtpEncodingParameters({
    String localId, RtpEncodingParameters params,
  });
  Future<List<StatsReport>> getSenderStats({String localId});
  Future<HandlerSendDataChannelResult> sendDataChannel({
    SctpStreamParameters options,
  });
  Future<HandlerReceiveResult> receive({
    HandlerReceiveOptions options,
  });
  Future<void> stopReceiving({
    String localId,
  });
  Future<List<StatsReport>> getReceiverStats({
    String localId,
  });
  Future<HandlerReceiveDataChannelResult> receiveDataChannel(
    HandlerReceiveDataChannelOptions options,
  );
}