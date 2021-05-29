import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mediasoup_client_flutter/src/Consumer.dart';
import 'package:mediasoup_client_flutter/src/DataConsumer.dart';
import 'package:mediasoup_client_flutter/src/DataProducer.dart';
import 'package:mediasoup_client_flutter/src/FlexQueue/FlexQueue.dart';
import 'package:mediasoup_client_flutter/src/Ortc.dart';
import 'package:mediasoup_client_flutter/src/Producer.dart';
import 'package:mediasoup_client_flutter/src/RtpParameters.dart';
import 'package:mediasoup_client_flutter/src/SctpParameters.dart';
import 'package:mediasoup_client_flutter/src/common/EnhancedEventEmitter.dart';
import 'package:mediasoup_client_flutter/src/common/Logger.dart';
import 'package:mediasoup_client_flutter/src/common/index.dart';
import 'package:mediasoup_client_flutter/src/handlers/HandlerInterface.dart';

enum Protocol { upd, tcp }

extension ProtocolExtension on Protocol {
  static const Map<String, Protocol> types = {
    'tcp': Protocol.tcp,
    'upd': Protocol.upd,
  };

  static const Map<Protocol, String> values = {
    Protocol.tcp: 'tcp',
    Protocol.upd: 'upd',
  };

  static Protocol fromString(String type) => types[type];

  String get value => values[this];
}

enum IceCandidateType {
  host,
  srflx,
  prflx,
  relay,
}

extension IceCandidateTypeExtension on IceCandidateType {
  static const Map<String, IceCandidateType> types = {
    'host': IceCandidateType.host,
    'prflx': IceCandidateType.prflx,
    'relay': IceCandidateType.relay,
    'srflx': IceCandidateType.srflx,
  };

  static const Map<IceCandidateType, String> values = {
    IceCandidateType.host: 'host',
    IceCandidateType.prflx: 'prflx',
    IceCandidateType.relay: 'relay',
    IceCandidateType.srflx: 'srflx',
  };

  static IceCandidateType fromString(String type) => types[type];

  String get value => values[this];
}

class IceParameters {
  /// ICE username fragment.
  String usernameFragment;

  /// ICE password.
  String password;

  /// ICE Lite.
  bool iceLite;

  IceParameters({
    this.usernameFragment,
    this.password,
    this.iceLite,
  });

  IceParameters.fromMap(Map data) {
    usernameFragment = data['usernameFragment'];
    password = data['password'];
    iceLite = data['iceLite'];
  }
}

enum TcpType {
  active,
  passive,
  so,
}

extension TcpTypeExtension on TcpType {
  static const Map<String, TcpType> types = {
    'active': TcpType.active,
    'passive': TcpType.passive,
    'so': TcpType.so,
  };

  static const Map<TcpType, String> values = {
    TcpType.active: 'active',
    TcpType.passive: 'passive',
    TcpType.so: 'so',
  };

  static TcpType fromString(String type) => types[type];

  String get value => values[this];
}

class IceCandidate {
  int component;

  /// Unique identifier that allows ICE to correlate candidates that appear on
  /// multiple transports.
  var foundation;

  // String foundation;

  ///The assigned priority of the candidate.
  int priority;

  /// The IP address of the candidate.
  String ip;

  /// The protocol of the candidate.
  Protocol protocol;

  /// The port for the candidate.
  int port;

  /// The type of candidate..
  IceCandidateType type;

  /// The type of TCP candidate.
  TcpType tcpType;

  String transport;

  String raddr;

  int rport;

  var generation;

  var networkId;

  var networkCost;

  IceCandidate({
    this.component = 1,
    this.foundation,
    this.priority,
    this.ip,
    this.protocol,
    this.port,
    this.type,
    this.tcpType,
    this.transport,
    this.raddr,
    this.rport,
    this.generation,
    this.networkId,
    this.networkCost,
  });

