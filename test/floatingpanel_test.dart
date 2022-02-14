import 'package:floatingpanel/floatingpanel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test', () {
    final floatingPanel = FloatBoxPanel(
      buttons: [Icons.message, Icons.photo_camera, Icons.video_library],
    );
  });
}
