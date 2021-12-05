import 'dart:async';

import 'package:example/features/me/bloc/me_bloc.dart';
import 'package:example/features/media_devices/bloc/media_devices_bloc.dart';
import 'package:example/features/peers/bloc/peers_bloc.dart';
import 'package:example/features/producers/bloc/producers_bloc.dart';
import 'package:example/features/room/bloc/room_bloc.dart';
import 'package:example/features/signaling/web_socket.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mediasoup_client_flutter/mediasoup_client_flutter.dart';

class RoomClientRepository {
  final ProducersBloc producersBloc;
  final PeersBloc peersBloc;
  final MeBloc meBloc;
  final RoomBloc roomBloc;
  final MediaDevicesBloc mediaDevicesBloc;

  final String roomId;
  final String peerId;
  final String url;
  final String displayName;

  bool _closed = false;

  WebSocket? _webSocket;
  Device? _mediasoupDevice;
  Transport? _sendTransport;
  Transport? _recvTransport;
  bool _produce = false;
  bool _consume = true;
  StreamSubscription<MediaDevicesState>? _mediaDevicesBlocSubscription;
  String? audioInputDeviceId;
  String? audioOutputDeviceId;
  String? videoInputDeviceId;

  RoomClientRepository({
    required this.producersBloc,
    required this.peersBloc,
    required this.meBloc,
    required this.roomBloc,
    required this.roomId,
    required this.peerId,
    required this.url,
    required this.displayName,
    required this.mediaDevicesBloc,
  }) {
    _mediaDevicesBlocSubscription =
        mediaDevicesBloc.stream.listen((MediaDevicesState state) async {
      if (state.selectedAudioInput != null &&
          state.selectedAudioInput?.deviceId != audioInputDeviceId) {
        await disableMic();
        enableMic();
      }

      if (state.selectedVideoInput != null &&
          state.selectedVideoInput?.deviceId != videoInputDeviceId) {
        await disableWebcam();
        enableWebcam();
      }
    });
  }

  void close() {
    if (_closed) {
      return;
    }

    _webSocket?.close();
    _sendTransport?.close();
    _recvTransport?.close();
    _mediaDevicesBlocSubscription?.cancel();
  }

  Future<void> disableMic() async {
    String micId = producersBloc.state.mic!.id;

    producersBloc.add(ProducerRemove(source: 'mic'));

    try {
      await _webSocket!.socket.request('closeProducer', {
        'producerId': micId,
      });
    } catch (error) {}
  }

  Future<void> disableWebcam() async {
    meBloc.add(MeSetWebcamInProgress(progress: true));
    String webcamId = producersBloc.state.webcam!.id;

    producersBloc.add(ProducerRemove(source: 'webcam'));

    try {
      await _webSocket!.socket.request('closeProducer', {
        'producerId': webcamId,
      });
    } catch (error) {} finally {
      meBloc.add(MeSetWebcamInProgress(progress: false));
    }
  }

  Future<void> muteMic() async {
    producersBloc.add(ProducerPaused(source: 'mic'));

    try {
      await _webSocket!.socket.request('pauseProducer', {
        'producerId': producersBloc.state.mic!.id,
      });
    } catch (error) {}
  }

  Future<void> unmuteMic() async {
    producersBloc.add(ProducerResumed(source: 'mic'));

    try {
      await _webSocket!.socket.request('resumeProducer', {
        'producerId': producersBloc.state.mic!.id,
      });
    } catch (error) {}
  }

  void _producerCallback(Producer producer) {
    if (producer.source == 'mic') {
      producer.on('transportclose', () {
        producersBloc.add(ProducerRemove(source: 'mic'));
      });

      producer.on('trackended', () {
        disableMic().catchError((data) {});
      });
    } else if (producer.source == 'webcam') {
      producer.on('transportclose', () {
        producersBloc.add(ProducerRemove(source: 'webcam'));
      });

      producer.on('trackended', () {
        disableWebcam().catchError((data) {});
      });
      meBloc.add(MeSetWebcamInProgress(progress: false));
    }

    producersBloc.add(ProducerAdd(producer: producer));
  }

  void _consumerCallback(Consumer consumer, [dynamic accept]) {
    // consumer.on('transportclose', () {
    //   // consumersBloc.add(ConsumerRemove(consumerId: consumer.id));
    // });

    ScalabilityMode scalabilityMode = ScalabilityMode.parse(
        consumer.rtpParameters.encodings.first.scalabilityMode);

    accept({});

    peersBloc.add(PeerAddConsumer(peerId: consumer.peerId, consumer: consumer));
  }

  Future<MediaStream> createAudioStream() async {
    audioInputDeviceId = mediaDevicesBloc.state.selectedAudioInput!.deviceId;
    Map<String, dynamic> mediaConstraints = {
      'audio': {
        'optional': [
          {
            'sourceId': audioInputDeviceId,
          },
        ],
      },
    };

    MediaStream stream =
        await navigator.mediaDevices.getUserMedia(mediaConstraints);

    return stream;
  }