  IceCandidate.fromMap(Map data) {
    component = data['component'] ?? 1;
    foundation = data['foundation'];
    // foundation = data['foundation'] is int ? data['foundation'] : data['foundation'].substring(0,3);
    ip = data['ip'];
    port = data['port'];
    priority = data['priority'];
    if (data['protocol'] != null) {
      protocol = ProtocolExtension.fromString(data['protocol']);
    }
    if (data['type'] != null) {
      type = IceCandidateTypeExtension.fromString(data['type']);
    }
    if (data['tcpType'] != null) {
      tcpType = TcpTypeExtension.fromString(data['tcpType']);
    }
    transport = data['transport'] ?? 'udp';
    raddr = data['raddr'];
    rport = data['rport'];
    generation = data['generation'];
    networkId = data['network-id'];
    networkCost = data['network-cost'];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> result = {};
    if (component != null) {
      result['component'] = component;
    }
    if (foundation != null) {
      result['foundation'] = foundation;
    }
    if (priority != null) {
      result['priority'] = priority;
    }
    if (ip != null) {
      result['ip'] = ip;
    }
    if (protocol != null) {
      result['protocol'] = protocol.value;
    }
    if (port != null) {
      result['port'] = port;
    }
    if (type != null) {
      result['type'] = type.value;
    }
    if (tcpType != null) {
      result['tcptype'] = tcpType.value;
    }
    if (transport != null) {
      result['transport'] = transport;
    }
    // if (raddr != null) {
    //   result['raddr'] = raddr;
    // }
    // if (rport != null) {
    //   result['rport'] = rport;
    // }
    // if (generation != null) {
    //   result['generation'] = generation;
    // }
    // if (networkId != null) {
    //   result['network-id'] = networkId;
    // }
    // if (networkCost != null) {
    //   result['network-cost'] = networkCost;
    // }

    return result;
  }

  static IceCandidate copy(IceCandidate old) {
    return IceCandidate(
      component: old.component,
      foundation: old.foundation,
      ip: old.ip,
      port: old.port,
      priority: old.priority,
      protocol: old.protocol,
      tcpType: old.tcpType,
      type: old.type,
      generation: old.generation,
      raddr: old.raddr,
      rport: old.rport,
      transport: old.transport,
      networkId: old.networkId,
      networkCost: old.networkCost,
    );
  }
}

enum DtlsRole {
  auto,
  client,
  server,
}

extension DtlsRoleExtension on DtlsRole {
  static const Map<String, DtlsRole> types = {
    'auto': DtlsRole.auto,
    'client': DtlsRole.client,
    'server': DtlsRole.server,
  };

  static const Map<DtlsRole, String> values = {
    DtlsRole.auto: 'auto',
    DtlsRole.client: 'client',
    DtlsRole.server: 'server',
  };

  static DtlsRole fromString(String type) => types[type];

  String get value => values[this];
}

class DtlsFingerprint {
  String algorithm;
  String value;

  DtlsFingerprint({this.algorithm, this.value});

  DtlsFingerprint.fromMap(Map data) {
    algorithm = data['algorithm'];
    value = data['value'];
  }

  Map<String, String> toMap() {
    return {
      'algorithm': algorithm,
      'value': value,
    };
  }
}

class DtlsParameters {
  DtlsRole role;
  List<DtlsFingerprint> fingerprints;

  DtlsParameters({this.role, this.fingerprints});

  DtlsParameters.fromMap(Map data) {
    role = DtlsRoleExtension.fromString(data['role']);
    fingerprints = List<DtlsFingerprint>.from(data['fingerprints']
        .map((fingerP) => DtlsFingerprint.fromMap(fingerP))
        .toList());
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role.value,
      'fingerprints':
          fingerprints.map((DtlsFingerprint fp) => fp.toMap()).toList(),
    };
  }
}

class PlainRtpParameters {
  String ip;
  int _ipVersion;
  int port;

