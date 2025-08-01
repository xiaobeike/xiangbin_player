import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/song.dart';

class SongListItem extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback onTap;

  const SongListItem({
    Key? key,
    required this.song,
    required this.isPlaying,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: Color(0xFF374151),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              // 歌曲封面
              Container(
                width: 60,
                height: 60,
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
                child: song.coverUrl != null && song.coverUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: song.coverUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => _buildDefaultCover(),
                          errorWidget: (context, url, error) => _buildDefaultCover(),
                        ),
                      )
                    : _buildDefaultCover(),
              ),
              
              SizedBox(width: 12),
              
              // 歌曲信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: TextStyle(
                        color: isPlaying ? Theme.of(context).primaryColor : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      song.singer,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        song.quality ?? '标准',
                        style: TextStyle(
                          color: Colors.green[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 播放状态指示器
              if (isPlaying)
                Container(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.equalizer,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.grey[400],
                    size: 24,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultCover() {
    return Center(
      child: Text(
        song.title.isNotEmpty ? song.title[0].toUpperCase() : '♪',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}