import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';
import '../services/api_service.dart';

class MusicProvider extends ChangeNotifier {
  // 首页数据 - 完全独立
  Map<String, List<Song>> _homeData = {};
  String _currentHomeCategory = '流行歌曲';
  
  // 搜索页面数据 - 完全独立
  List<Song> _searchResults = [];
  String _searchKeyword = '';
  
  // 当前显示的数据（首页或搜索页面）
  List<Song> _currentSongs = [];
  String _currentKeyword = '流行歌曲';
  bool _isSearchMode = false;
  
  // 播放相关
  int _currentIndex = -1;
  bool _isPlaying = false;
  Song? _currentPlayingSong;
  
  // UI状态
  bool _isLoading = false;
  
  // 音频播放器
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration(minutes: 3, seconds: 30);
  Timer? _progressTimer;
  
  // 歌词相关
  String? _currentLyrics;
  bool _isLoadingLyrics = false;

  // Getters
  List<Song> get songs => _currentSongs;
  int get currentIndex => _currentIndex;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  String get currentKeyword => _currentKeyword;
  bool get isSearchMode => _isSearchMode;
  Song? get currentSong => _currentPlayingSong ?? 
      (_currentIndex >= 0 && _currentIndex < _currentSongs.length ? _currentSongs[_currentIndex] : null);
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  String? get currentLyrics => _currentLyrics;
  bool get isLoadingLyrics => _isLoadingLyrics;

  MusicProvider() {
    _initializePlayer();
    loadCategoryData('流行歌曲');
  }