  int get ipVersion => _ipVersion;

  set ipVersion(int ip) {
    if (ip != 4 || ip != 6) {
      throw 'only 4 or 6';
    }
    _ipVersion = ip;
  }

  PlainRtpParameters({this.ip, this.port, int ipVersion})
      : this._ipVersion = ipVersion,
        assert(ipVersion != 4 || ipVersion != 6, 'Only 4 or 6');
}

Logger _logger = Logger('Transport');

enum Direction {
  send,
  recv,
}

extension DirectionExtension on Direction {
  static const Map<String, Direction> types = {
    'recv': Direction.recv,
    'send': Direction.send,
  };

  static const Map<Direction, String> values = {
    Direction.recv: 'recv',
    Direction.send: 'send',
  };

  static Direction fromString(String type) => types[type];

  String get value => values[this];
}

class CanProduceByKind {
  bool audio;
  bool video;

  // TODO: what is that?
  Map<String, bool> tmp;

  CanProduceByKind({this.audio, this.video, this.tmp});

  bool canIt(RTCRtpMediaType kind) {
    if (kind == RTCRtpMediaType.RTCRtpMediaTypeAudio) {
      return audio;
    }

    return video;
  }
}

class Transport extends EnhancedEventEmitter {
  // Id.
  String _id;

  // Closed flag.
  bool _closed = false;

  // Direction
  Direction _direction;

  // Extended RTP capabilities.
  // TODO: make class ExtendedRtpCapabilities;
  var _extendedRtpCapabilities;

  // Whether we can produce audio/video based on computed extended RTP
  // capabilities.
  CanProduceByKind _canProduceByKind;

  // SCTP max message size if enabled, null otherwise.
  int _maxSctpMessageSize;

  // RTC handler instance.
  HandlerInterface _handler;

  // Transport connection state.
  String _connectionState = 'new';

  // App custom data.
  Map<String, dynamic> _appData;

  // Map of Producers indexed by id.
  Map<String, Producer> _producers = <String, Producer>{};

  // Map of Consumers indexed by id.
  Map<String, Consumer> _consumers = <String, Consumer>{};

  // Map of DataProducers indexed by id.
  Map<String, DataProducer> _dataProducers = <String, DataProducer>{};

  // Map of DataConsumers indexed by id.
  Map<String, DataConsumer> _dataConsumers = <String, DataConsumer>{};

  // Whether the Consumer for RTP probation has been created.
  bool _probatorConsumerCreated = false;

  // FlexQueue instance to make async tasks happen sequentially.
  FlexQueue _flexQueue = FlexQueue();

  // Observer instance.
  EnhancedEventEmitter _observer = EnhancedEventEmitter();

  Function producerCallback;
  Function consumerCallback;
  Function dataProducerCallback;
  Function dataConsumerCallback;

