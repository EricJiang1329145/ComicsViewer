import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showPasswordChange = false
    
    // 动画状态
    @State private var titleOffset: CGFloat = -30
    @State private var titleOpacity: Double = 0
    @State private var settingsOffset: CGFloat = 30
    @State private var settingsOpacity: Double = 0
    
    // 背景圆球动画状态
    @State private var ballOffsets: [CGSize] = Array(repeating: CGSize.zero, count: 5)
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景渐变
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.2, green: 0.1, blue: 0.3)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // 装饰性圆球背景
                GeometryReader { geometry in
                    ForEach(0..<5, id: \.self) { index in
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.1),
                                        Color.white.opacity(0.05)
                                    ]),
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 100
                                )
                            )
                            .frame(width: CGFloat.random(in: 100...200))
                            .position(
                                x: CGFloat.random(in: 0...geometry.size.width),
                                y: CGFloat.random(in: 0...geometry.size.height)
                            )
                            .offset(ballOffsets[index])
                            .opacity(0.3)
                            .onAppear {
                                // 为每个圆球设置随机浮动动画
                                let duration = Double.random(in: 15...25)
                                let randomX = CGFloat.random(in: -30...30)
                                let randomY = CGFloat.random(in: -30...30)
                                
                                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true).delay(Double(index) * 0.5)) {
                                    ballOffsets[index] = CGSize(width: randomX, height: randomY)
                                }
                            }
                    }
                }
                
                // 主要内容
                ScrollView {
                    VStack(spacing: 30) {
                        // 标题
                        VStack(spacing: 10) {
                            Text("设置")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .offset(y: titleOffset)
                                .opacity(titleOpacity)
                            
                            Text("管理您的应用偏好设置")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                                .offset(y: titleOffset)
                                .opacity(titleOpacity)
                        }
                        .padding(.top, 20)
                        
                        // 设置项列表
                        VStack(spacing: 15) {
                            // 修改密码设置项
                            SettingsItemView(
                                icon: "lock.shield.fill",
                                title: "修改密码",
                                subtitle: "更改您的应用密码",
                                iconColor: .blue,
                                action: {
                                    showPasswordChange = true
                                }
                            )
                            
                            // 其他设置项（可扩展）
                            SettingsItemView(
                                icon: "photo.fill",
                                title: "图片质量",
                                subtitle: "设置图片显示质量",
                                iconColor: .green,
                                action: {
                                    // 预留功能
                                }
                            )
                            
                            SettingsItemView(
                                icon: "paintbrush.fill",
                                title: "主题外观",
                                subtitle: "自定义应用外观",
                                iconColor: .purple,
                                action: {
                                    // 预留功能
                                }
                            )
                            
                            SettingsItemView(
                                icon: "info.circle.fill",
                                title: "关于应用",
                                subtitle: "版本信息和帮助",
                                iconColor: .orange,
                                action: {
                                    // 预留功能
                                }
                            )
                        }
                        .padding(.horizontal, 20)
                        .offset(y: settingsOffset)
                        .opacity(settingsOpacity)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showPasswordChange) {
                PasswordChangeView()
            }
        }
        .onAppear {
            // 页面加载时的动画
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                titleOffset = 0
                titleOpacity = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.8).delay(0.5)) {
                settingsOffset = 0
                settingsOpacity = 1.0
            }
        }
    }
}

// 设置项视图组件
struct SettingsItemView: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // 添加按压动画
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed = false
                }
            }
            
            action()
        }) {
            HStack(spacing: 15) {
                // 图标
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(iconColor)
                }
                
                // 文本内容
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // 箭头图标
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview("设置页面预览") {
    SettingsView()
}