import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../models/audio_item.dart';
import '../services/audio_service.dart';

enum AudioRepeatMode {
  off,
  repeatAll,
  repeatOne,
}

class GlobalAudioState {
  final String? voiceFile;
  final String? audioUrl;
  final int? activeSurahNumber;
  final String? title;
  final bool isPlaying;
  final bool isLoading;
  final bool isDownloading;
  final double downloadProgress;
  final Duration position;
  final Duration duration;
  final double playbackRate;
  final bool isVisible;
  final String? localPath;
  final Object? navigationTarget; // Extra info to navigate back to view when tapped
  final List<AudioItem> queue;
  final int currentQueueIndex;
  final AudioRepeatMode repeatMode;
  final bool isShuffle;

  const GlobalAudioState({
    this.voiceFile,
    this.audioUrl,
    this.activeSurahNumber,
    this.title,
    this.isPlaying = false,
    this.isLoading = false,
    this.isDownloading = false,
    this.downloadProgress = 0.0,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.playbackRate = 1.0,
    this.isVisible = false,
    this.localPath,
    this.navigationTarget,
    this.queue = const [],
    this.currentQueueIndex = -1,
    this.repeatMode = AudioRepeatMode.off,
    this.isShuffle = false,
  });

  AudioItem? get currentAudioItem {
    if (queue.isEmpty) return null;
    if (currentQueueIndex >= 0 && currentQueueIndex < queue.length) {
      return queue[currentQueueIndex];
    }
    return null;
  }

  bool get isLoaded => isVisible && (voiceFile != null || audioUrl != null);

  bool get hasNext =>
      queue.isNotEmpty &&
      (repeatMode == AudioRepeatMode.repeatAll ||
          isShuffle ||
          currentQueueIndex + 1 < queue.length);

  bool get hasPrevious =>
      queue.isNotEmpty &&
      (repeatMode == AudioRepeatMode.repeatAll ||
          isShuffle ||
          currentQueueIndex > 0 ||
          position.inSeconds > 3);

  GlobalAudioState copyWith({
    String? voiceFile,
    String? audioUrl,
    int? activeSurahNumber,
    String? title,
    bool? isPlaying,
    bool? isLoading,
    bool? isDownloading,
    double? downloadProgress,
    Duration? position,
    Duration? duration,
    double? playbackRate,
    bool? isVisible,
    String? localPath,
    Object? navigationTarget,
    List<AudioItem>? queue,
    int? currentQueueIndex,
    AudioRepeatMode? repeatMode,
    bool? isShuffle,
  }) {
    return GlobalAudioState(
      voiceFile: voiceFile ?? this.voiceFile,
      audioUrl: audioUrl ?? this.audioUrl,
      activeSurahNumber: activeSurahNumber ?? this.activeSurahNumber,
      title: title ?? this.title,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      isDownloading: isDownloading ?? this.isDownloading,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      playbackRate: playbackRate ?? this.playbackRate,
      isVisible: isVisible ?? this.isVisible,
      localPath: localPath ?? this.localPath,
      navigationTarget: navigationTarget ?? this.navigationTarget,
      queue: queue ?? this.queue,
      currentQueueIndex: currentQueueIndex ?? this.currentQueueIndex,
      repeatMode: repeatMode ?? this.repeatMode,
      isShuffle: isShuffle ?? this.isShuffle,
    );
  }
}

class GlobalAudioNotifier extends StateNotifier<GlobalAudioState> {
  final AudioService _audioService = AudioService();
  final Random _random = Random();
  StreamSubscription? _playerStateSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _playerCompleteSub;

  GlobalAudioNotifier() : super(const GlobalAudioState()) {
    _listenToAudioService();
  }