  /// @emits connect - (transportLocalParameters: any, callback: Function, errback: Function)
  /// @emits connectionstatechange - (connectionState: ConnectionState)
  /// @emits produce - (producerLocalParameters: any, callback: Function, errback: Function)
  /// @emits producedata - (dataProducerLocalParameters: any, callback: Function, errback: Function)
  Transport({
    Direction direction,
    String id,
    IceParameters iceParameters,
    List<IceCandidate> iceCandidates,
    DtlsParameters dtlsParameters,
    SctpParameters sctpParameters,
    List<RTCIceServer> iceServers,
    RTCIceTransportPolicy iceTransportPolicy,
    Map<String, dynamic> additionalSettings,
    Map<String, dynamic> proprietaryConstraints,
    Map<String, dynamic> appData,
    ExtendedRtpCapabilities extendedRtpCapabilities,
    CanProduceByKind canProduceByKind,
    this.producerCallback,
    this.consumerCallback,
    this.dataProducerCallback,
    this.dataConsumerCallback,
  }) : super() {
    _logger.debug('constructor() [id:$id, direction:${direction.value}]');

    _id = id;
    _direction = direction;
    _extendedRtpCapabilities = extendedRtpCapabilities;
    _canProduceByKind = canProduceByKind;
    _maxSctpMessageSize =
        sctpParameters != null ? sctpParameters.maxMessageSize : null;

    // Clone and sanitize additionalSettings.
    additionalSettings = Map<String, dynamic>.of(additionalSettings);

    additionalSettings.remove('iceServers');
    additionalSettings.remove('iceTransportPolicy');
    additionalSettings.remove('bundlePolicy');
    additionalSettings.remove('rtcpMuxPolicy');
    additionalSettings.remove('sdpSemantics');

    _handler = HandlerInterface.handlerFactory();

    _handler.run(
      options: HandlerRunOptions(
        direction: direction,
        iceParameters: iceParameters,
        iceCandidates: iceCandidates,
        dtlsParameters: dtlsParameters,
        sctpParameters: sctpParameters,
        iceServers: iceServers,
        iceTransportPolicy: iceTransportPolicy,
        additionalSettings: additionalSettings,
        proprietaryConstraints: proprietaryConstraints,
        extendedRtpCapabilities: extendedRtpCapabilities,
      ),
    );

    _appData = appData;

    _handleHandler();
  }

  void _handleHandler() {
    HandlerInterface handler = _handler;

    handler.on(
      '@connect',
      (Map data) {
        DtlsParameters dtlsParameters = data['dtlsParameters'];
        Function callback = data['callback'];
        Function errback = data['errback'];

        if (_closed) {
          errback('closed');

          return;
        }

        safeEmit('connect', {
          'dtlsParameters': dtlsParameters,
          'callback': callback,
          'errback': errback
        });
      },
    );

    handler.on(
      '@connectionstatechange',
      (Map data) {
        String connectionState = data['state'];

        if (connectionState == _connectionState) {
          return;
        }

        _logger.debug('connection state changed to $connectionState');

        _connectionState = connectionState;

        if (!_closed) {
          safeEmit('connectionstatechange', {
            'connectionState': connectionState,
          });
        }
      },
    );
  }

  /// Transport id.
  String get id => _id;

  // Whether the Transport is closed.
  bool get closed => _closed;

  // Transport direction.
  Direction get direction => _direction;

  /// RTC handler instance.
  HandlerInterface get handler => _handler;

  /// Connection state.
  String get connectionState => _connectionState;

  /// App custom data.
  Map<dynamic, dynamic> get appData => _appData;

  /// Invalid setter.
  set appData(Map<dynamic, dynamic> newAppData) {
    throw ('no.. Connot override appData object');
  }

  /// Observer.
  ///
  /// @emits close
  /// @emits newproducer - (producer: Producer)
  /// @emits newconsumer - (producer: Producer)
  /// @emits newdataproducer - (dataProducer: DataProducer)
  /// @emits newdataconsumer - (dataProducer: DataProducer)
  EnhancedEventEmitter get observer => _observer;

  /// Close the Transport.
  Future<void> close() async {
    if (_closed) {
      return;
    }

    _logger.debug('close()');

    _closed = true;

    // TODO: close task handler.

    // Close the handler.
    await _handler.close();

    // Close all Producers.
    for (Producer producer in _producers.values) {
      producer.transportClosed();
    }
    _producers.clear();

    // Close all Consumers.
    for (Consumer consumer in _consumers.values) {
      consumer.transportClosed();
    }
    _consumers.clear();

    // Close all DataProducers.
    for (DataProducer dataProducer in _dataProducers.values) {
      dataProducer.transportClosed();
    }
    _dataProducers.clear();

    // Close all DataConsumers.
    for (DataConsumer dataConsumer in _dataConsumers.values) {
      dataConsumer.transportClosed();
    }
    _dataConsumers.clear();

    // Emit observer event.
    _observer.safeEmit('close');
  }