  Future<MediaStream> createVideoStream() async {
    videoInputDeviceId = mediaDevicesBloc.state.selectedVideoInput!.deviceId;
    Map<String, dynamic> mediaConstraints = <String, dynamic>{
      'audio': false,
      'video': {
        'mandatory': {
          'minWidth':
              '1280', // Provide your own width, height and frame rate here
          'minHeight': '720',
          'minFrameRate': '30',
        },
        'optional': [
          {
            'sourceId': videoInputDeviceId,
          },
        ],
      },
    };

    MediaStream stream =
        await navigator.mediaDevices.getUserMedia(mediaConstraints);

    return stream;
  }

  void enableWebcam() async {
    if (meBloc.state.webcamInProgress) {
      return;
    }
    meBloc.add(MeSetWebcamInProgress(progress: true));
    if (_mediasoupDevice!.canProduce(RTCRtpMediaType.RTCRtpMediaTypeVideo) == false) {
      return;
    }
    MediaStream? videoStream;
    MediaStreamTrack? track;
    try {
      // NOTE: prefer using h264
      final videoVPVersion = kIsWeb ? 9 : 8;
      RtpCodecCapability? codec = _mediasoupDevice!.rtpCapabilities.codecs
          .firstWhere(
              (RtpCodecCapability c) => c.mimeType.toLowerCase() == 'video/vp$videoVPVersion',
              orElse: () =>
                  throw 'desired vp$videoVPVersion codec+configuration is not supported');
      videoStream = await createVideoStream();
      track = videoStream.getVideoTracks().first;
      meBloc.add(MeSetWebcamInProgress(progress: true));
      _sendTransport!.produce(
        track: track,
        codecOptions: ProducerCodecOptions(
          videoGoogleStartBitrate: 1000,
        ),
        encodings: kIsWeb ? [
          RtpEncodingParameters(scalabilityMode: 'S3T3_KEY', scaleResolutionDownBy: 1.0),
        ] : [],
        stream: videoStream,
        appData: {
          'source': 'webcam',
        },
        source: 'webcam',
        codec: codec,
      );
    } catch (error) {
      if (videoStream != null) {
        await videoStream.dispose();
      }
    }
  }

  void enableMic() async {
    if (_mediasoupDevice!.canProduce(RTCRtpMediaType.RTCRtpMediaTypeAudio) == false) {
      return;
    }

    MediaStream? audioStream;
    MediaStreamTrack? track;
    try {
      audioStream = await createAudioStream();
      track = audioStream.getAudioTracks().first;
      _sendTransport!.produce(
        track: track,
        codecOptions: ProducerCodecOptions(opusStereo: 1, opusDtx: 1),
        stream: audioStream,
        appData: {
          'source': 'mic',
        },
        source: 'mic',
      );
    } catch (error) {
      if (audioStream != null) {
        await audioStream.dispose();
      }
    }
  }

