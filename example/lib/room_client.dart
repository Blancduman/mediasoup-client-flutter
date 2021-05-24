import 'dart:async';

import 'package:example/web_socket.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mediasoup_client_flutter/mediasoup_client_flutter.dart';

class RoomClient {
  final String roomId;
  final String peerId;
  final String url;
  final String displayName;

  bool _closed = false;

  WebSocket _webSocket;
  Device _mediasoupDevice;
  Transport _sendTransport;
  Transport _recvTransport;
  Producer _micProducer;
  Producer _webcamProducer;
  Producer _shareProducer;
  DataProducer _chatDataProducer;
  DataProducer _botDataProducer;
  Map<String, Consumer> _consumers = {};
  Map<String, DataConsumer> _dataConsumers = {};
  Map<String, MediaDeviceInfo> _webcams = {};
  bool _produce = false;
  bool _consume = true;

  Function(Consumer consumer) onConsumer;

  RoomClient({
    this.roomId,
    this.peerId,
    this.url,
    this.displayName,
    this.onConsumer
  });

  void close() {
    if (_closed) {
      return;
    }

    _webSocket.close();
    _sendTransport?.close();
    _recvTransport?.close();
  }

  Future<void> disableMic() async {
    if (_micProducer == null) {
      return;
    }

    _micProducer.close();

    try {
      await _webSocket.socket.request('closeProducer', {
        'producerId': _micProducer.id,
      });
    } catch (error) {}
    _micProducer = null;
  }

  void _producerCallback(Producer producer) {
    if (producer.source == 'mic') {
      _micProducer = producer;

      _micProducer.on('transportclose', () {
        // _micProducer.stream.dispose();
        _micProducer = null;
      });

      _micProducer.on('trackended', () {
        disableMic().catchError(() {});
      });
    } else {
      _webcamProducer = producer;

      _webcamProducer.on('transportclose', () {
        _webcamProducer = null;
      });

      _webcamProducer.on('trackended', () {});
    }
  }

  void _consumerCallback(dynamic consumer, dynamic accept) {
    _consumers[consumer.id] = consumer;

    consumer.on('transportclose', () {
      _consumers.remove(consumer.id);
    });

    ScalabilityMode scalabilityMode = ScalabilityMode.parse(
        consumer.rtpParameters.encodings.first.scalabilityMode);

    onConsumer(consumer);
    accept({});
  }

  Future<MediaStream> createAudioStream() async {
    Map<String, dynamic> mediaConstraints = {
      'audio': true,
    };

    MediaStream stream =
        await navigator.mediaDevices.getUserMedia(mediaConstraints);

    return stream;
  }