  /// Get associated Transport (RTCPeerConnection) stats.
  ///
  /// @returns {List<StatsReport>}
  Future<List<StatsReport>> getState() async {
    if (_closed) {
      throw ('closed');
    }

    return await _handler.getTransportStats();
  }

  /// Restart ICE connection.
  void restartIce(IceParameters iceParameters) {
    _logger.debug('restartIce()');

    if (this._closed)
      throw ('closed');
    else if (iceParameters == null) throw ('missing iceParameters');

    // Enqueue command.
    _flexQueue.addTask(FlexTaskAdd(
      id: '',
      argument: iceParameters,
      execFun: _handler.restartIce,
      message: 'transport.restartIce()',
    ));
  }

  /// Update ICE servers.
  void updateIceServers(List<RTCIceServer> iceServers) {
    _logger.debug('updateIceServers()');

    if (this._closed)
      throw ('closed');
    else if (iceServers == null) throw ('missing iceServers');

    _flexQueue.addTask(FlexTaskAdd(
      id: '',
      argument: iceServers,
      execFun: _handler.updateIceServers,
      message: 'transport.updateIceServers()',
    ));
  }

  void _handleProducer(Producer producer) {
    producer.on('@close', () {
      _producers.remove(producer.id);

      if (_closed) {
        return;
      }

      _flexQueue.addTask(FlexTaskRemove(
        id: producer.id,
        argument: producer.localId,
        execFun: _handler.stopSending,
        message: 'producer @close event',
        errorCallbackFun: (error) =>
            _logger.warn('producer.close() failed:${error.toString()}'),
      ));
    });

    producer.on('@replacetrack',
        (MediaStreamTrack track, Function callback, Function errback) {
      _flexQueue.addTask(FlexTaskAdd(
        id: '',
        argument: ReplaceTrackOptions(localId: producer.localId, track: track),
        callbackFun: callback,
        errorCallbackFun: errback,
        execFun: _handler.replaceTrack,
        message: 'producer @replacetrack event',
      ));
    });

    producer.on('@setmaxspatiallayer', (spatialLayer, callback, errback) {
      _flexQueue.addTask(FlexTaskAdd(
        id: '',
        argument: SetMaxSpatialLayerOptions(
            localId: producer.localId, spatialLayer: spatialLayer),
        callbackFun: callback,
        errorCallbackFun: errback,
        execFun: _handler.setMaxSpatialLayer,
        message: 'producer @setmaxspatiallayer event',
      ));
    });

    producer.on('@setrtpencodingparameters', (params, callback, errback) {
      _flexQueue.addTask(FlexTaskAdd(
        id: '',
        argument: SetRtpEncodingParametersOptions(
            localId: producer.localId, params: params),
        execFun: _handler.setRtpEncodingParameters,
        callbackFun: callback,
        errorCallbackFun: errback,
        message: 'producer @setrtpencodingparameters event',
      ));
    });

    producer.on('@getstats', (callback, errback) {
      if (_closed) {
        return errback(Error.safeToString('close'));
      }

      _handler
          .getSenderStats(producer.localId)
          .then(callback)
          .catchError(errback);
    });
  }

  void _handleConsumer(Consumer consumer) {
    consumer.on('@close', () {
      _consumers.remove(consumer.id);

      if (_closed) {
        return;
      }

      _flexQueue.addTask(FlexTaskRemove(
        id: consumer.id,
        argument: consumer.localId,
        execFun: _handler.stopReceiving,
        message: 'consumer @close event',
      ));
    });

    consumer.on('@getstats', (callback, errback) {
      if (_closed) {
        return errback(Error.safeToString('closed'));
      }

      _handler
          .getReceiverStats(consumer.localId)
          .then(callback)
          .catchError(errback);
    });
  }

