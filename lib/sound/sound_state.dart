import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile_puzzle_game/sound/audio_controller.dart';

class SoundState with ChangeNotifier {
  late AudioController audioController;

  SoundState({
    required this.audioController
  });

  @override
  void dispose() {
    super.dispose();
    return audioController.dispose();
  }

  void playClickSoundInteraction() async {
    List<String> soundPaths = [
      'assets/beeps/tiny_soft_ding_beep_2.ogg',
      'assets/beeps/tiny_soft_ding_beep.wav',
      'assets/beeps/very_tiny_soft_beep_2.wav',
    ];
    String selectedSoundPath = (soundPaths..shuffle()).first;
    double pitchShift = 1.0 + Random().nextDouble() * 0.4 - 0.2;
    await audioController.playSound(selectedSoundPath, pitchShift: pitchShift);
  }

  void playTickSound() async {
    List<String> soundPaths = [
      'assets/beeps/very_tiny_soft_beep.wav',
    ];
    String selectedSoundPath = (soundPaths..shuffle()).first;
    double pitchShift = 1.0 + Random().nextDouble() * 0.4 - 0.2;
    await audioController.playSound(selectedSoundPath, pitchShift: pitchShift);
  }

  void playPauseSound() async {
    List<String> soundPaths = [
      'assets/beeps/small_soft_beep.wav',
    ];
    String selectedSoundPath = (soundPaths..shuffle()).first;
    double pitchShift = 1.0 + Random().nextDouble() * 0.4 - 0.2;
    await audioController.playSound(selectedSoundPath, pitchShift: pitchShift);
  }

  void playClickSoundTyping() async {
    List<String> soundPaths = [
      'assets/keyboard_keys/key1.wav',
      'assets/keyboard_keys/key2.ogg',
      'assets/keyboard_keys/key3.wav',
      'assets/keyboard_keys/key4.wav',
      'assets/keyboard_keys/key5.wav',
    ];
    String selectedSoundPath = (soundPaths..shuffle()).first;
    double pitchShift = 1.0 + Random().nextDouble() * 0.4 - 0.2;
    await audioController.playSound(selectedSoundPath, pitchShift: pitchShift);
  }
}
