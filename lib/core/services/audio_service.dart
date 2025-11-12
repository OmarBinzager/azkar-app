import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

/// Global audio service that persists across screen navigation
class AudioService {
  static final AudioService _instance = AudioService._internal();
  late AudioPlayer _audioPlayer;

  factory AudioService() {
    return _instance;
  }

  AudioService._internal() {
    _audioPlayer = AudioPlayer();
    _configureAudioContext();
  }

  Future<void> _configureAudioContext() async {
    final audioContext = AudioContext(
      android: AudioContextAndroid(
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gain,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: {
          AVAudioSessionOptions.mixWithOthers,
          AVAudioSessionOptions.defaultToSpeaker,
        },
      ),
    );

    unawaited(AudioPlayer.global.setAudioContext(audioContext));
    unawaited(_audioPlayer.setAudioContext(audioContext));
  }

  AudioPlayer get audioPlayer => _audioPlayer;

  /// Play audio from asset source
  Future<void> playAsset(String assetPath) async {
    try {
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      print('Error playing audio: $e');
      rethrow;
    }
  }

  /// Pause audio playback
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      print('Error pausing audio: $e');
      rethrow;
    }
  }

  /// Resume audio playback
  Future<void> resume() async {
    try {
      await _audioPlayer.resume();
    } catch (e) {
      print('Error resuming audio: $e');
      rethrow;
    }
  }

  /// Stop audio playback
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Error stopping audio: $e');
      rethrow;
    }
  }

  /// Seek to a specific position
  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      print('Error seeking audio: $e');
      rethrow;
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume);
    } catch (e) {
      print('Error setting volume: $e');
      rethrow;
    }
  }

  /// Get current player state
  PlayerState get state => _audioPlayer.state;

  /// Get current playback position
  Future<Duration?> getCurrentPosition() async {
    try {
      return await _audioPlayer.getCurrentPosition();
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  /// Get audio duration
  Future<Duration?> getDuration() async {
    try {
      return await _audioPlayer.getDuration();
    } catch (e) {
      print('Error getting duration: $e');
      return null;
    }
  }

  /// Listen to player state changes
  Stream<PlayerState> get onPlayerStateChanged =>
      _audioPlayer.onPlayerStateChanged;

  /// Listen to duration changes
  Stream<Duration> get onDurationChanged => _audioPlayer.onDurationChanged;

  /// Listen to position changes
  Stream<Duration> get onPositionChanged => _audioPlayer.onPositionChanged;

  /// Dispose the audio service (only call this when app is closing)
  void dispose() {
    _audioPlayer.dispose();
  }
}
