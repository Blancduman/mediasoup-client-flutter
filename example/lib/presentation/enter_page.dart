import 'package:example/logic/blocs/media_devices/media_devices_bloc.dart';
import 'package:example/presentation/components/list_media_devices/list_media_devices.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EnterPage extends StatefulWidget {
  static const String RoutePath = '/';

  @override
  _EnterPageState createState() => _EnterPageState();
}

class _EnterPageState extends State<EnterPage> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _textEditingController.addListener(() {
      final String text = _textEditingController.text.toLowerCase();
      setState(() {
        _textEditingController.value = _textEditingController.value.copyWith(
          text: text,
          // selection: TextSelection(
          //   baseOffset: text.length,
          //   extentOffset: text.length,
          // ),
          // composing: TextRange.empty,
        );
      });
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('mediasoup-client-flutter'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            TextField(
              autofocus: false,
              controller: _textEditingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: 'Room url (empty = random room)',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/room',
                  arguments: _textEditingController.value.text.toLowerCase(),
                );
              },
              child: Text('Join'),
            ),
            Text(
              'Audio Input',
              style: Theme.of(context).textTheme.headline5,
            ),
            Builder(
              builder: (context) {
                final List<MediaDeviceInfo> audioInputDevices = context
                    .select((MediaDevicesBloc bloc) => bloc.state.audioInputs);
                final MediaDeviceInfo selectedAudioInput = context.select(
                    (MediaDevicesBloc bloc) => bloc.state.selectedAudioInput);

                return ListMediaDevices(
                  key: Key('audioinput'),
                  selectedDevice: selectedAudioInput,
                  devices: audioInputDevices,
                  onSelect: (MediaDeviceInfo device) => context
                      .read<MediaDevicesBloc>()
                      .add(MediaDeviceSelectAudioInput(device)),
                );
              },
            ),
            Text(
              'Audio Output',
              style: Theme.of(context).textTheme.headline5,
            ),
            Builder(
              builder: (context) {
                final List<MediaDeviceInfo> audioOutputDevices = context
                    .select((MediaDevicesBloc bloc) => bloc.state.audioOutputs);
                final MediaDeviceInfo selectedAudioOutput = context.select(
                        (MediaDevicesBloc bloc) => bloc.state.selectedAudioOutput);

                return ListMediaDevices(
                  key: Key('audiooutput'),
                  selectedDevice: selectedAudioOutput,
                  devices: audioOutputDevices,
                  onSelect: (MediaDeviceInfo device) => context
                      .read<MediaDevicesBloc>()
                      .add(MediaDeviceSelectAudioOutput(device)),
                );
              },
            ),
            Text(
              'Video Input',
              style: Theme.of(context).textTheme.headline5,
            ),
            Builder(
              builder: (context) {
                final List<MediaDeviceInfo> videoInputDevices = context
                    .select((MediaDevicesBloc bloc) => bloc.state.videoInputs);
                final MediaDeviceInfo selectedVideoInput = context.select(
                        (MediaDevicesBloc bloc) => bloc.state.selectedVideoInput);

                return ListMediaDevices(
                  key: Key('videoinput'),
                  selectedDevice: selectedVideoInput,
                  devices: videoInputDevices,
                  onSelect: (MediaDeviceInfo device) => context
                      .read<MediaDevicesBloc>()
                      .add(MediaDeviceSelectVideoInput(device)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
