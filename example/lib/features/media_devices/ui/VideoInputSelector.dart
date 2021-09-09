import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:example/features/media_devices/ui/MediaDeviceSelector.dart';
import 'package:example/features/media_devices/bloc/media_devices_bloc.dart';

class VideoInputSelector extends StatelessWidget {
  const VideoInputSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<MediaDeviceInfo> videoInputDevices =
    context.select((MediaDevicesBloc bloc) => bloc.state.videoInputs);
    final MediaDeviceInfo? selectedVideoInput = context
        .select((MediaDevicesBloc bloc) => bloc.state.selectedVideoInput);

    return MediaDeviceSelector(
      selected: selectedVideoInput,
      options: videoInputDevices,
      onChanged: (MediaDeviceInfo? device) =>
          context.read<MediaDevicesBloc>().add(
            MediaDeviceSelectVideoInput(device),
          ),
    );
  }
}
