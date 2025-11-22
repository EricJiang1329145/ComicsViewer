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
- **安全功能**: 密码验证和修改相关功能

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

## 密码功能说明

### 默认密码

应用的默认密码为 `081201`。用户首次启动应用或未设置自定义密码时使用此密码。

### 密码存储

密码使用 UserDefaults 进行存储，键名为 `comicViewerPassword`。

### 应用锁定机制

- 应用启动时自动锁定，需要输入密码解锁
- 应用进入后台时自动锁定
- 从后台返回前台时需要重新输入密码解锁

### 修改密码

用户可以通过以下步骤修改密码：
1. 成功登录应用后，点击右上角的设置按钮（齿轮图标）
2. 在密码修改界面输入当前密码、新密码和确认新密码
3. 点击"确认修改"按钮保存新密码

### 密码验证规则

- 新密码长度至少为4位
- 新密码和确认密码必须一致
- 修改密码时需要验证当前密码的正确性

## UI动画和美化

### 密码页面动画效果

密码验证页面已添加以下动画和美化效果：

1. **背景渐变**
   - 使用蓝紫渐变背景，提升视觉效果
   - 添加装饰性圆形元素增加层次感

2. **标题动画**
   - 应用标题添加缩放和透明度动画
   - 使用阴影效果增强立体感

3. **密码输入框动画**
   - 聚焦时放大效果（1.05倍）
   - 聚焦时添加蓝色阴影效果
   - 密码错误时震动效果（左右摆动）

4. **登录按钮美化**
   - 使用蓝紫渐变色替代纯色背景
   - 添加阴影效果增强立体感
   - 空密码时按钮缩小并降低透明度
   - 按钮状态变化添加平滑过渡动画

5. **错误提示动画**
   - 错误提示使用红色半透明背景
   - 添加淡入淡出动画效果
   - 错误提示3秒后自动隐藏

6. **成功验证动画**
   - 密码验证成功时显示成功动画
   - 使用绿色勾选图标和文字提示
   - 添加缩放和透明度动画效果

7. **动态背景圆球**
   - 添加6个不同大小和透明度的背景圆球
   - 每个圆球以随机慢速在不同范围内移动
   - 使用不同的动画时长创造自然流畅的效果
   - 通过透明度和大小差异创造视觉层次感

### 实现技术

- 使用SwiftUI的动画系统实现各种过渡效果
- 利用@State变量控制动画状态
- 使用withAnimation和animation修饰符控制动画时机和曲线
- 使用transition实现视图切换动画

## 贡献指南

1. Fork 项目仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request