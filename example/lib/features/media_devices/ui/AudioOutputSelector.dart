import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:example/features/media_devices/ui/MediaDeviceSelector.dart';
import 'package:example/features/media_devices/bloc/media_devices_bloc.dart';

class AudioOutputSelector extends StatelessWidget {
  const AudioOutputSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<MediaDeviceInfo> audioOutputDevices =
    context.select((MediaDevicesBloc bloc) => bloc.state.audioOutputs);
    final MediaDeviceInfo? selectedAudioOutput = context
        .select((MediaDevicesBloc bloc) => bloc.state.selectedAudioOutput);

    return MediaDeviceSelector(
      selected: selectedAudioOutput,
      options: audioOutputDevices,
      onChanged: (MediaDeviceInfo? device) =>
          context.read<MediaDevicesBloc>().add(
            MediaDeviceSelectAudioOutput(device),
          ),
    );
  }
}