  void _handleDataProducer(DataProducer dataProducer) {
    dataProducer.on('@close', () {
      _dataProducers.remove(dataProducer.id);
    });
  }

  void _handleDataConsumer(DataConsumer dataConsumer) {
    dataConsumer.on('@close', () {
      _dataConsumers.remove(dataConsumer.id);
    });
  }

  /// Create a Producer.
  /// use producerCallback to receive a new Producer.
  void produce({
    MediaStreamTrack track,
    MediaStream stream,
    List<RtpEncodingParameters> encodings,
    ProducerCodecOptions codecOptions,
    RtpCodecCapability codec,
    bool stopTracks = true,
    bool disableTrackOnPause = true,
    bool zeroRtpOnPause = false,
    Map<String, dynamic> appData,
    String source,
  }) {
    _logger.debug('produce() [track:${track.toString()}');

    if (track == null) {
      throw ('missing track');
    } else if (_direction != Direction.send) {
      throw ('not a sending Transport');
    } else if (!_canProduceByKind
        .canIt(RTCRtpMediaTypeExtension.fromString(track.kind))) {
      throw ('cannot produce ${track.kind}');
    } else if (listeners('connect').isEmpty && _connectionState == 'new') {
      throw ('no "connect" listener set into this transport');
    } else if (listeners('produce').isEmpty) {
      throw ('no "pruduce" listener set into this transport');
    }

    _flexQueue.addTask(FlexTaskAdd(
      id: '',
      message: 'transport.produce()',
      execFun: () async {
        try {
          List<RtpEncodingParameters> normalizedEncodings = [];

          if (encodings != null && encodings.isEmpty) {
            normalizedEncodings = null;
          } else if (encodings != null && encodings.isNotEmpty) {
            normalizedEncodings =
                encodings.map((RtpEncodingParameters encoding) {
              RtpEncodingParameters normalizedEncoding =
                  RtpEncodingParameters(active: true);

              if (encoding.active == false) {
                normalizedEncoding.active = false;
              }
              if (encoding.dtx != null) {
                normalizedEncoding.dtx = encoding.dtx;
              }
              if (encoding.scalabilityMode != null) {
                normalizedEncoding.scalabilityMode = encoding.scalabilityMode;
              }
              if (encoding.scaleResolutionDownBy != null) {
                normalizedEncoding.scaleResolutionDownBy =
                    encoding.scaleResolutionDownBy;
              }
              if (encoding.maxBitrate != null) {
                normalizedEncoding.maxBitrate = encoding.maxBitrate;
              }
              if (encoding.maxFramerate != null) {
                normalizedEncoding.maxFramerate = encoding.maxFramerate;
              }
              if (encoding.adaptivePtime != null) {
                normalizedEncoding.adaptivePtime = encoding.adaptivePtime;
              }
              if (encoding.priority != null) {
                normalizedEncoding.priority = encoding.priority;
              }
              if (encoding.networkPriority != null) {
                normalizedEncoding.networkPriority = encoding.networkPriority;
              }

              return normalizedEncoding;
            }).toList();
          }

          HandlerSendResult sendResult = await _handler.send(HandlerSendOptions(
            track: track,
            encodings: normalizedEncodings,
            codecOptions: codecOptions,
            codec: codec,
            stream: stream,
          ));

          try {
            // This will fill rtpParameters's missing fields with default values.
            Ortc.validateRtpParameters(sendResult.rtpParameters);

            String id = await safeEmitAsFuture('produce', {
              'kind': track.kind,
              'rtpParameters': sendResult.rtpParameters,
              'appData': appData,
            });

            Producer producer = Producer(
              id: id,
              localId: sendResult.localId,
              rtpSender: sendResult.rtpSender,
              track: track,
              rtpParameters: sendResult.rtpParameters,
              stopTracks: stopTracks,
              disableTrackOnPause: disableTrackOnPause,
              zeroRtpOnPause: zeroRtpOnPause,
              appData: appData,
              stream: stream,
              source: source,
            );

            _producers[producer.id] = producer;
            _handleProducer(producer);

            // Emit observer event.
            _observer.safeEmit('newProducer', {
              'producer': producer,
            });

            this?.producerCallback(producer);
          } catch (error) {
            _handler.stopSending(sendResult.localId);

            throw error;
          }
        } catch (error) {
          // This catch is needed to stop the given track if the command above
          // failed due to closed Transport.
          if (stopTracks) {
            try {
              track.stop();
            } catch (error2) {}
          }
          throw error;
        }
      },
    ));
  }

