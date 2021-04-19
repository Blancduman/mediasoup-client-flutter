import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mediasoup_client_flutter/src/Ortc.dart';
import 'package:mediasoup_client_flutter/src/RtpParameters.dart';
import 'package:mediasoup_client_flutter/src/SctpParameters.dart';
import 'package:mediasoup_client_flutter/src/Transport.dart';
import 'package:mediasoup_client_flutter/src/common/EnhancedEventEmitter.dart';
import 'package:mediasoup_client_flutter/src/common/Logger.dart';
import 'package:mediasoup_client_flutter/src/handlers/HandlerInterface.dart';
import 'package:mediasoup_client_flutter/src/handlers/Native.dart'
  if (dart.library.html) 'package:mediasoup_client_flutter/src/handlers/Browser.dart';

Logger logger = Logger('Device');

class Device {
  // RTC handler factory.
  HandlerInterface _handlerInterface;
  // Loaded flag.
  bool _loaded = false;
  // Extended RTP capabilities.
  ExtendedRtpCapabilities _extendedRtpCapabilities;
  // Local RTP capabilities for receiving media.
  RtpCapabilities _recvRtpCapabilities;
  // Whether we can produce audio/video based on computed extended RTP
  // capabilities.
  CanProduceByKind _canProduceByKind;
  // Local SCTP capabilities.
  SctpCapabilities _sctpCapabilities;
  // Observer instance.
  EnhancedEventEmitter _observer = EnhancedEventEmitter();

  // Whether the Device is loaded.
  bool get loaded => _loaded;

  /// RTP capabilities of the Device for receiving media.
  /// 
  /// @throws {InvalidStateError} if not loaded.
  RtpCapabilities get rtpCapabilities {
    if (!_loaded) {
      throw('not loaded');
    }

    return _recvRtpCapabilities;
  }

  /// SCTP capabilities of the Device.
  /// @throws {InvalidStateError} if not loaded.
  SctpCapabilities get sctpCapabilities {
    if (_loaded) {
      throw('not loaded');
    }

    return _sctpCapabilities;
  }

  /// Observer.
  EnhancedEventEmitter get observer => _observer;

  /// Initialize the Device.
  Future<void> load({
    RtpCapabilities routerRtpCapabilities,
  }) async {
    logger.debug('load() [routerRtpCapabilities:${routerRtpCapabilities}]');

    routerRtpCapabilities = RtpCapabilities.copy(routerRtpCapabilities);

    // Temporal handler to get its capabilities.
    HandlerInterface handler;

    try {
      if (_loaded) {
        throw('already loaded');
      }

      // This may throw.
      Ortc.validateRtpCapabilities(routerRtpCapabilities);

      handler = HandlerInterface.handlerFactory();

      RtpCapabilities nativeRtpCapabilities = await handler.getNativeRtpCapabilities();

      logger.debug('load() | got native RTP capabilities:$nativeRtpCapabilities');

      // This may throw.
      Ortc.validateRtpCapabilities(nativeRtpCapabilities);

      // Get extended RTP capabilities.
      _extendedRtpCapabilities = Ortc.getExtendedRtpCapabilities(nativeRtpCapabilities, routerRtpCapabilities);

      logger.debug('load() | got extended RTP capabilities:$_extendedRtpCapabilities');

      // Check wether we can produce audio/video.
      _canProduceByKind = CanProduceByKind(
        audio: Ortc.canSend(RTCRtpMediaType.RTCRtpMediaTypeAudio, _extendedRtpCapabilities),
        video: Ortc.canSend(RTCRtpMediaType.RTCRtpMediaTypeVideo, _extendedRtpCapabilities),
      );

      // Generate our receiving RTP capabilities for receiving media.
      _recvRtpCapabilities = Ortc.getRecvRtpCapabilities(_extendedRtpCapabilities);

      // This may throw.
      Ortc.validateRtpCapabilities(_recvRtpCapabilities);

      logger.debug('load() | got receiving RTP capabilities:$_recvRtpCapabilities');

      // Generate our SCTP capabilities.
      _sctpCapabilities = handler.getNativeSctpCapabilities();

      logger.debug('load() | got native SCTP capabilities:$_sctpCapabilities');

      // This may throw.
      Ortc.validateSctpCapabilities(_sctpCapabilities);

      logger.debug('load() successed');

      _loaded = true;

      handler.close();
    } catch (error) {
      if (handler != null) {
        await handler.close();
      }

      throw error;
    }
  }

