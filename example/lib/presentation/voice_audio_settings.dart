import 'package:example/logic/blocs/media_devices/media_devices_bloc.dart';
import 'package:example/presentation/components/list_media_devices/list_media_devices.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class AudioVideoSettings extends StatefulWidget {
  const AudioVideoSettings({Key key}) : super(key: key);

  @override
  _AudioVideoSettingsState createState() => _AudioVideoSettingsState();
}

class _AudioVideoSettingsState extends State<AudioVideoSettings> {
  MediaDeviceInfo selectedAudioInput;
  MediaDeviceInfo selectedAudioOutput;
  MediaDeviceInfo selectedVideoInput;

  @override
  void initState() {
    super.initState();

    final MediaDevicesState devicesInfo = context.read<MediaDevicesBloc>().state;
    setState(() {
      selectedAudioInput = devicesInfo.selectedAudioInput;
      selectedAudioOutput = devicesInfo.selectedAudioOutput;
      selectedVideoInput = devicesInfo.selectedVideoInput;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio & Video'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                final MediaDevicesState devicesInfo = context.read<MediaDevicesBloc>().state;
                final MediaDeviceInfo audioInput = devicesInfo.selectedAudioInput;
                final MediaDeviceInfo audioOutput = devicesInfo.selectedAudioOutput;
                final MediaDeviceInfo videoInput = devicesInfo.selectedVideoInput;

                if (audioInput != selectedAudioInput) {
                  context.read<MediaDevicesBloc>().add(MediaDeviceSelectAudioInput(selectedAudioInput));
                }
                if (audioOutput != selectedAudioOutput) {
                  context.read<MediaDevicesBloc>().add(MediaDeviceSelectAudioOutput(selectedAudioOutput));
                }
                if (videoInput != selectedVideoInput) {
                  context.read<MediaDevicesBloc>().add(MediaDeviceSelectVideoInput(selectedVideoInput));
                }
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.save,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            Builder(
              builder: (context) {
                final List<MediaDeviceInfo> audioInputDevices = context
                    .select((MediaDevicesBloc bloc) => bloc.state.audioInputs);

                return ListMediaDevices(
                  key: Key('audioinput'),
                  selectedDevice: selectedAudioInput,
                  devices: audioInputDevices,
                  onSelect: (MediaDeviceInfo device) => setState(() {
                    selectedAudioInput = device;
                  }),
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

                return ListMediaDevices(
                  key: Key('audiooutput'),
                  selectedDevice: selectedAudioOutput,
                  devices: audioOutputDevices,
                  onSelect: (MediaDeviceInfo device) => setState(() {
                    selectedAudioOutput = device;
                  }),
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

                return ListMediaDevices(
                  key: Key('videoinput'),
                  selectedDevice: selectedVideoInput,
                  devices: videoInputDevices,
                  onSelect: (MediaDeviceInfo device) => setState(() {
                    selectedVideoInput = device;
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