  /// Create a Consumer to consume a remote Producer.
  /// use consumerCallback to receive a new Consumer.
  void consume({
    String id,
    String producerId,
    RTCRtpMediaType kind,
    RtpParameters rtpParameters,
    Map<dynamic, dynamic> appData,
    Function accept,
  }) {
    _logger.debug('consume()');

    rtpParameters = RtpParameters.copy(rtpParameters);

    if (_closed) {
      throw ('closed');
    } else if (_direction != Direction.recv) {
      throw ('not a receiving Transport');
    } else if (id == null) {
      throw ('missing id');
    } else if (producerId == null) {
      throw ('missing producerId');
    } else if (kind != RTCRtpMediaType.RTCRtpMediaTypeAudio &&
        kind != RTCRtpMediaType.RTCRtpMediaTypeVideo) {
      throw ('invalid kind ${RTCRtpMediaTypeExtension.value(kind)}');
    } else if (listeners('connect').isEmpty && _connectionState == 'new') {
      throw ('no "connect" listener set into this transport');
    }

    _flexQueue.addTask(FlexTaskAdd(
        id: id,
        message: 'transport.consume()',
        execFun: () async {
          // Unsure the device can consume it.
          bool canConsume =
              Ortc.canReceive(rtpParameters, _extendedRtpCapabilities);

          if (!canConsume) {
            throw ('cannot consume this Producer');
          }

          HandlerReceiveResult receiveResult =
              await _handler.receive(HandlerReceiveOptions(
            trackId: id,
            kind: kind,
            rtpParameters: rtpParameters,
          ));

          Consumer consumer = Consumer(
            id: id,
            localId: receiveResult.localId,
            producerId: producerId,
            rtpParameters: rtpParameters,
            appData: Map<String, dynamic>.from(appData),
            track: receiveResult.track,
            rtpReceiver: receiveResult.rtpReceiver,
            stream: receiveResult.stream,
          );

          _consumers[consumer.id] = consumer;

          _handleConsumer(consumer);

          // If this is the first video Consumer and the Consumer for RTP probation
          // has not yet been created, create it now.
          if (!_probatorConsumerCreated &&
              kind == RTCRtpMediaType.RTCRtpMediaTypeVideo) {
            try {
              RtpParameters probatorRtpParameters =
                  Ortc.generateProbatorRtpparameters(consumer.rtpParameters);

              await _handler.receive(HandlerReceiveOptions(
                trackId: 'probator',
                kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
                rtpParameters: probatorRtpParameters,
              ));

              _logger.debug('consume() | Consumer for RTP probation created');

              _probatorConsumerCreated = true;
            } catch (error) {
              _logger.error(
                  'consume() | failed to create Consumer for RTP probation:${error.toString()}');
            }
          }

          // Emit observer event.
          _observer.safeEmit('newconsumer', {'consumer': consumer});

          consumerCallback(consumer, accept);
        }));
  }