  Future<void> _joinRoom() async {
    try {
      _mediasoupDevice = Device();

      dynamic routerRtpCapabilities =
          await _webSocket!.socket.request('getRouterRtpCapabilities', {});

      print(routerRtpCapabilities);

      final rtpCapabilities = RtpCapabilities.fromMap(routerRtpCapabilities);
      rtpCapabilities.headerExtensions.removeWhere((he) => he.uri == 'urn:3gpp:video-orientation');
      await _mediasoupDevice!.load(routerRtpCapabilities: rtpCapabilities);

      if (_mediasoupDevice!.canProduce(RTCRtpMediaType.RTCRtpMediaTypeAudio) == true ||
          _mediasoupDevice!.canProduce(RTCRtpMediaType.RTCRtpMediaTypeVideo) == true) {
        _produce = true;
      }

      if (_produce) {
        Map transportInfo =
            await _webSocket!.socket.request('createWebRtcTransport', {
          'forceTcp': false,
          'producing': true,
          'consuming': false,
          'sctpCapabilities': _mediasoupDevice!.sctpCapabilities.toMap(),
        });

        _sendTransport = _mediasoupDevice!.createSendTransportFromMap(
          transportInfo,
          producerCallback: _producerCallback,
        );

        _sendTransport!.on('connect', (Map data) {
          _webSocket!.socket
              .request('connectWebRtcTransport', {
                'transportId': _sendTransport!.id,
                'dtlsParameters': data['dtlsParameters'].toMap(),
              })
              .then(data['callback'])
              .catchError(data['errback']);
        });

        _sendTransport!.on('produce', (Map data) async {
          try {
            Map response = await _webSocket!.socket.request(
              'produce',
              {
                'transportId': _sendTransport!.id,
                'kind': data['kind'],
                'rtpParameters': data['rtpParameters'].toMap(),
                if (data['appData'] != null)
                  'appData': Map<String, dynamic>.from(data['appData'])
              },
            );

            data['callback'](response['id']);
          } catch (error) {
            data['errback'](error);
          }
        });

        _sendTransport!.on('producedata', (data) async {
          try {
            Map response = await _webSocket!.socket.request('produceData', {
              'transportId': _sendTransport!.id,
              'sctpStreamParameters': data['sctpStreamParameters'].toMap(),
              'label': data['label'],
              'protocol': data['protocol'],
              'appData': data['appData'],
            });

            data['callback'](response['id']);
          } catch (error) {
            data['errback'](error);
          }
        });
      }

      if (_consume) {
        Map transportInfo = await _webSocket!.socket.request(
          'createWebRtcTransport',
          {
            'forceTcp': false,
            'producing': false,
            'consuming': true,
            'sctpCapabilities': _mediasoupDevice!.sctpCapabilities.toMap(),
          },
        );

        _recvTransport = _mediasoupDevice!.createRecvTransportFromMap(
          transportInfo,
          consumerCallback: _consumerCallback,
        );

        _recvTransport!.on(
          'connect',
          (data) {
            _webSocket!.socket
                .request(
                  'connectWebRtcTransport',
                  {
                    'transportId': _recvTransport!.id,
                    'dtlsParameters': data['dtlsParameters'].toMap(),
                  },
                ).then(data['callback'])
                .catchError(data['errback']);
          },
        );
      }

      Map response = await _webSocket!.socket.request('join', {
        'displayName': displayName,
        'device': {
          'name': "Flutter",
          'flag': 'flutter',
          'version': '0.8.0',
        },
        'rtpCapabilities': _mediasoupDevice!.rtpCapabilities.toMap(),
        'sctpCapabilities': _mediasoupDevice!.sctpCapabilities.toMap(),
      });

      response['peers'].forEach((value) {
        peersBloc.add(PeerAdd(newPeer: value));
      });

      if (_produce) {
        enableMic();
        enableWebcam();

        _sendTransport!.on('connectionstatechange', (connectionState) {
          if (connectionState == 'connected') {
            // enableChatDataProducer();
            // enableBotDataProducer();
          }
        });
      }
    } catch (error) {
      print(error);
      close();
    }
  }

  void join() {
    _webSocket = WebSocket(
      peerId: peerId,
      roomId: roomId,
      url: url,
    );

    _webSocket!.onOpen = _joinRoom;
    _webSocket!.onFail = () {
      print('WebSocket connection failed');
    };
    _webSocket!.onDisconnected = () {
      if (_sendTransport != null) {
        _sendTransport!.close();
        _sendTransport = null;
      }
      if (_recvTransport != null) {
        _recvTransport!.close();
        _recvTransport = null;
      }
    };
    _webSocket!.onClose = () {
      if (_closed) return;

      close();
    };

    _webSocket!.onRequest = (request, accept, reject) async {
      switch (request['method']) {
        case 'newConsumer':
          {
            if (!_consume) {
              reject(403, 'I do not want to consume');
              break;
            }
            try {
              _recvTransport!.consume(
                id: request['data']['id'],
                producerId: request['data']['producerId'],
                kind: RTCRtpMediaTypeExtension.fromString(
                    request['data']['kind']),
                rtpParameters:
                    RtpParameters.fromMap(request['data']['rtpParameters']),
                appData: Map<String, dynamic>.from(request['data']['appData']),
                peerId: request['data']['peerId'],
                accept: accept,
              );
            } catch (error) {
              print('newConsumer request failed: $error');
              throw (error);
            }
            break;
          }
        default:
          break;
      }
    };

    _webSocket!.onNotification = (notification) async {
      switch (notification['method']) {
        //TODO: todo;
        case 'producerScore':
          {
            break;
          }
        case 'consumerClosed':
          {
            String consumerId = notification['data']['consumerId'];
            peersBloc.add(PeerRemoveConsumer(consumerId: consumerId));

            break;
          }
        case 'consumerPaused':
          {
            String consumerId = notification['data']['consumerId'];
            peersBloc.add(PeerPausedConsumer(consumerId: consumerId));
            break;
          }

        case 'consumerResumed':
          {
            String consumerId = notification['data']['consumerId'];
            peersBloc.add(PeerResumedConsumer(consumerId: consumerId));
            break;
          }

        case 'newPeer':
          {
            final Map<String, dynamic> newPeer = Map<String, dynamic>.from(notification['data']);
            peersBloc.add(PeerAdd(newPeer: newPeer));
            break;
          }

        case 'peerClosed':
          {
            String peerId = notification['data']['peerId'];
            peersBloc.add(PeerRemove(peerId: peerId));
            break;
          }

        default:
          break;
      }
    };
  }
}
