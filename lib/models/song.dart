class Song {
  final String title;
  final String singer;
  final String? coverUrl;
  final String? musicUrl;
  final String quality;
  final String? lrcUrl;
  final String? lyrics; // 添加直接存储歌词的字段

  Song({
    required this.title,
    required this.singer,
    this.coverUrl,
    this.musicUrl,
    this.quality = '标准',
    this.lrcUrl,
    this.lyrics, // 新增歌词字段
  });
}