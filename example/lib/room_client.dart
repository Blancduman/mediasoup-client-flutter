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

  Web_Socket _web_socket;
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

  RoomClient({this.roomId, this.peerId, this.url, this.displayName,});

  void close() {
    if (_closed) {
      return;
    }

    _web_socket.close();
    _sendTransport?.close();
    _recvTransport?.close();
  }

  Future<void> disableMic() async {
    if (_micProducer == null) {
      return;
    }

    _micProducer.close();

    try {
      await _web_socket.sendRequest({
        'method': 'closeProducer',
        'data': {
          'producerId': _micProducer.id,
        }
      });
    } catch (error) {

    }
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
    }
  }

  void _consumerCallback(Consumer consumer) {

  }

  Future<MediaStream> createAudioStream() async {
    Map<String, dynamic> mediaConstraints = {
      'audio': true,
    };

    MediaStream stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

    return stream;
  }

  Future<MediaStream> createVideoStream() async {
    Map<String, dynamic> mediaConstraints = {
      'audio': false,
      'video': {
        'mandatory': {
          'minWidth': '320',
          'minHeight': '240',
          'minFrameRate': '15',
        },
        'facingMode': 'user',
      },
    };

    MediaStream stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

    return stream;
  }

  void enableChatDataProducer() {

  }

  void enableBotDataProducer() {

  }

  Future<void> _joinRoom() async {
    try {
      _mediasoupDevice = Device();

      Map routerRtpCapabilities = await _web_socket.sendRequestWithResponse({
        'method': 'getRouterRtpCapabilities',
      });

      RtpCapabilities rtpCapabilities = RtpCapabilities.fromMap(routerRtpCapabilities);
      _mediasoupDevice.load(routerRtpCapabilities: rtpCapabilities);

      if (_mediasoupDevice.canProduce(RTCRtpMediaType.RTCRtpMediaTypeAudio) || _mediasoupDevice.canProduce(RTCRtpMediaType.RTCRtpMediaTypeVideo)) {
        _produce = true;
      }

      if (_produce) {
        Map transportInfo = await _web_socket.sendRequestWithResponse({
          'method': 'createWebRtcTransport',
          'data': {
            'forceTcp': false,
            'producing': true,
            'consuming': false,
            'sctpCapabilities': _mediasoupDevice.sctpCapabilities.toMap(),
          }
        });

        _sendTransport = _mediasoupDevice.createSendTransportFromMap(
          transportInfo,
          producerCallback: _producerCallback,
        );

        _sendTransport.on('connect', (DtlsParameters dtlsParameters, callback, errback) {
          _web_socket.sendRequest({
            'method': 'connectWebRtcTransport',
            'data': {
              'transportId': _recvTransport.id,
              'dtlsParameters': dtlsParameters.toMap(),
            }
          }).then(callback).catchError(errback);
        });

        _sendTransport.on('produce', (Map<String, dynamic> data, callback, errback) async {
          try {
            Map response = await _web_socket.sendRequestWithResponse({
              'method': 'produce',
              'data': {
                'transportId': _sendTransport.id,
                'kind': RTCRtpMediaTypeExtension.value(data['kind']),
                'rtpParameters': data['rtpParameters'].toMap(),
                'appData': data['appData']
              },
            });

            callback({
              'id': response['id'],
            });
          } catch (error) {
            errback(error);
          }
        });

        _sendTransport.on('producedata', (Map<String, dynamic> data, callback, errback) async {
          try {
            Map response = await _web_socket.sendRequestWithResponse({
              'method': 'produceData',
              'data': {
                'transportId': _sendTransport.id,
                'sctpStreamParameters': data['sctpStreamParameters'].toMap(),
                'label': data['label'],
                'protocol': data['protocol'],
                'appData': data['appData'],
              }
            });

            callback({
              'id': response['id'],
            });
          } catch (error) {
            errback(error);
          }
        });
      }

      if (_consume) {
        Map transportInfo = await _web_socket.sendRequestWithResponse({
          'method': 'createWebRtcTransport',
          'data': {
            'forceTcp': false,
            'producing': false,
            'consuming': true,
            'sctpCapabilities': _mediasoupDevice.sctpCapabilities.toMap(),
          },
        });

        _recvTransport = _mediasoupDevice.createRecvTransportFromMap(
          transportInfo,
          consumerCallback: _consumerCallback,
        );

        _recvTransport.on(
          'connect',
          (Map<String, dynamic> data, callback, errback) {
            _web_socket.sendRequest({
              'method': 'connectWebRtcTransport',
              'data': {
                'transportId': _recvTransport.id,
                'dtlsParameters': data['dtlsParameters'].toMap(),
              },
            }).then(callback).catchError(errback);
          },
        );
      }

      Map peers = await _web_socket.sendRequestWithResponse({
        'method': 'join',
        'data': {
          'displayName': displayName,
          'device': "It's flutter boy",
          'rtpCapabilities': _mediasoupDevice.rtpCapabilities.toMap(),
          'sctpCapabilities': _mediasoupDevice.sctpCapabilities.toMap(),
        }
      });

      if (_produce) {
        if (_mediasoupDevice.canProduce(RTCRtpMediaType.RTCRtpMediaTypeAudio)) {
          MediaStream audioStream;
          MediaStreamTrack track;
          try {
            audioStream = await createAudioStream();
            track = audioStream.getAudioTracks().first;
            _sendTransport.produce(
              track: track,
              codecOptions: ProducerCodecOptions(
                opusStereo: 1,
                opusDtx: 1,
              ),
              stream: audioStream,
              source: 'mic',
            );
          } catch (error) {
            if (audioStream != null) {
              await audioStream.dispose();
            }
          }

          _sendTransport.on('connectionstatechange', (connectionState) {
            if (connectionState == 'connected') {
              enableChatDataProducer();
              enableBotDataProducer();
            }
          });
        }
      }
    } catch (error) {
      close();
    }
  }

  Future<void> join() {
    _web_socket = Web_Socket(
      peerId: peerId,
      roomId: roomId,
      url: url,
    );

    _web_socket.onOpen = _joinRoom;
    _web_socket.onFail = () {
      print('WebSocket connection failed');
    };
    _web_socket.onDisconnected = () {
      if (_sendTransport != null) {
        _sendTransport.close();
        _sendTransport = null;
      }
      if (_recvTransport != null) {
        _recvTransport.close();
        _recvTransport = null;
      }
    };
    _web_socket.onClose = () {
      if (_closed)
        return;

      close();
    };

    _web_socket.onRequest = (data) {
      switch(data['method']) {
        case 'newConsumer': {


          break;
        }
        default: break;
      }
    };

    _web_socket.open();
  }
}