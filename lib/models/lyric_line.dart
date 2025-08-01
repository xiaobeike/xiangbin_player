class LyricLine {
  final String text;
  final Duration time;
  
  LyricLine({required this.text, required this.time});
  
  @override
  String toString() => 'LyricLine(time: $time, text: $text)';
}