import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';

class MiniPlayer extends StatelessWidget {
  final VoidCallback onTap;

  const MiniPlayer({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        final currentSong = musicProvider.currentSong;
        if (currentSong == null) return SizedBox.shrink();

        return Container(
          height: 80,
          decoration: BoxDecoration(
            color: Color(0xFF374151),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    // 歌曲封面
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
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
                              borderRadius: BorderRadius.circular(8),
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
                    
                    SizedBox(width: 12),
                    
                    // 歌曲信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentSong.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            currentSong.singer,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    
                    // 播放控制按钮
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.skip_previous),
                          color: Colors.white,
                          onPressed: musicProvider.playPrevious,
                        ),
                        IconButton(
                          icon: Icon(
                            musicProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                          ),
                          color: Theme.of(context).primaryColor,
                          iconSize: 32,
                          onPressed: musicProvider.togglePlayPause,
                        ),
                        IconButton(
                          icon: Icon(Icons.skip_next),
                          color: Colors.white,
                          onPressed: musicProvider.playNext,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
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
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}