  // /// Create a new Device to connect to mediasoup server.
  // /// 
  // /// @throws {UnsupportedError} if device is not supported.
  // Device() {
  //   logger.debug('constructor()');

  //   //
  // }

  /// Whether we can produce audio/video.
  /// 
  /// @throws {InvalidStateError} if not loaded.
  /// @throws {TypeError} if wrong arguments.
  bool canProduce(RTCRtpMediaType kind) {
    if (!_loaded) {
      throw('not loaded');
    } else if (kind != RTCRtpMediaType.RTCRtpMediaTypeAudio && kind != RTCRtpMediaType.RTCRtpMediaTypeVideo) {
      throw('invalid kind ${RTCRtpMediaTypeExtension.value(kind)}');
    }

    return _canProduceByKind.canIt(kind);
  }

  Transport _createTransport({
    Direction direction,
    String id,
    IceParameters iceParameters,
    List<IceCandidate> iceCandidates,
    DtlsParameters dtlsParameters,
    SctpParameters sctpParameters,
    List<RTCIceServer> iceServers,
    RTCIceTransportPolicy iceTransportPolicy,
    Map<dynamic, dynamic> additionalSettings,
    Map<dynamic, dynamic> proprietaryConstraints,
    Map<dynamic, dynamic> appData,
  }) {
    if (!_loaded) {
			throw('not loaded');
    } else if (id == null) {
			throw('missing id');
		} else if (iceParameters == null) {
			throw('missing iceParameters');
    } else if (iceCandidates == null) {
			throw('missing iceCandidates');
		} else if (dtlsParameters == null) {
			throw('missing dtlsParameters');
    }

    // Create a new Transport.
    Transport transport = Transport(
      direction: direction,
      id: id,
      iceParameters: iceParameters,
      iceCandidates: iceCandidates,
      dtlsParameters: dtlsParameters,
      sctpParameters: sctpParameters,
      iceServers: iceServers,
      iceTransportPolicy: iceTransportPolicy,
      additionalSettings: additionalSettings,
      proprietaryConstraints: proprietaryConstraints,
      appData: appData,
      extendedRtpCapabilities: _extendedRtpCapabilities,
      canProduceByKind: _canProduceByKind,
    );

    // Emit observer event.
    _observer.safeEmit('newtransport', [transport]);  

    return transport;
  }


  /// Creates a Transport for sending media.
  /// 
  /// @throws {InvalidStateError} if not loaded.
  /// @throws {TypeError} if wrong arguments.
  Transport createSendTransport({
    String id,
    IceParameters iceParameters,
    List<IceCandidate> iceCandidates,
    DtlsParameters dtlsParameters,
    SctpParameters sctpParameters,
    List<RTCIceServer> iceServers,
    RTCIceTransportPolicy iceTransportPolicy,
    Map<dynamic, dynamic> additionalSettings,
    Map<dynamic, dynamic> proprietaryConstraints,
    Map<dynamic, dynamic> appData,
  }) {
    logger.debug('createSendTransport()');

    return _createTransport(
      direction: Direction.send,
      id: id,
      iceParameters: iceParameters,
      iceCandidates: iceCandidates,
      dtlsParameters: dtlsParameters,
      sctpParameters: sctpParameters,
      iceServers: iceServers,
      iceTransportPolicy: iceTransportPolicy,
      additionalSettings: additionalSettings,
      proprietaryConstraints: proprietaryConstraints,
      appData: appData,
    );
  }

  /// Creates a Transport for receiving media.
  /// 
  /// @throws {InvalidStateError} if not loaded.
  /// @throws {TypeError} if wrong arguments.
  Transport createRecvTransport({
    String id,
    IceParameters iceParameters,
    List<IceCandidate> iceCandidates,
    DtlsParameters dtlsParameters,
    SctpParameters sctpParameters,
    List<RTCIceServer> iceServers,
    RTCIceTransportPolicy iceTransportPolicy,
    Map<dynamic, dynamic> additionalSettings,
    Map<dynamic, dynamic> proprietaryConstraints,
    Map<dynamic, dynamic> appData,
  }) {
    logger.debug('createRecvTransport()');

    return _createTransport(
      direction: Direction.recv,
      id: id,
      iceParameters: iceParameters,
      iceCandidates: iceCandidates,
      dtlsParameters: dtlsParameters,
      sctpParameters: sctpParameters,
      iceServers: iceServers,
      iceTransportPolicy: iceTransportPolicy,
      additionalSettings: additionalSettings,
      proprietaryConstraints: proprietaryConstraints,
      appData: appData,
    );
  }
}