  void _listenToAudioService() {
    _playerStateSub = _audioService.onPlayerStateChanged.listen((pState) {
      state = state.copyWith(
        isPlaying: pState == PlayerState.playing,
        isLoading: pState == PlayerState.playing ? false : state.isLoading,
      );
    });

    _durationSub = _audioService.onDurationChanged.listen((dur) {
      state = state.copyWith(duration: dur);
    });

    _positionSub = _audioService.onPositionChanged.listen((pos) {
      state = state.copyWith(position: pos);
    });

    _playerCompleteSub = _audioService.audioPlayer.onPlayerComplete.listen((_) {
      if (state.repeatMode == AudioRepeatMode.repeatOne) {
        seek(Duration.zero);
        resume();
      } else if (state.queue.isNotEmpty) {
        playNext(autoAdvance: true);
      } else {
        state = state.copyWith(
          isPlaying: false,
          position: Duration.zero,
        );
      }
    });
  }

  Future<String> getLocalAudioPath(String voiceFile) async {
    final Directory baseDir = await getApplicationDocumentsDirectory();
    final Directory audioDir = Directory('${baseDir.path}/audios');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return '${audioDir.path}/$voiceFile.mp3';
  }

  Future<bool> localAudioExists(String voiceFile) async {
    final path = await getLocalAudioPath(voiceFile);
    return await File(path).exists();
  }

  Future<void> playAudio({
    required String voiceFile,
    required String title,
    Object? navigationTarget,
    bool fromQueue = false,
  }) async {
    if (voiceFile.isEmpty) return;

    if (!fromQueue) {
      final matchedIndex =
          state.queue.indexWhere((item) => item.voiceFile == voiceFile);
      if (matchedIndex != -1) {
        state = state.copyWith(currentQueueIndex: matchedIndex);
      } else {
        state = state.copyWith(
          queue: [
            AudioItem(id: voiceFile, title: title, voiceFile: voiceFile),
          ],
          currentQueueIndex: 0,
        );
      }
    }

    // If already playing this file, toggle play/pause
    if (state.voiceFile == voiceFile && state.isVisible) {
      if (state.isPlaying) {
        await pause();
      } else {
        await resume();
      }
      return;
    }

    state = state.copyWith(
      voiceFile: voiceFile,
      title: title,
      isLoading: true,
      isVisible: true,
      navigationTarget: navigationTarget,
      position: Duration.zero,
      duration: Duration.zero,
    );

    try {
      final localPath = await getLocalAudioPath(voiceFile);
      final file = File(localPath);

      if (!await file.exists()) {
        // Download audio file
        state = state.copyWith(isDownloading: true, downloadProgress: 0.0);
        final downloadUrl = 'https://drive.google.com/uc?export=download&id=$voiceFile&confirm=t';
        final request = http.Request('GET', Uri.parse(downloadUrl));
        final response = await http.Client().send(request);

        if (response.statusCode == 200) {
          final contentLength = response.contentLength ?? 0;
          List<int> bytes = [];
          int downloaded = 0;

          await for (var chunk in response.stream) {
            bytes.addAll(chunk);
            downloaded += chunk.length;
            if (contentLength > 0) {
              state = state.copyWith(downloadProgress: downloaded / contentLength);
            }
          }

          await file.writeAsBytes(bytes);
          state = state.copyWith(isDownloading: false, localPath: localPath);
        } else {
          throw Exception('Failed to download audio file: ${response.statusCode}');
        }
      } else {
        state = state.copyWith(localPath: localPath);
      }

      await _audioService.audioPlayer.stop();
      await _audioService.audioPlayer.play(DeviceFileSource(localPath));
      await _audioService.audioPlayer.setPlaybackRate(state.playbackRate);

      state = state.copyWith(
        isLoading: false,
        isPlaying: true,
      );
    } catch (e) {
      print('Error playing global audio: $e');
      state = state.copyWith(
        isLoading: false,
        isDownloading: false,
        isPlaying: false,
      );
    }
  }

  Future<void> playQueue(
    List<AudioItem> items, {
    int initialIndex = 0,
    Object? navigationTarget,
  }) async {
    if (items.isEmpty) return;
    final safeIndex = initialIndex.clamp(0, items.length - 1);
    final targetItem = items[safeIndex];

    state = state.copyWith(
      queue: items,
      currentQueueIndex: safeIndex,
    );

    await playAudio(
      voiceFile: targetItem.voiceFile,
      title: targetItem.title,
      navigationTarget: navigationTarget,
      fromQueue: true,
    );
  }

