import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mediasoup_client_flutter/src/Producer.dart';
import 'package:mediasoup_client_flutter/src/SctpParameters.dart';
import 'package:mediasoup_client_flutter/src/Transport.dart';
import 'package:mediasoup_client_flutter/src/common/EnhancedEventEmitter.dart';
import 'package:mediasoup_client_flutter/src/RtpParameters.dart';
import 'package:mediasoup_client_flutter/src/handlers/Browser.dart';
import 'package:mediasoup_client_flutter/src/handlers/Native.dart';

class SCTP_NUM_STREAMS {
  static const int OS = 1024;
  static const int MIS = 1024;
}

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

  Map<String, dynamic> toMap() {
    return {
      if (credential != null)
        'credential': credential,
      if (credentialType != null)
      'credentialType': credentialType.value,
      if (urls != null)
      'urls': urls,
      if (username != null)
      'username': username,
    };
  }
}

class HandlerRunOptions {
  Direction direction;
  IceParameters iceParameters;
  List<IceCandidate> iceCandidates;
  DtlsParameters dtlsParameters;
  SctpParameters sctpParameters;
  List<RTCIceServer> iceServers;
  RTCIceTransportPolicy iceTransportPolicy;
  var additionalSettings;
  Map<String, dynamic> proprietaryConstraints;
  var extendedRtpCapabilities;

  HandlerRunOptions({
    this.direction,
    this.iceParameters,
    this.iceCandidates,
    this.dtlsParameters,
    this.sctpParameters,
    this.iceServers,
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
  MediaStream stream;

  HandlerSendOptions({
    this.track,
    this.encodings,
    this.codecOptions,
    this.codec,
    this.stream,
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
  MediaStream stream;
  RTCRtpReceiver rtpReceiver;

  HandlerReceiveResult({
    this.localId,
    this.track,
    this.rtpReceiver,
    this.stream,
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

class ReplaceTrackOptions {
  final String localId;
  final MediaStreamTrack track;

  ReplaceTrackOptions({this.localId, this.track});
}

class HandlerReceiveDataChannelResult {
  RTCDataChannel dataChannel;

  HandlerReceiveDataChannelResult({this.dataChannel});
}

class SetMaxSpatialLayerOptions {
  final String localId;
  final int spatialLayer;

  SetMaxSpatialLayerOptions({this.localId, this.spatialLayer});
}

class SetRtpEncodingParametersOptions {
  final String localId;
  final RtpEncodingParameters params;

  SetRtpEncodingParametersOptions({this.localId, this.params});
}

abstract class HandlerInterface extends EnhancedEventEmitter {
  HandlerInterface() : super();

  static HandlerInterface handlerFactory() {
    if (kIsWeb) {
      return Browser();
    } else {
      return Native();
    }
  }
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
  void run({HandlerRunOptions options});
  Future<void> updateIceServers(List<RTCIceServer> iceServers);
  Future<void> restartIce(IceParameters iceParameters);
  // TODO: RTCStatsReport
  Future<List<StatsReport>> getTransportStats();
  Future<HandlerSendResult> send(HandlerSendOptions options);
  Future<void> stopSending(String localId);
  Future<void> replaceTrack(ReplaceTrackOptions options);
  Future<void> setMaxSpatialLayer(SetMaxSpatialLayerOptions options);
  Future<void> setRtpEncodingParameters(SetRtpEncodingParametersOptions options);
  Future<List<StatsReport>> getSenderStats(String localId);
  Future<HandlerSendDataChannelResult> sendDataChannel(SctpStreamParameters options);
  Future<HandlerReceiveResult> receive(HandlerReceiveOptions options);
  Future<void> stopReceiving(
    String localId,
  );
  Future<List<StatsReport>> getReceiverStats(String localId);
  Future<HandlerReceiveDataChannelResult> receiveDataChannel(
    HandlerReceiveDataChannelOptions options,
  );
}