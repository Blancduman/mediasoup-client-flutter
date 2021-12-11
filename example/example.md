```
import 'package:mediasoup_client_flutter/mediasoup_client_flutter.dart';
import 'package:flutter_webrtc/flutter_webrtc';
import 'package:my_project/my_signaling.dart';

// Create a device.
final device = Device();

// Communicate with server app to retrieve router RTP capabilities.
final Map<String, dynamic> routerRtpCapabilities = await mySignaling.request('getRouterCapabilities');

// Load the device with the router RTP capabilities.
final rtpCapabilities = RtpCapabilities.fromMap(routerRtpCapabilities);
await device.load(routerRtpCapabilities: rtpCapabilities);

// Check wheter we can produce video to the router.
if (!device.canProduce(RTCRtpMediaType.RTCRtpMediaTypeVideo)) {
    print('cannot produce video');
    // Abort next steps.
}

// Create a transport in the server for sending our media through it.
final Map transportInfo = await mySignaling.request('createTransport', {
    'forceTcp': false,
    'producing': true,
    'consuming': false,
    'sctpCapabilities': device.sctpCapabilities.toMap(),
});

// Create a callback for producers.
void _producerCallback(Producer producer) {
    /* Your code. */
}

final sendTransport = device.createSendTransportFromMap(
    transportInfo,
    producerCallback: _producerCallback,
);

// Set transport "connect" event handler.
sendTransport.on('connect', (Map data) {
// Here we must communicate our local parameters to our remote transport.
mySignaling.request('transport-connect', {
    'transportId': _sendTransport.id,
    'dtlsParameters': data['dtlsParameters'].toMap(),
})
// Done in the server, tell our transport.
.then(data['callback'])
// Something was wrong in server side.
.catchError(data['errback']);
});

// Set transport "produce" event handler.
_sendTransport.on('produce', (Map data) async {
// Here we must communicate our local parameters to our remote transport.
    try {
        Map response = await mySignaling.request(
            'produce',
            {
                'transportId': sendTransport.id,
                'kind': data['kind'],
                'rtpParameters': data['rtpParameters'].toMap(),
                if (data['appData'] != null)
                'appData': Map<String, dynamic>.from(data['appData'])
            },
        );
        // Done in the server, pass the response to our transport.
        data['callback'](response['id']);
    } catch (error) {
        // Something was wrong in server side.
        data['errback'](error);
    }
});

// Produce our webcam video.
Map<String, dynamic> mediaConstraints = <String, dynamic>{
    'audio': false,
    'video': {
        'mandatory': {
            // Provide your own width, height and frame rate here.
            'minWidth': '1280',
            'minHeight': '720',
            'minFrameRate': '30',
        },
    },
};

final MediaStream stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
final MediaStreamTrack track = stream.getVideoTracks().first;
sendTransport.produce(
    stream: stream,
    track: track,
    source: 'webcam',
);
// Producer will return through _producerCallback.
```