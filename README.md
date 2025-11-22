# ComicsViewer

📚 专业的本地漫画阅读管理应用 - SwiftUI + SwiftData 实现

## 功能特性

✅ 双模式导入
- 相册图片批量导入
- 文件系统直接选择

✅ 智能管理
- 自动持久化存储
- 图片元数据管理
- 创建时间自动记录

✅ 阅读体验
- 自适应图片布局
- 居中优化显示
- 阅读进度记忆

✅ 数据安全
- 本地沙盒存储
- 删除联动清理
- 数据加密保护
- 应用密码保护
- 自定义密码设置
- 后台锁定机制

✅ 界面美化
- 密码页面动画效果
- 渐变背景和装饰元素
- 交互动画和过渡效果
- 现代化UI设计
- 动态背景圆球动画
- 增强的验证成功弹出动画
- 美化的密码设置页面UI
- 丰富的页面动画效果
- 全新的设置页面设计
- 设置按钮全局可见性

## 技术栈

- **SwiftUI** - 声明式UI框架
- **SwiftData** - 原生数据持久化
- **PhotosUI** - 系统相册集成
- **FileProvider** - 文件系统交互

## 项目结构

```
ComicsViewer/
├── Models/                 
│   └── ComicProject.swift  # 漫画项目模型
├── Views/                  
│   └── ComicDetailView.swift # 漫画详情视图
├── Components/             
│   ├── ImagePicker.swift   # 图片选择器
│   └── FileDocumentPicker.swift # 文件选择器
├── Extensions/             
│   ├── FileManager+Extensions.swift # 文件管理扩展
│   └── UIImage+Extensions.swift # 图片处理扩展
├── ContentView.swift       # 主内容视图
└── ComicApp.swift          # 应用入口
```

## 快速开始

1. 克隆仓库
```bash
git clone https://github.com/yourname/ComicsViewer.git
```

2. 使用Xcode 15+ 打开项目
```bash
cd ComicsViewer
open ComicsViewer.xcodeproj
```

3. 配置签名
- 选择开发团队
- 启用Automatically manage signing

4. 运行项目
- 选择模拟器或真机
- ⌘R 启动应用

## 应用截图

| 书架视图 | 阅读视图 | 导入界面 |
|---------|---------|---------|
| ![shelf](screenshots/shelf.png) | ![reader](screenshots/reader.png) | ![import](screenshots/import.png) |

## 贡献指南

欢迎通过Issue和PR参与改进，请遵循以下规范：
1. 新功能开发请创建feature分支
2. Bug修复请创建hotfix分支
3. 提交信息遵循Conventional Commits规范

## 许可证

本项目采用 [MIT License](LICENSE)