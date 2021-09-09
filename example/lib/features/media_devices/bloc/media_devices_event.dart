part of 'media_devices_bloc.dart';

abstract class MediaDevicesEvent extends Equatable {
  const MediaDevicesEvent();
}

class MediaDeviceLoadDevices extends MediaDevicesEvent {
  @override
  List<Object> get props => [];
}

class MediaDeviceSelectAudioInput extends MediaDevicesEvent {
  final MediaDeviceInfo? device;

  const MediaDeviceSelectAudioInput(this.device);

  @override
  List<Object> get props => [];
}

class MediaDeviceSelectAudioOutput extends MediaDevicesEvent {
  final MediaDeviceInfo? device;

  const MediaDeviceSelectAudioOutput(this.device);

  @override
  List<Object> get props => [];
}

class MediaDeviceSelectVideoInput extends MediaDevicesEvent {
  final MediaDeviceInfo? device;

  const MediaDeviceSelectVideoInput(this.device);

  @override
  List<Object> get props => [];
}

class MediaDeviceSelectVideoOut extends MediaDevicesEvent {
  final MediaDeviceInfo device;

  const MediaDeviceSelectVideoOut(this.device);

  @override
  List<Object> get props => [];
}