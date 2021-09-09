import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

part 'media_devices_event.dart';
part 'media_devices_state.dart';

class MediaDevicesBloc extends Bloc<MediaDevicesEvent, MediaDevicesState> {
  MediaDevicesBloc() : super(MediaDevicesState());

  @override
  Stream<MediaDevicesState> mapEventToState(
    MediaDevicesEvent event,
  ) async* {
    if (event is MediaDeviceLoadDevices) {
      yield* _mapLoadDevicesToState(event);
    } else if (event is MediaDeviceSelectAudioInput) {
      yield* _mapSelectAudioInputToState(event);
    } else if (event is MediaDeviceSelectAudioOutput) {
      yield* _mapSelectAudioOutputToState(event);
    } else if (event is MediaDeviceSelectVideoInput) {
      yield* _mapSelectVideoInputToState(event);
    }
  }

  Stream<MediaDevicesState> _mapSelectAudioInputToState(MediaDeviceSelectAudioInput event) async* {
    yield state.copyWith(
      selectedAudioInput: event.device,
    );
  }

  Stream<MediaDevicesState> _mapSelectAudioOutputToState(MediaDeviceSelectAudioOutput event) async* {
    yield state.copyWith(
      selectedAudioOutput: event.device,
    );
  }

  Stream<MediaDevicesState> _mapSelectVideoInputToState(MediaDeviceSelectVideoInput event) async* {
    yield state.copyWith(
      selectedVideoInput: event.device,
    );
  }

  Stream<MediaDevicesState> _mapLoadDevicesToState(
      MediaDeviceLoadDevices event) async* {
    try {
      final List<MediaDeviceInfo> devices =
          await navigator.mediaDevices.enumerateDevices();

      final List<MediaDeviceInfo> audioInputs = [];
      final List<MediaDeviceInfo> audioOutputs = [];
      final List<MediaDeviceInfo> videoInputs = [];

      devices.forEach((device) {
        switch (device.kind) {
          case 'audioinput':
            audioInputs.add(device);
            break;
          case 'audiooutput':
            audioOutputs.add(device);
            break;
          case 'videoinput':
            videoInputs.add(device);
            break;
          default:
            break;
        }
      });
      MediaDeviceInfo? selectedAudioInput;
      MediaDeviceInfo? selectedAudioOutput;
      MediaDeviceInfo? selectedVideoInput;
      if (audioInputs.isNotEmpty) {
        selectedAudioInput = audioInputs.first;
      }
      if (audioOutputs.isNotEmpty) {
        selectedAudioOutput = audioOutputs.first;
      }
      if (videoInputs.isNotEmpty) {
        selectedVideoInput = videoInputs.first;
      }

      yield MediaDevicesState(
        audioInputs: audioInputs,
        audioOutputs: audioOutputs,
        videoInputs: videoInputs,
        selectedAudioInput: selectedAudioInput,
        selectedAudioOutput: selectedAudioOutput,
        selectedVideoInput: selectedVideoInput,
      );
    } catch (e) {}
  }
}
