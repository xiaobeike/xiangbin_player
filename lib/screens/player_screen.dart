import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../models/lyric_line.dart';

class PlayerScreen extends StatefulWidget {
  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<LyricLine> _parsedLyrics = [];
  ScrollController _lyricsScrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _lyricsScrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        final currentSong = musicProvider.currentSong;
        
        // 当歌词更新时，重新解析
        if (musicProvider.currentLyrics != null) {
          _parseLyrics(musicProvider.currentLyrics!);
        }
        
        // 根据当前播放时间滚动歌词
        _scrollToCurrentLyric(musicProvider.currentPosition);
        
        return Scaffold(
          backgroundColor: Color(0xFF1f2937),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.keyboard_arrow_down, size: 32),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              children: [
                Text(
                  '香槟音乐 - 正在播放',
                  style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                ),
                Text(
                  currentSong?.title ?? '未知歌曲',
                  style: TextStyle(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: [
                Tab(text: '封面'),
                Tab(text: '歌词'),
              ],
            ),
          ),
          body: currentSong == null
              ? Center(
                  child: Text(
                    '暂无播放歌曲',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // 封面页
                          _buildCoverTab(context, musicProvider, currentSong),
                          
                          // 歌词页
                          _buildLyricsTab(context, musicProvider),
                        ],
                      ),
                    ),
                    
                    // 进度条
                    _buildProgressBar(context, musicProvider),
                    
                    // 播放控制按钮
                    _buildPlayControls(context, musicProvider),
                    
