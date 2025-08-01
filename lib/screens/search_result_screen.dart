import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../widgets/song_list_item.dart';
import '../widgets/mini_player.dart';
import 'player_screen.dart';

class SearchResultScreen extends StatefulWidget {
  final String keyword;

  const SearchResultScreen({Key? key, required this.keyword}) : super(key: key);

  @override
  _SearchResultScreenState createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  bool _hasSearched = false;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    // 初始化搜索控制器，设置初始文本和光标位置
    _searchController = TextEditingController(text: widget.keyword);
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: widget.keyword.length),
    );
    
    // 在initState中执行搜索
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasSearched) {
        Provider.of<MusicProvider>(context, listen: false)
            .searchSongs(widget.keyword);
        _hasSearched = true;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              '搜索结果',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            elevation: 0,
            backgroundColor: Color(0xFF6366F1),
            foregroundColor: Colors.white,
          ),
          body: Column(
            children: [
              // 搜索区域 - 简洁设计
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // 搜索框
                    Expanded(
                      child: Container(
                        height: 44,
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: '搜索歌曲或歌手',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 16,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.white.withOpacity(0.8),
                              size: 20,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onTap: () {
                            // 点击时将光标移到文本末尾
                            _searchController.selection = TextSelection.fromPosition(
                              TextPosition(offset: _searchController.text.length),
                            );
                          },
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              _performSearch(context, value.trim());
                            }
                          },
                        ),
                      ),
                    ),
                    
                    SizedBox(width: 12),
                    
                    // 歌曲数量显示
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${musicProvider.songs.length} 首',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 歌曲列表
              Expanded(
                child: Container(
                  color: Color(0xFF1f2937),
                  child: musicProvider.isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF6366F1),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                '正在搜索歌曲...',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : musicProvider.songs.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Icon(
                                      Icons.search_off,
                                      size: 40,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    '暂无搜索结果',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '请尝试其他关键词',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Provider.of<MusicProvider>(context, listen: false)
                                          .searchSongs(widget.keyword);
                                    },
                                    icon: Icon(Icons.refresh, size: 18),
                                    label: Text('重新搜索'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF6366F1),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              color: Color(0xFF6366F1),
                              onRefresh: () async {
                                await musicProvider.searchSongs(widget.keyword);
                              },
                              child: ListView.builder(
                                padding: EdgeInsets.only(
                                  top: 8,
                                  bottom: musicProvider.currentSong != null ? 100 : 16,
                                ),
                                itemCount: musicProvider.songs.length,
                                itemBuilder: (context, index) {
                                  final song = musicProvider.songs[index];
                                  final isCurrentSong = index == musicProvider.currentIndex;
                                  
                                  return Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: isCurrentSong 
                                          ? Color(0xFF6366F1).withOpacity(0.1)
                                          : Colors.transparent,
                                    ),
                                    child: SongListItem(
                                      song: song,
                                      isPlaying: isCurrentSong && musicProvider.isPlaying,
                                      onTap: () {
                                        musicProvider.playSong(index);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
              ),
            ],
          ),
          
          // 底部迷你播放器
          bottomSheet: musicProvider.currentSong != null
              ? MiniPlayer(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlayerScreen(),
                      ),
                    );
                  },
                )
              : null,
        );
      },
    );
  }


  void _performSearch(BuildContext context, String keyword) {
    // 如果搜索关键词不同，跳转到新的搜索结果页面
    if (keyword != widget.keyword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultScreen(keyword: keyword),
        ),
      );
    } else {
      // 如果关键词相同，重新搜索当前页面
      Provider.of<MusicProvider>(context, listen: false).searchSongs(keyword);
    }
  }
}