  Future<MediaStream> createVideoStream() async {
    Map<String, dynamic> mediaConstraints = <String, dynamic>{
      'audio': false,
      'video': {
        'mandatory': {
          'minWidth':
              '1280', // Provide your own width, height and frame rate here
          'minHeight': '720',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      },
    };

    MediaStream stream =
        await navigator.mediaDevices.getUserMedia(mediaConstraints);

    return stream;
  }

  void enableChatDataProducer() {}

  void enableBotDataProducer() {}

  Future<void> _joinRoom() async {
    try {
      _mediasoupDevice = Device();

      dynamic routerRtpCapabilities =
          await _webSocket.socket.request('getRouterRtpCapabilities', {});

      print(routerRtpCapabilities);

      final rtpCapabilities = RtpCapabilities.fromMap(routerRtpCapabilities);
      await _mediasoupDevice.load(routerRtpCapabilities: rtpCapabilities);

      if (_mediasoupDevice.canProduce(RTCRtpMediaType.RTCRtpMediaTypeAudio) ||
          _mediasoupDevice.canProduce(RTCRtpMediaType.RTCRtpMediaTypeVideo)) {
        _produce = true;
      }

      if (_produce) {
        Map transportInfo =
            await _webSocket.socket.request('createWebRtcTransport', {
          'forceTcp': false,
          'producing': true,
          'consuming': false,
          'sctpCapabilities': _mediasoupDevice.sctpCapabilities.toMap(),
        });

        _sendTransport = _mediasoupDevice.createSendTransportFromMap(
          transportInfo,
          producerCallback: _producerCallback,
        );

        _sendTransport.on('connect', (Map data) {
          _webSocket.socket
              .request('connectWebRtcTransport', {
                'transportId': _sendTransport.id,
                'dtlsParameters': data['dtlsParameters'].toMap(),
              }).then(data['callback'])
              .catchError(data['errback']);
        });

        _sendTransport.on('produce', (Map data) async {
          try {
            Map response = await _webSocket.socket.request(
              'produce',
              {
                'transportId': _sendTransport.id,
                'kind': data['kind'],
                'rtpParameters': data['rtpParameters'].toMap(),
                'appData': Map<String, dynamic>.from(data['appData'])
              },
            );

            // return response['id'];

            data['callback'](response['id']);
          } catch (error) {
            data['errback'](error);
          }
        });

        _sendTransport.on('producedata', (data) async {
          try {
            Map response = await _webSocket.socket.request('produceData', {
              'transportId': _sendTransport.id,
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
        Map transportInfo = await _webSocket.socket.request(
          'createWebRtcTransport',
          {
            'forceTcp': false,
            'producing': false,
            'consuming': true,
            'sctpCapabilities': _mediasoupDevice.sctpCapabilities.toMap(),
          },
        );

        _recvTransport = _mediasoupDevice.createRecvTransportFromMap(
          transportInfo,
          consumerCallback: _consumerCallback,
        );

        _recvTransport.on(
          'connect',
          (data) {
            _webSocket.socket
                .request(
                  'connectWebRtcTransport',
                  {
                    'transportId': _recvTransport.id,
                    'dtlsParameters': data['dtlsParameters'].toMap(),
                  },
                )
                .then(data['callback'])
                .catchError(data['errback']);
          },
        );
      }

      Map peers = await _webSocket.socket.request('join', {
        'displayName': displayName,
        'device': "It's flutter boy",
        'rtpCapabilities': _mediasoupDevice.rtpCapabilities.toMap(),
        'sctpCapabilities': _mediasoupDevice.sctpCapabilities.toMap(),
      });

      if (_produce) {
        if (_mediasoupDevice.canProduce(RTCRtpMediaType.RTCRtpMediaTypeVideo)) {
          MediaStream videoStream;
          MediaStreamTrack track;
          try {
            RtpCodecCapability codec = _mediasoupDevice.rtpCapabilities.codecs
                .firstWhere(
                    (RtpCodecCapability c) =>
                        c.mimeType.toLowerCase() == 'video/vp9',
                    orElse: () =>
                        throw 'desired H264 codec+configuration is not supported');
            videoStream = await createVideoStream();
            track = videoStream.getVideoTracks().first;
            _sendTransport.produce(
              track: track,
              codecOptions: ProducerCodecOptions(
                videoGoogleStartBitrate: 1000,
              ),
              encodings: [
                RtpEncodingParameters(scalabilityMode: 'S3T3_KEY'),
              ],
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
        if (_mediasoupDevice.canProduce(RTCRtpMediaType.RTCRtpMediaTypeAudio)) {
          MediaStream audioStream;
          MediaStreamTrack track;
          try {
            audioStream = await createAudioStream();
            track = audioStream.getAudioTracks().first;
            _sendTransport.produce(
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

        _sendTransport.on('connectionstatechange', (connectionState) {
          if (connectionState == 'connected') {
            enableChatDataProducer();
            enableBotDataProducer();
          }
        });
      }
    } catch (error) {
      print(error);
      close();
    }
  }

  Future<void> join() {
    _webSocket = WebSocket(
      peerId: peerId,
      roomId: roomId,
      url: url,
    );

    _webSocket.onOpen = _joinRoom;
    _webSocket.onFail = () {
      print('WebSocket connection failed');
    };
    _webSocket.onDisconnected = () {
      if (_sendTransport != null) {
        _sendTransport.close();
        _sendTransport = null;
      }
      if (_recvTransport != null) {
        _recvTransport.close();
        _recvTransport = null;
      }
    };
    _webSocket.onClose = () {
      if (_closed) return;

      close();
    };

    _webSocket.onRequest = (request, accept, reject) async {
      switch (request['method']) {
        case 'newConsumer':
          {
            if (!_consume) {
              reject(403, 'I do not want to consume');
              break;
            }
            try {
              _recvTransport.consume(
                id: request['data']['id'],
                producerId: request['data']['producerId'],
                kind: RTCRtpMediaTypeExtension.fromString(
                    request['data']['kind']),
                rtpParameters:
                    RtpParameters.fromMap(request['data']['rtpParameters']),
                appData: Map<dynamic, dynamic>.from(request['data']['appData']),
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
  }
}
