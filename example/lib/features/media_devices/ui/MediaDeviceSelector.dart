import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class MediaDeviceSelector extends StatelessWidget {
  final List<MediaDeviceInfo> options;
  final MediaDeviceInfo? selected;
  final void Function(MediaDeviceInfo?)? onChanged;

  const MediaDeviceSelector({
    Key? key,
    this.options = const <MediaDeviceInfo>[],
    this.selected,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<MediaDeviceInfo>(
      isExpanded: true,
      value: selected,
      onChanged: onChanged,
      items: options
          .map<DropdownMenuItem<MediaDeviceInfo>>((device) {
        return DropdownMenuItem<MediaDeviceInfo>(
          child: Text(device.label, overflow: TextOverflow.fade,),
          value: device,
        );
      }).toList(),
    );
  }
}
