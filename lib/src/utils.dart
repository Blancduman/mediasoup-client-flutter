import 'dart:math';

import 'package:flutter_webrtc/flutter_webrtc.dart';

Random random = Random();

int generateRandomNumber() {
  return random.nextInt(10000000);
}