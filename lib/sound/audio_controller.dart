import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:logging/logging.dart';

class AudioController {
  static final Logger _log = Logger('AudioController');

  SoLoud? _soloud; 
  SoundHandle? _musicHandle; 
  Map<String, AudioSource> _soundSources = {};

  Future<void> initialize() async {
    _soloud = SoLoud.instance;
    await _soloud!.init();
    await preloadSounds();
  }

  Future<void> preloadSounds() async {
    List<String> soundPaths = [
      'assets/beeps/short_2_tone_beep.wav',
      'assets/beeps/tiny_soft_ding_beep_2.ogg',
      'assets/beeps/tiny_soft_ding_beep.wav',
      'assets/beeps/very_tiny_soft_beep_2.wav',
      'assets/beeps/very_tiny_soft_beep.wav',
      'assets/beeps/small_soft_beep.wav',
    ];
    // List<String> reverbSoundPaths = [
    //   'assets/clacks/clack1nr.wav',
    //   'assets/clacks/clack2nr.wav',
    //   'assets/clacks/clack3nr.wav',
    //   'assets/clacks/clack4nr.wav',
    //   'assets/clacks/clack5nr.wav',
    //   'assets/clacks/clack6nr.wav',
    // ];

    for (String key in soundPaths) {
      _soundSources[key] = await _soloud!.loadAsset(key);
    }
    // for (String key in reverbSoundPaths) {
    //   _soundSources[key] = await _soloud!.loadAsset(key);
    // }
  }

  void dispose() {
    _soloud?.deinit();
  }


  Future<void> playSound(String assetKey, {required double pitchShift}) async {
    try {
      final source = _soundSources[assetKey];
      if (source == null) {
        _log.severe("Asset $assetKey was not preloaded. Ignoring.");
        return;
      }

      _soloud!.play(
        volume: 1.0,
        source,
      );
    } on SoLoudException catch (e) {
      _log.severe("Cannot play sound '$assetKey'. Ignoring.", e);
    }
  }

  // Future<void> startMusic() async {
  //   if (_musicHandle != null) {
  //     if (_soloud!.getIsValidVoiceHandle(_musicHandle!)) {
  //       _log.info('Music is already playing. Stopping first.');
  //       await _soloud!.stop(_musicHandle!);
  //     }
  //   }
  //   _log.info('Loading music');
  //   final musicSource = await _soloud!
  //       .loadAsset('the_core.mp3', mode: LoadMode.disk);
  //   musicSource.allInstancesFinished.first.then((_) {
  //     _soloud!.disposeSource(musicSource);
  //     _log.info('Music source disposed');
  //     _musicHandle = null;
  //   });

  //   _log.info('Playing music');
  //   _musicHandle = await _soloud!.play(
  //     musicSource,
  //     volume: 0.4,
  //     looping: true,
  //     loopingStartAt: const Duration(seconds: 1, milliseconds: 0),
  //   );
  // }

  void fadeOutMusic() {
    if (_musicHandle == null) {
      _log.info('Nothing to fade out');
      return;
    }
    const length = Duration(seconds: 5);
    _soloud!.fadeVolume(_musicHandle!, 0, length);
    _soloud!.scheduleStop(_musicHandle!, length);
  }

  void applyFilter() {
    _soloud!.filters.robotizeFilter.activate();
  }

  void removeFilter() {
    _soloud!.filters.robotizeFilter.deactivate();
  }
}
