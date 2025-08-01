import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/song.dart';

class ApiService {
  static const String _baseUrl = 'https://api.yyy001.com/api/mgmuisc';
  
  // 音乐分类列表
  static const Map<String, List<String>> _categoryKeywords = {
    '流行歌曲': ['流行', '热门', '经典', '好听'],
    '热门歌曲': ['热门', '流行', '排行榜', '新歌'],
    '新歌榜': ['新歌', '最新', '2024', '热门'],
    '经典老歌': ['经典', '老歌', '怀旧', '金曲'],
    '华语金曲': ['华语', '中文', '国语', '粤语'],
    '欧美热歌': ['欧美', '英文', '流行', '热门'],
  };

  /// 搜索歌曲（只获取基本信息，不包含音频链接）
  static Future<List<Song>> searchSongs(String keyword, {int num = 10}) async {
    try {
      // 如果是分类搜索，使用对应的关键词
      String searchKeyword = keyword;
      if (_categoryKeywords.containsKey(keyword)) {
        // 使用分类中的第一个关键词进行搜索
        searchKeyword = _categoryKeywords[keyword]!.first;
      }
      
      // 常规搜索
      final response = await http.get(
        Uri.parse('$_baseUrl?msg=${Uri.encodeComponent(searchKeyword)}&type=json&num=$num'),
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['code'] == 200 && data['data'] != null) {
          return (data['data'] as List).map((item) {
            return Song(
              title: item['title'] ?? '未知歌曲',
              singer: item['singer'] ?? '未知歌手',
              quality: '标准', // 搜索结果中没有音质信息，使用默认值
            );
          }).toList();
        }
      }
      
      return [];
    } catch (e) {
      print('搜索歌曲失败: $e');
      return [];
    }
  }

  /// 获取歌曲详细信息（封面、音质等）
  static Future<Song?> getSongDetail(String keyword, int index) async {
    try {
      // 如果是分类搜索，使用对应的关键词
      String searchKeyword = keyword;
      if (_categoryKeywords.containsKey(keyword)) {
        searchKeyword = _categoryKeywords[keyword]!.first;
      }
      
      // 获取搜索结果的详情
      final response = await http.get(
        Uri.parse('$_baseUrl?msg=${Uri.encodeComponent(searchKeyword)}&n=${index + 1}&type=json'),
      ).timeout(Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['code'] == 200) {
          return Song(
            title: data['title'] ?? '未知歌曲',
            singer: data['singer'] ?? '未知歌手',
            coverUrl: data['cover'],
            quality: data['quality'] ?? '标准',
            lrcUrl: data['lrc_url'],
            lyrics: data['lrc'], // 直接获取歌词
          );
        }
      }
      
      return null;
    } catch (e) {
      print('获取歌曲详情失败: $e');
      return null;
    }
  }

  /// 获取歌曲音频链接
  static Future<String?> getSongAudioUrl(String keyword, int index) async {
    try {
      // 如果是分类搜索，使用对应的关键词
      String searchKeyword = keyword;
      if (_categoryKeywords.containsKey(keyword)) {
        searchKeyword = _categoryKeywords[keyword]!.first;
      }
      
      // 获取音频链接
      final response = await http.get(
        Uri.parse('$_baseUrl?msg=${Uri.encodeComponent(searchKeyword)}&n=${index + 1}&type=json'),
      ).timeout(Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['code'] == 200 && data['music_url'] != null) {
          return data['music_url'];
        }
      }
      
      return null;
    } catch (e) {
      print('获取音频链接失败: $e');
      return null;
    }
  }

  /// 获取歌词内容
  static Future<String?> getLyrics(String keyword, int index) async {
    try {
      // 如果是分类搜索，使用对应的关键词
      String searchKeyword = keyword;
      if (_categoryKeywords.containsKey(keyword)) {
        searchKeyword = _categoryKeywords[keyword]!.first;
      }
      
      // 获取歌词
      final response = await http.get(
        Uri.parse('$_baseUrl?msg=${Uri.encodeComponent(searchKeyword)}&n=${index + 1}&type=json'),
      ).timeout(Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // 优先使用直接返回的歌词
        if (data['code'] == 200 && data['lrc'] != null && data['lrc'].isNotEmpty) {
          return data['lrc'];
        }
        
        // 如果没有直接返回歌词但有歌词URL，尝试获取歌词
        if (data['code'] == 200 && data['lrc_url'] != null && data['lrc_url'].isNotEmpty) {
          try {
            final lyricsResponse = await http.get(Uri.parse(data['lrc_url']));
            if (lyricsResponse.statusCode == 200) {
              return lyricsResponse.body;
            }
          } catch (e) {
            print('获取歌词文件失败: $e');
          }
        }
      }
      
      return null;
    } catch (e) {
      print('获取歌词失败: $e');
      return null;
    }
  }
}