                    SizedBox(height: 20),
                  ],
                ),
        );
      },
    );
  }
  
  void _parseLyrics(String lyrics) {
    _parsedLyrics = [];
    
    try {
      final lines = lyrics.split('\n');
      
      for (var line in lines) {
        // 匹配时间标签 [mm:ss.xx]
        final timeMatches = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2})\]').allMatches(line);
        
        if (timeMatches.isNotEmpty) {
          // 提取歌词文本（去除所有时间标签）
          String text = line.replaceAll(RegExp(r'\[\d{2}:\d{2}\.\d{2}\]'), '').trim();
          
          // 如果有文本，添加到解析结果
          if (text.isNotEmpty) {
            for (var match in timeMatches) {
              final minutes = int.parse(match.group(1)!);
              final seconds = int.parse(match.group(2)!);
              final milliseconds = int.parse(match.group(3)!) * 10;
              
              final time = Duration(
                minutes: minutes,
                seconds: seconds,
                milliseconds: milliseconds,
              );
              
              _parsedLyrics.add(LyricLine(text: text, time: time));
            }
          }
        }
      }
      
      // 按时间排序
      _parsedLyrics.sort((a, b) => a.time.compareTo(b.time));
    } catch (e) {
      print('解析歌词失败: $e');
      _parsedLyrics = [];
    }
  }
  
  void _scrollToCurrentLyric(Duration currentPosition) {
    if (_parsedLyrics.isEmpty || !_lyricsScrollController.hasClients) return;
    
    // 找到当前应该高亮的歌词
    int currentIndex = -1;
    for (int i = 0; i < _parsedLyrics.length; i++) {
      if (i == _parsedLyrics.length - 1) {
        if (currentPosition >= _parsedLyrics[i].time) {
          currentIndex = i;
        }
      } else if (currentPosition >= _parsedLyrics[i].time && 
                currentPosition < _parsedLyrics[i + 1].time) {
        currentIndex = i;
        break;
      }
    }
    
    // 如果找到当前歌词，滚动到该位置
    if (currentIndex >= 0) {
      final screenHeight = MediaQuery.of(context).size.height;
      final scrollPosition = (currentIndex * 50.0) - (screenHeight / 3);
      
      _lyricsScrollController.animateTo(
        scrollPosition > 0 ? scrollPosition : 0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  Widget _buildCoverTab(BuildContext context, MusicProvider musicProvider, dynamic currentSong) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            // 歌曲封面
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF6A1B9A),
                    Color(0xFF1A237E),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: currentSong.coverUrl != null && currentSong.coverUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        currentSong.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultCover(currentSong.title);
                        },
                      ),
                    )
                  : _buildDefaultCover(currentSong.title),
            ),
            
            SizedBox(height: 40),
            
            // 歌曲信息
            Text(
              currentSong.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            SizedBox(height: 8),
            
            Text(
              currentSong.singer,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 8),
            
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                currentSong.quality,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green[400],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLyricsTab(BuildContext context, MusicProvider musicProvider) {
    if (musicProvider.isLoadingLyrics) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    
    final lyrics = musicProvider.currentLyrics;
    
    if (lyrics == null || lyrics.isEmpty || _parsedLyrics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note,
              size: 64,
              color: Colors.grey[600],
            ),
            SizedBox(height: 16),
            Text(
              '暂无歌词，请欣赏音乐',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }
    
    // 当前播放时间
    final currentPosition = musicProvider.currentPosition;
    
    return ListView.builder(
      controller: _lyricsScrollController,
      padding: EdgeInsets.symmetric(vertical: 100, horizontal: 24),
      itemCount: _parsedLyrics.length,
      itemBuilder: (context, index) {
        // 判断是否是当前播放的歌词
        bool isCurrentLyric = false;
        if (index < _parsedLyrics.length - 1) {
          isCurrentLyric = currentPosition >= _parsedLyrics[index].time && 
                          currentPosition < _parsedLyrics[index + 1].time;
        } else {
          isCurrentLyric = currentPosition >= _parsedLyrics[index].time;
        }
        
        return Container(
          height: 50,
          alignment: Alignment.center,
          child: Text(
            _parsedLyrics[index].text,
            style: TextStyle(
              fontSize: isCurrentLyric ? 20 : 16,
              fontWeight: isCurrentLyric ? FontWeight.bold : FontWeight.normal,
              color: isCurrentLyric ? Theme.of(context).primaryColor : Colors.white,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _buildDefaultCover(String title) {
    return Center(
      child: Text(
        title.isNotEmpty ? title[0].toUpperCase() : '♪',
        style: TextStyle(
          color: Colors.white,
          fontSize: 80,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, MusicProvider musicProvider) {
    return Column(
      children: [
        // 进度条
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Theme.of(context).primaryColor,
            inactiveTrackColor: Colors.grey[600],
            thumbColor: Theme.of(context).primaryColor,
            overlayColor: Theme.of(context).primaryColor.withOpacity(0.2),
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
            trackHeight: 4,
          ),
          child: Slider(
            value: musicProvider.totalDuration.inMilliseconds > 0
                ? musicProvider.currentPosition.inMilliseconds.toDouble()
                : 0.0,
            max: musicProvider.totalDuration.inMilliseconds.toDouble(),
            onChanged: (value) {
              musicProvider.seekTo(Duration(milliseconds: value.toInt()));
            },
          ),
        ),
        
        // 时间显示
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(musicProvider.currentPosition),
                style: TextStyle(color: Colors.grey[400]),
              ),
              Text(
                _formatDuration(musicProvider.totalDuration),
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayControls(BuildContext context, MusicProvider musicProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 上一首
        IconButton(
          icon: Icon(Icons.skip_previous),
          iconSize: 48,
          color: Colors.white,
          onPressed: musicProvider.playPrevious,
        ),
        
        // 播放/暂停
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color(0xFF6A1B9A),
                Color(0xFF1A237E),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              musicProvider.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
            iconSize: 40,
            color: Colors.white,
            onPressed: musicProvider.togglePlayPause,
          ),
        ),
        
        // 下一首
        IconButton(
          icon: Icon(Icons.skip_next),
          iconSize: 48,
          color: Colors.white,
          onPressed: musicProvider.playNext,
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }
}