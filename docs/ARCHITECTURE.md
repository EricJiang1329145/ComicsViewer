# ComicsViewer 架构设计

## 概述

ComicsViewer 是一个基于 SwiftUI 和 SwiftData 的本地漫画阅读管理应用。应用采用模块化设计，将不同功能分离到独立的文件中，以提高代码的可维护性和可读性。

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

## 模块说明

### 1. Models (数据模型)

`ComicProject.swift` 包含了应用的核心数据模型：

- `ComicProject`: 使用 @Model 宏标记的 SwiftData 模型类
- 属性：
  - `id`: 唯一标识符
  - `filePaths`: 图片文件路径数组
  - `title`: 漫画标题
  - `createDate`: 创建日期
- 方法：
  - `init(images:title:)`: 初始化方法
  - `deleteFiles()`: 删除关联文件
  - `loadImages(completion:)`: 异步加载图片
- 缓存机制：
  - `thumbnailCache`: 缩略图缓存
  - `mainImageCache`: 主图缓存

### 2. Views (视图)

`ContentView.swift` 是应用的主要视图，负责展示漫画库和导航结构。

`ComicDetailView.swift` 是漫画详情视图，负责展示漫画的所有图片。

### 3. Components (组件)

`ImagePicker.swift` 和 `FileDocumentPicker.swift` 是自定义的 UIViewControllerRepresentable 组件，用于从相册或文件系统选择图片。

### 4. Extensions (扩展)

`FileManager+Extensions.swift` 和 `UIImage+Extensions.swift` 提供了对系统类的扩展功能。

### 5. 应用入口

`ComicApp.swift` 是应用的入口点，负责初始化 SwiftData 模型容器。

## 数据流

1. 用户通过 ImagePicker 或 FileDocumentPicker 导入图片
2. 创建 ComicProject 实例并保存到 SwiftData
3. ContentView 展示漫画库列表
4. 用户选择漫画查看 ComicDetailView
5. ComicDetailView 加载并显示漫画图片

## 性能优化

1. 图片缓存：使用 NSCache 实现缩略图和主图缓存
2. 异步加载：图片加载在后台队列进行，避免阻塞主线程
3. 内存管理：设置缓存大小限制和自动清理机制