  Future<void> playNext({bool autoAdvance = false}) async {
    if (state.queue.isEmpty) return;

    if (state.isShuffle && state.queue.length > 1) {
      int nextIndex = _random.nextInt(state.queue.length);
      while (nextIndex == state.currentQueueIndex && state.queue.length > 1) {
        nextIndex = _random.nextInt(state.queue.length);
      }
      state = state.copyWith(currentQueueIndex: nextIndex);
      final item = state.queue[nextIndex];
      await playAudio(
        voiceFile: item.voiceFile,
        title: item.title,
        navigationTarget: state.navigationTarget,
        fromQueue: true,
      );
      return;
    }

    int nextIndex = state.currentQueueIndex + 1;
    if (nextIndex < state.queue.length) {
      state = state.copyWith(currentQueueIndex: nextIndex);
      final item = state.queue[nextIndex];
      await playAudio(
        voiceFile: item.voiceFile,
        title: item.title,
        navigationTarget: state.navigationTarget,
        fromQueue: true,
      );
    } else if (state.repeatMode == AudioRepeatMode.repeatAll) {
      state = state.copyWith(currentQueueIndex: 0);
      final item = state.queue[0];
      await playAudio(
        voiceFile: item.voiceFile,
        title: item.title,
        navigationTarget: state.navigationTarget,
        fromQueue: true,
      );
    } else {
      if (autoAdvance) {
        state = state.copyWith(
          isPlaying: false,
          position: Duration.zero,
        );
      }
    }
  }

  Future<void> playPrevious() async {
    if (state.queue.isEmpty) return;

    // If currently playing and position > 3 seconds, restart current track
    if (state.position.inSeconds > 3) {
      await seek(Duration.zero);
      if (!state.isPlaying) {
        await resume();
      }
      return;
    }

    if (state.isShuffle && state.queue.length > 1) {
      int prevIndex = _random.nextInt(state.queue.length);
      while (prevIndex == state.currentQueueIndex && state.queue.length > 1) {
        prevIndex = _random.nextInt(state.queue.length);
      }
      state = state.copyWith(currentQueueIndex: prevIndex);
      final item = state.queue[prevIndex];
      await playAudio(
        voiceFile: item.voiceFile,
        title: item.title,
        navigationTarget: state.navigationTarget,
        fromQueue: true,
      );
      return;
    }

    int prevIndex = state.currentQueueIndex - 1;
    if (prevIndex >= 0) {
      state = state.copyWith(currentQueueIndex: prevIndex);
      final item = state.queue[prevIndex];
      await playAudio(
        voiceFile: item.voiceFile,
        title: item.title,
        navigationTarget: state.navigationTarget,
        fromQueue: true,
      );
    } else if (state.repeatMode == AudioRepeatMode.repeatAll) {
      final lastIndex = state.queue.length - 1;
      state = state.copyWith(currentQueueIndex: lastIndex);
      final item = state.queue[lastIndex];
      await playAudio(
        voiceFile: item.voiceFile,
        title: item.title,
        navigationTarget: state.navigationTarget,
        fromQueue: true,
      );
    } else {
      await seek(Duration.zero);
    }
  }

  void toggleRepeatMode() {
    final nextMode = switch (state.repeatMode) {
      AudioRepeatMode.off => AudioRepeatMode.repeatAll,
      AudioRepeatMode.repeatAll => AudioRepeatMode.repeatOne,
      AudioRepeatMode.repeatOne => AudioRepeatMode.off,
    };
    state = state.copyWith(repeatMode: nextMode);
  }

  void toggleShuffle() {
    state = state.copyWith(isShuffle: !state.isShuffle);
  }

  Future<void> seekRelative(int seconds) async {
    final targetSeconds = state.position.inSeconds + seconds;
    final totalSeconds = state.duration.inSeconds;
    final clampedSeconds =
        targetSeconds.clamp(0, totalSeconds > 0 ? totalSeconds : 0);
    await seek(Duration(seconds: clampedSeconds));
  }

  Future<String> getQuranAudioCachePath(String reciterId, int surahNumber) async {
    final Directory baseDir = await getApplicationDocumentsDirectory();
    final Directory audioDir = Directory('${baseDir.path}/quran_audios');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return '${audioDir.path}/${reciterId}_$surahNumber.mp3';
  }

