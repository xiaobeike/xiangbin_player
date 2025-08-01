import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../widgets/song_list_item.dart';
import '../widgets/mini_player.dart';
import '../widgets/search_bar.dart';
import 'player_screen.dart';
import 'search_result_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin, RouteAware {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  
  final List<String> _categories = [
    '流行歌曲',
    '热门歌曲', 
    '新歌榜',
    '经典老歌',
    '华语金曲',
    '欧美热歌'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final category = _categories[_tabController.index];
        Provider.of<MusicProvider>(context, listen: false).loadCategoryData(category);
      }
    });
  }

  @override
  void didPopNext() {
    // 从搜索页面返回时，刷新当前分类数据
    super.didPopNext();
    final currentCategory = _categories[_tabController.index];
    Provider.of<MusicProvider>(context, listen: false).loadCategoryData(currentCategory);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        return Scaffold(
          body: Column(
            children: [
              // 顶部区域 - 标题和搜索框
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // 标题栏
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '香槟音乐播放器',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.search, color: Colors.white),
                              onPressed: () => _showSearchDialog(context),
                            ),
                          ],
                        ),
                      ),
                      
                      // 搜索栏
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CustomSearchBar(
                            controller: _searchController,
                            onSearch: (keyword) {
                              if (keyword.isNotEmpty) {
                                _navigateToSearchResult(context, keyword);
                              }
                            },
                          ),
                        ),
                      ),
                      
                      // Tab栏
                      Container(
                        height: 48,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final isSelected = _tabController.index == index;
                            return GestureDetector(
                              onTap: () {
                                _tabController.animateTo(index);
                              },
                              child: Container(
                                margin: EdgeInsets.only(right: 12, top: 4, bottom: 4),
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: isSelected ? LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.3),
                                      Colors.white.withOpacity(0.2),
                                    ],
                                  ) : null,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: isSelected ? [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: Offset(0, 1),
                                    ),
                                  ] : null,
                                ),
                                child: Center(
                                  child: Text(
                                    _categories[index],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // 主内容区域
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
                            '正在加载歌曲...',
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
                                  Icons.music_note,
                                  size: 40,
                                  color: Colors.grey[400],
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                '暂无歌曲',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '请选择其他分类',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: Color(0xFF6366F1),
                          onRefresh: () async {
                            final currentCategory = _categories[_tabController.index];
                            await musicProvider.loadCategoryData(currentCategory);
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

  void _navigateToSearchResult(BuildContext context, String keyword) async {
    // 跳转到搜索结果页面，等待返回
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultScreen(keyword: keyword),
      ),
    );
    
    // 返回时自动刷新当前分类数据
    final currentCategory = _categories[_tabController.index];
    Provider.of<MusicProvider>(context, listen: false).loadCategoryData(currentCategory);
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String searchText = '';
        return AlertDialog(
          backgroundColor: Color(0xFF374151),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            '搜索音乐',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            autofocus: true,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: '输入歌曲名或歌手名',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Color(0xFF6366F1),
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              searchText = value;
            },
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                _searchController.text = value.trim();
                _navigateToSearchResult(context, value.trim());
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '取消',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (searchText.trim().isNotEmpty) {
                  _searchController.text = searchText.trim();
                  _navigateToSearchResult(context, searchText.trim());
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('搜索'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// 自定义SliverPersistentHeaderDelegate用于Tab栏吸顶
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
