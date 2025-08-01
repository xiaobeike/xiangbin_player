# 香槟音乐播放器

一款基于Flutter开发的跨平台移动音乐应用，提供流畅的音乐播放体验。

## 项目简介

香槟音乐播放器是一款现代化的音乐应用，支持Android、iOS、Web、Windows、macOS、Linux等多个平台。应用采用蓝色主题设计，提供优雅的用户界面和丰富的音乐功能。

## 主要功能

- 🎵 **音乐播放控制** - 支持播放、暂停、上一首/下一首等基本控制
- 🔍 **智能搜索** - 快速查找歌曲、专辑和艺术家
- 📚 **音乐库管理** - 按专辑、歌手、歌单等分类浏览音乐
- 📝 **歌词显示** - 支持歌词解析和同步显示
- 🎨 **精美界面** - 蓝色主题设计，现代化UI体验
- 📱 **跨平台支持** - 一套代码，多平台运行

## 技术栈

- **框架**: Flutter
- **语言**: Dart
- **状态管理**: Provider
- **网络请求**: http
- **音频播放**: just_audio
- **图片缓存**: cached_network_image
- **架构模式**: 分层架构 (models, providers, screens, services, widgets)

## 项目结构

```
lib/
├── main.dart                    # 应用入口
├── models/                      # 数据模型层
│   ├── song.dart               # 歌曲模型
│   └── lyric_line.dart         # 歌词行模型
├── providers/                   # 状态管理层
│   └── music_provider.dart     # 音乐播放状态管理
├── screens/                     # 页面层
│   ├── splash_screen.dart      # 启动页面
│   ├── home_screen.dart        # 主页面
│   ├── player_screen.dart      # 播放器页面
│   └── search_result_screen.dart # 搜索结果页面
├── services/                    # 服务层
│   └── api_service.dart        # API服务
└── widgets/                     # 组件层
    ├── mini_player.dart        # 迷你播放器组件
    ├── search_bar.dart         # 搜索栏组件
    └── song_list_item.dart     # 歌曲列表项组件
```

## 开始使用

### 环境要求

- Flutter SDK >= 2.19.0
- Dart SDK >= 2.19.0
- Android SDK (Android开发)
- Xcode (iOS开发)

### 安装步骤

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd xiaobeike_music_player
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **运行应用**
   ```bash
   # Android
   flutter run
   
   # iOS
   flutter run -d ios
   
   # Web
   flutter run -d web
   ```

### 构建发布版本

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 应用图标

项目使用蓝色主题的应用图标，支持Android自适应图标和iOS图标。图标文件位于：
- `assets/images/app_icon_blue.png` - 主应用图标
- `assets/images/logo_blue.svg` - SVG格式logo

## 开发指南

### 添加新功能

1. 在相应的目录下创建新文件
2. 遵循现有的代码结构和命名规范
3. 使用Provider进行状态管理
4. 确保代码通过lint检查

### 代码规范

- 使用 `flutter_lints` 进行代码规范检查
- 遵循Dart官方代码风格指南
- 为公共方法添加文档注释
- 保持代码简洁和可读性

## 贡献指南

欢迎提交Issue和Pull Request来改进项目！

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。


本项目所使用 api 来源于网络分享，如有侵权请联系作者删除。

**香槟音乐播放器** - 让音乐更美好 🎵