  void _initializePlayer() {
    // 监听播放位置变化
    _audioPlayer.positionStream.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    // 监听播放时长变化
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _totalDuration = duration;
        notifyListeners();
      }
    });

    // 监听播放状态变化
    _audioPlayer.playerStateStream.listen((state) {
      final wasPlaying = _isPlaying;
      _isPlaying = state.playing;
      
      if (wasPlaying != _isPlaying) {
        notifyListeners();
      }
      
      if (state.processingState == ProcessingState.completed) {
        playNext();
      }
    });
  }

  /// 加载首页分类数据 - 完全独立的数据管理
  Future<void> loadCategoryData(String category) async {
    if (category.trim().isEmpty) return;
    
    _isLoading = true;
    _currentHomeCategory = category;
    _currentKeyword = category;
    _isSearchMode = false;
    notifyListeners();

    try {
      // 检查缓存
      if (_homeData.containsKey(category) && _homeData[category]!.isNotEmpty) {
        _currentSongs = List<Song>.from(_homeData[category]!);
      } else {
        // 从API获取数据
        final results = await ApiService.searchSongs(category, num: 10);
        _homeData[category] = List<Song>.from(results);
        _currentSongs = List<Song>.from(results);
        
        // 异步加载详细信息
        _loadSongDetailsAsync(category, isHome: true);
      }
      
      // 重置播放索引
      if (_currentPlayingSong == null && _currentIndex >= _currentSongs.length) {
        _currentIndex = -1;
      }
    } catch (e) {
      print('加载分类数据失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 搜索歌曲 - 完全独立的搜索数据
  Future<void> searchSongs(String keyword) async {
    if (keyword.trim().isEmpty) return;
    
    _isLoading = true;
    _searchKeyword = keyword;
    _currentKeyword = keyword;
    _isSearchMode = true;
    notifyListeners();

    try {
      final results = await ApiService.searchSongs(keyword, num: 10);
      _searchResults = List<Song>.from(results);
      _currentSongs = List<Song>.from(results);
      
      // 重置播放索引
      if (_currentPlayingSong == null && _currentIndex >= _currentSongs.length) {
        _currentIndex = -1;
      }
      
      // 异步加载详细信息
      _loadSongDetailsAsync(keyword, isHome: false);
    } catch (e) {
      print('搜索歌曲失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 恢复首页数据 - 从搜索模式返回首页时调用
  void restoreHomeData() {
    _isSearchMode = false;
    _currentKeyword = _currentHomeCategory;
    
    // 恢复首页当前分类的数据
    if (_homeData.containsKey(_currentHomeCategory)) {
      _currentSongs = List<Song>.from(_homeData[_currentHomeCategory]!);
    } else {
      _currentSongs = [];
      // 重新加载当前分类数据
      loadCategoryData(_currentHomeCategory);
      return;
    }
    
    notifyListeners();
  }

  /// 异步加载歌曲详细信息
  void _loadSongDetailsAsync(String keyword, {required bool isHome}) async {
    final targetList = isHome ? _homeData[keyword] : _searchResults;
    if (targetList == null) return;

    for (int i = 0; i < targetList.length; i++) {
      try {
        final detail = await ApiService.getSongDetail(keyword, i);
        if (detail != null) {
          // 更新对应的数据源
          targetList[i] = Song(
            title: targetList[i].title,
            singer: targetList[i].singer,
            coverUrl: detail.coverUrl,
            musicUrl: targetList[i].musicUrl,
            quality: detail.quality,
            lrcUrl: detail.lrcUrl,
            lyrics: detail.lyrics,
          );
          
          // 如果当前显示的是这个数据源，同步更新显示
          if ((isHome && !_isSearchMode && _currentHomeCategory == keyword) ||
              (!isHome && _isSearchMode && _searchKeyword == keyword)) {
            _currentSongs[i] = targetList[i];
            notifyListeners();
          }
        }
      } catch (e) {
        // 静默处理单个歌曲的加载失败
      }
      
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

  /// 播放指定歌曲
  Future<void> playSong(int index) async {
    if (index < 0 || index >= _currentSongs.length) return;

    _currentIndex = index;
    final song = _currentSongs[index];
    
    try {
      await _audioPlayer.stop();
      _currentPlayingSong = song;
      _loadLyrics();
      
      if (song.musicUrl == null || song.musicUrl!.isEmpty) {
        final audioUrl = await ApiService.getSongAudioUrl(_currentKeyword, index);
        if (audioUrl != null && audioUrl.isNotEmpty) {
          _currentSongs[index] = Song(
            title: song.title,
            singer: song.singer,
            coverUrl: song.coverUrl,
            musicUrl: audioUrl,
            quality: song.quality,
            lrcUrl: song.lrcUrl,
            lyrics: song.lyrics,
          );
          _currentPlayingSong = _currentSongs[index];
        }
      }
      
      final updatedSong = _currentPlayingSong!;
      if (updatedSong.musicUrl != null && updatedSong.musicUrl!.isNotEmpty) {
        try {
          await _audioPlayer.setUrl(updatedSong.musicUrl!);
          await _audioPlayer.play();
        } catch (audioError) {
          _startSimulatedPlayback();
        }
      } else {
        _startSimulatedPlayback();
      }
    } catch (e) {
      _startSimulatedPlayback();
    }
    
    notifyListeners();
  }

  /// 加载歌词
  Future<void> _loadLyrics() async {
    if (_currentIndex < 0 || _currentIndex >= _currentSongs.length) return;
    
    _isLoadingLyrics = true;
    _currentLyrics = null;
    notifyListeners();
    
    try {
      final song = _currentSongs[_currentIndex];
      
      if (song.lyrics != null && song.lyrics!.isNotEmpty) {
        _currentLyrics = song.lyrics;
        _isLoadingLyrics = false;
        notifyListeners();
        return;
      }
      
      final lyrics = await ApiService.getLyrics(_currentKeyword, _currentIndex);
      _currentLyrics = lyrics;
    } catch (e) {
      print('加载歌词失败: $e');
    } finally {
      _isLoadingLyrics = false;
      notifyListeners();
    }
  }

  /// 开始模拟播放
  void _startSimulatedPlayback() {
    _currentPosition = Duration.zero;
    _isPlaying = true;
    _startProgressTimer();
  }

  /// 开始进度计时器
  void _startProgressTimer() {
    _progressTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isPlaying) {
        _currentPosition = Duration(seconds: _currentPosition.inSeconds + 1);
        
        if (_currentPosition >= _totalDuration) {
          _stopProgressTimer();
          playNext();
        }
        
        notifyListeners();
      }
    });
  }

  /// 停止进度计时器
  void _stopProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  /// 切换播放/暂停
  Future<void> togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        _stopProgressTimer();
        _isPlaying = false;
        notifyListeners();
      } else {
        if (_currentIndex >= 0) {
          await _audioPlayer.play();
          _isPlaying = true;
          notifyListeners();
        } else if (_currentSongs.isNotEmpty) {
          await playSong(0);
        }
      }
    } catch (e) {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _startProgressTimer();
      } else {
        _stopProgressTimer();
      }
      notifyListeners();
    }
  }

  /// 播放上一首
  Future<void> playPrevious() async {
    if (_currentSongs.isEmpty) return;
    
    int prevIndex = _currentIndex - 1;
    if (prevIndex < 0) {
      prevIndex = _currentSongs.length - 1;
    }
    
    await playSong(prevIndex);
  }

  /// 播放下一首
  Future<void> playNext() async {
    if (_currentSongs.isEmpty) return;
    
    int nextIndex = _currentIndex + 1;
    if (nextIndex >= _currentSongs.length) {
      nextIndex = 0;
    }
    
    await playSong(nextIndex);
  }

  /// 跳转到指定位置
  Future<void> seekTo(Duration position) async {
    try {
      if (position <= _totalDuration) {
        await _audioPlayer.seek(position);
      }
    } catch (e) {
      _currentPosition = position;
      notifyListeners();
    }
  }

  /// 设置音量
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume);
    } catch (e) {
      // 静默处理错误
    }
  }

  @override
  void dispose() {
    _stopProgressTimer();
    _audioPlayer.dispose();
    super.dispose();
  }
}