# 开发指南

## 环境要求

- Xcode 15.0 或更高版本
- iOS 17.0 或更高版本
- Swift 5.9 或更高版本

## 项目设置

1. 克隆项目仓库
2. 使用 Xcode 打开 `ComicsViewer.xcodeproj`
3. 选择目标设备（模拟器或真机）
4. 编译并运行项目

## 代码结构

项目遵循模块化设计原则，将不同功能分离到独立的文件中：

- **Models**: 数据模型相关代码
- **Views**: SwiftUI 视图组件
- **Components**: 自定义组件
- **Extensions**: 系统类扩展

## 编码规范

### 命名规范

- 类名使用 PascalCase
- 函数名和变量名使用 camelCase
- 常量名使用 UPPER_CASE
- 文件名与主要类型名保持一致

### 代码组织

- 每个文件只包含一个主要类型
- 相关功能组织在同一个目录下
- 使用扩展来组织协议实现

### 注释规范

- 使用中文注释
- 公共接口必须有详细注释
- 复杂逻辑需要添加实现说明

## 性能优化

### 图片处理

- 使用缩略图减少内存占用
- 实现图片缓存避免重复加载
- 异步加载大图避免阻塞主线程

### 数据管理

- 使用 SwiftData 进行数据持久化
- 合理使用 @Query 和 @Binding
- 及时清理不需要的数据和缓存

## 测试

### 单元测试

项目使用 XCTest 框架进行单元测试：

```swift
func testComicProjectCreation() {
    let images = [UIImage()]
    let comic = ComicProject(images: images, title: "Test Comic")
    XCTAssertEqual(comic.title, "Test Comic")
}
```

### UI 测试

使用 XCUITest 进行界面测试：

```swift
func testComicImport() {
    let app = XCUIApplication()
    app.buttons["Import"].tap()
    // 验证导入功能
}
```

## 调试技巧

### 使用预览

利用 SwiftUI 的预览功能快速查看界面效果：

```swift
#Preview {
    ContentView()
        .modelContainer(for: ComicProject.self, inMemory: true)
}
```

### 日志输出

使用 `print()` 或 `os_log()` 输出调试信息：

```swift
import os
let logger = Logger(subsystem: "com.example.ComicsViewer", category: "debug")
logger.info("图片加载完成")
```

## 常见问题

### 编译错误

- 确保所有依赖库已正确导入
- 检查 SwiftData 模型是否正确标记
- 确认 Xcode 版本符合要求

### 运行时错误

- 检查图片路径是否正确
- 验证文件权限设置
- 确认设备存储空间充足

## 贡献指南

1. Fork 项目仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request