  /// Create a DataProducer
  /// use dataProducerCallback to receive a new ProducerData.
  void produceData({
    bool ordered = true,
    int maxPacketLife,
    int maxRetransmits,
    Priority priority = Priority.Low,
    String label = '',
    String protocol = '',
    Map<dynamic, dynamic> appData,
  }) {
    _logger.debug('produceData()');

    if (_direction != Direction.send) {
      throw ('not a sending Transport');
    } else if (_maxSctpMessageSize == null) {
      throw ('SCTP not enabled by remote Transport');
    } else if (priority == null) {
      throw ('wrong priority');
    } else if (listeners('connect').isEmpty && _connectionState == 'new') {
      throw ('no "connect" listener set into this transport');
    } else if (listeners('producedata').isEmpty) {
      throw ('no "producedata" listener set into this transport');
    }

    if (maxPacketLife != null || maxRetransmits != null) {
      ordered = false;
    }

    // Enqueue command.
    _flexQueue.addTask(FlexTaskAdd(
        id: '',
        execFun: () async {
          HandlerSendDataChannelResult sendDataResult =
              await _handler.sendDataChannel(SctpStreamParameters(
            ordered: ordered,
            maxPacketLifeTime: maxPacketLife,
            maxRetransmits: maxRetransmits,
            priority: priority,
            label: label,
            protocol: protocol,
          ));

          // This will fill sctpStreamParameters's missing fields with default values.
          Ortc.validateSctpStreamParameters(
              sendDataResult.sctpStreamParameters);

          String id = await safeEmitAsFuture('producedata', {
            'sctpStreamParameters': sendDataResult.sctpStreamParameters,
            'label': label,
            'protocol': protocol,
            'appData': appData,
          });

          DataProducer dataProducer = DataProducer(
            id: id,
            dataChannel: sendDataResult.dataChannel,
            sctpStreamParameters: sendDataResult.sctpStreamParameters,
            appData: appData,
          );

          _dataProducers[dataProducer.id] = dataProducer;
          _handleDataProducer(dataProducer);

          // Emit observer event.
          _observer.safeEmit('newdataproducer', {
            'dataProducer': dataProducer,
          });

          dataProducerCallback(dataProducer);
        }));
  }

  // Create a DataConsumer
  // use dataConsuemrCallback to receive a new DataConsumer.
  void consumeData({
    String id,
    String dataProducerId,
    SctpStreamParameters sctpStreamParameters,
    String label = '',
    String protocol = '',
    Map<dynamic, dynamic> appData,
  }) {
    _logger.debug('consumeData()');

    sctpStreamParameters = SctpStreamParameters.copy(sctpStreamParameters);

    if (_closed) {
      throw ('closed');
    } else if (_direction != Direction.recv) {
      throw ('not a receiving Transport');
    } else if (_maxSctpMessageSize == null) {
      throw ('SCTP not enabled by remote Transport');
    } else if (id == null) {
      throw ('missing id');
    } else if (dataProducerId == null) {
      throw ('missing dataProducerId');
    } else if (listeners('connect').isEmpty && _connectionState == 'new') {
      throw ('no "connect" listener set into this transport');
    }

    // This may throw.
    Ortc.validateSctpStreamParameters(sctpStreamParameters);

    // Enqueue command.

    _flexQueue.addTask(FlexTaskAdd(
      id: id,
      message: 'transport.consumeData()',
      execFun: () async {
        HandlerReceiveDataChannelResult receiveDataChannelResult =
            await _handler.receiveDataChannel(HandlerReceiveDataChannelOptions(
          sctpStreamParameters: sctpStreamParameters,
          label: label,
          protocol: protocol,
        ));

        DataConsumer dataConsumer = DataConsumer(
            id: id,
            dataProducerId: dataProducerId,
            dataChannel: receiveDataChannelResult.dataChannel,
            sctpStreamParameters: sctpStreamParameters,
            appData: appData);

        _dataConsumers[dataConsumer.id] = dataConsumer;
        _handleDataConsumer(dataConsumer);

        // Emit observer event.
        _observer.safeEmit('newdataconsumer', {
          'dataConsumer': dataConsumer,
        });

        dataConsumerCallback(dataConsumer);
      },
    ));
  }
}