  Future<bool> isQuranAudioCached(String reciterId, int surahNumber) async {
    try {
      final path = await getQuranAudioCachePath(reciterId, surahNumber);
      final file = File(path);
      return await file.exists() && (await file.length() > 0);
    } catch (_) {
      return false;
    }
  }

  Future<void> deleteQuranAudio(String reciterId, int surahNumber) async {
    try {
      final path = await getQuranAudioCachePath(reciterId, surahNumber);
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting Quran audio cache: $e');
    }
  }

  Future<void> playUrlAudio({
    required String url,
    required String title,
    int? surahNumber,
    String? reciterId,
    Object? navigationTarget,
  }) async {
    if (url.isEmpty) return;

    // If already playing this url, toggle play/pause
    if (state.audioUrl == url && state.isVisible) {
      if (state.isPlaying) {
        await pause();
      } else {
        await resume();
      }
      return;
    }

    state = GlobalAudioState(
      voiceFile: null,
      audioUrl: url,
      activeSurahNumber: surahNumber,
      title: title,
      isLoading: true,
      isVisible: true,
      navigationTarget: navigationTarget,
      playbackRate: state.playbackRate,
    );

    try {
      String? cachePath;
      if (reciterId != null && surahNumber != null) {
        cachePath = await getQuranAudioCachePath(reciterId, surahNumber);
      }

      final cacheFile = cachePath != null ? File(cachePath) : null;

      // 1. Play directly from local disk if already cached
      if (cacheFile != null && await cacheFile.exists() && await cacheFile.length() > 0) {
        await _audioService.audioPlayer.stop();
        await _audioService.audioPlayer.play(DeviceFileSource(cacheFile.path));
        await _audioService.audioPlayer.setPlaybackRate(state.playbackRate);

        state = state.copyWith(
          isLoading: false,
          isPlaying: true,
          localPath: cacheFile.path,
        );
        return;
      }

      // 2. Start streaming IMMEDIATELY for instant playback (no waiting!)
      await _audioService.audioPlayer.stop();
      await _audioService.audioPlayer.play(UrlSource(url));
      await _audioService.audioPlayer.setPlaybackRate(state.playbackRate);

      state = state.copyWith(
        isLoading: false,
        isPlaying: true,
      );

      // 3. Save to local storage in background for future offline use
      if (cacheFile != null) {
        unawaited(_downloadAndCacheAudio(url, cacheFile));
      }
    } catch (e) {
      print('Error playing Quran audio stream: $e');
      state = state.copyWith(
        isLoading: false,
        isDownloading: false,
        isPlaying: false,
      );
    }
  }

  Future<void> _downloadAndCacheAudio(String url, File cacheFile) async {
    try {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(url));
      request.headers['User-Agent'] =
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

      final response = await client.send(request);
      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();
        await cacheFile.writeAsBytes(bytes);
        state = state.copyWith(localPath: cacheFile.path);
      }
    } catch (e) {
      print('Background cache download exception: $e');
    }
  }

  Future<void> pause() async {
    await _audioService.pause();
    state = state.copyWith(isPlaying: false);
  }

  Future<void> resume() async {
    await _audioService.resume();
    state = state.copyWith(isPlaying: true);
  }

  Future<void> stop() async {
    await _audioService.stop();
    state = state.copyWith(
      isPlaying: false,
      isVisible: false,
      position: Duration.zero,
    );
  }

  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
    state = state.copyWith(position: position);
  }

  Future<void> setPlaybackRate(double rate) async {
    await _audioService.audioPlayer.setPlaybackRate(rate);
    state = state.copyWith(playbackRate: rate);
  }

  void closePlayerBar() {
    state = state.copyWith(isVisible: false);
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _durationSub?.cancel();
    _positionSub?.cancel();
    _playerCompleteSub?.cancel();
    super.dispose();
  }
}

final globalAudioProvider = StateNotifierProvider<GlobalAudioNotifier, GlobalAudioState>((ref) {
  return GlobalAudioNotifier();
});
