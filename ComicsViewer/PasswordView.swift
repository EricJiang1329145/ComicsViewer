import SwiftUI

// 背景圆球数据结构
struct BackgroundBall: Identifiable {
    let id = UUID()
    var size: CGFloat
    var position: CGPoint
    var opacity: Double
    var offset: CGSize = .zero
    var animationDuration: Double
    var moveRange: CGFloat
    
    init(size: CGFloat, position: CGPoint, opacity: Double, animationDuration: Double, moveRange: CGFloat) {
        self.size = size
        self.position = position
        self.opacity = opacity
        self.animationDuration = animationDuration
        self.moveRange = moveRange
    }
}

// 密码验证视图
struct PasswordView: View {
    @Binding var isUnlocked: Bool
    @State private var password: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isPasswordFocused: Bool = false
    @State private var shakeOffset: CGFloat = 0
    @State private var showSuccessAnimation: Bool = false
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    
    // 背景圆球数组
    @State private var backgroundBalls: [BackgroundBall] = []
    
    // 默认密码为 081201
    private let defaultPassword = "081201"
    
    // 从UserDefaults获取存储的密码，如果不存在则使用默认密码
    private var storedPassword: String {
        UserDefaults.standard.string(forKey: "comicViewerPassword") ?? defaultPassword
    }
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // 装饰性圆形元素
            ForEach(backgroundBalls) { ball in
                Circle()
                    .fill(Color.white.opacity(ball.opacity))
                    .frame(width: ball.size, height: ball.size)
                    .offset(x: ball.position.x + ball.offset.width, y: ball.position.y + ball.offset.height)
            }
            
            VStack(spacing: 24) {
                Spacer()
                
                // 应用标题
                Text("漫画查看器")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .scaleEffect(titleScale)
                    .opacity(titleOpacity)
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                
                // 密码输入框
                SecureField("请输入密码", text: $password)
                    .padding()
                    .frame(maxWidth: 300)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.secondarySystemBackground))
                            .shadow(color: isPasswordFocused ? Color.blue.opacity(0.5) : Color.clear, radius: 5, x: 0, y: 0)
                    )
                    .scaleEffect(isPasswordFocused ? 1.05 : 1.0)
                    .offset(x: shakeOffset)
                    .font(.title2)
                    .keyboardType(.numberPad)
                    .textContentType(.password)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.none)
                    .onTapGesture {
                        isPasswordFocused = true
                    }
                    .onSubmit {
                        verifyPassword()
                    }
                    .animation(.easeInOut(duration: 0.2), value: isPasswordFocused)
                
                // 登录按钮
                Button(action: verifyPassword) {
                    Text("登录")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 300)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(10)
                        .shadow(color: Color.blue.opacity(0.5), radius: 5, x: 0, y: 2)
                }
                .disabled(password.isEmpty)
                .scaleEffect(password.isEmpty ? 0.95 : 1.0)
                .opacity(password.isEmpty ? 0.7 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: password.isEmpty)
                
                // 错误提示
                if showError {
                    Text(errorMessage)
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.red.opacity(0.8))
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
                        .animation(.easeInOut(duration: 0.3), value: showError)
                }
                
                Spacer()
            }
            .padding()
        }
        .overlay(
            // 成功动画视图
            Group {
                if showSuccessAnimation {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                        
                        VStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.green)
                                .scaleEffect(showSuccessAnimation ? 1.2 : 0.1)
                                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showSuccessAnimation)
                            
                            Text("验证成功")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .opacity(showSuccessAnimation ? 1 : 0)
                                .animation(.easeInOut(duration: 0.5).delay(0.2), value: showSuccessAnimation)
                        }
                    }
                    .transition(.opacity)
                }
            }
        )
        .onAppear {
            // 标题动画
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                titleScale = 1.0
                titleOpacity = 1.0
            }
            
            // 初始化随机背景圆球
            initializeBackgroundBalls()
        }
    }
    
    // 初始化随机背景圆球
    private func initializeBackgroundBalls() {
        // 生成5-10个随机圆球
        let ballCount = Int.random(in: 5...10)
        var balls: [BackgroundBall] = []
        
        for _ in 0..<ballCount {
            // 随机大小 (40-200)
            let size = CGFloat.random(in: 40...200)
            
            // 随机位置 (分布在屏幕周围)
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            let x = CGFloat.random(in: -screenWidth/2...screenWidth/2)
            let y = CGFloat.random(in: -screenHeight/2...screenHeight/2)
            let position = CGPoint(x: x, y: y)
            
            // 随机透明度 (0.03-0.15)
            let opacity = Double.random(in: 0.03...0.15)
            
            // 随机动画持续时间 (3-8秒，比原来快很多)
            let animationDuration = Double.random(in: 1...4)
            
            // 随机移动范围 (20-60)
            let moveRange = CGFloat.random(in: 20...60)
            
            let ball = BackgroundBall(
                size: size,
                position: position,
                opacity: opacity,
                animationDuration: animationDuration,
                moveRange: moveRange
            )
            
            balls.append(ball)
        }
        
        backgroundBalls = balls
        
        // 为每个圆球启动动画
        for index in balls.indices {
            let ball = balls[index]
            let randomX = CGFloat.random(in: -ball.moveRange...ball.moveRange)
            let randomY = CGFloat.random(in: -ball.moveRange...ball.moveRange)
            
            withAnimation(.easeInOut(duration: ball.animationDuration).repeatForever(autoreverses: true)) {
                backgroundBalls[index].offset = CGSize(width: randomX, height: randomY)
            }
        }
    }
    
    // 验证密码
    private func verifyPassword() {
        if password == storedPassword {
            // 密码正确，显示成功动画
            showSuccessAnimation = true
            
            // 重置焦点状态
            isPasswordFocused = false
            
            // 延迟后解锁
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isUnlocked = true
                }
            }
        } else {
            // 密码错误，触发震动动画
            withAnimation(.easeInOut(duration: 0.1).repeatCount(5, autoreverses: true)) {
                shakeOffset = 10
            }
            
            // 震动结束后重置偏移
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    shakeOffset = 0
                }
            }
            
            // 显示错误信息
            showError = true
            errorMessage = "密码错误，请重试"
            password = ""
            
            // 3秒后隐藏错误信息
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showError = false
            }
        }
    }
}

// 密码修改视图
struct PasswordChangeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showSuccess: Bool = false
    
    // 默认密码为 081201
    private let defaultPassword = "081201"
    
    // 从UserDefaults获取存储的密码，如果不存在则使用默认密码
    private var storedPassword: String {
        UserDefaults.standard.string(forKey: "comicViewerPassword") ?? defaultPassword
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("修改密码")) {
                    SecureField("当前密码", text: $currentPassword)
                        .keyboardType(.numberPad)
                        .textContentType(.password)
                    
                    SecureField("新密码", text: $newPassword)
                        .keyboardType(.numberPad)
                        .textContentType(.newPassword)
                    
                    SecureField("确认新密码", text: $confirmPassword)
                        .keyboardType(.numberPad)
                        .textContentType(.newPassword)
                }
                
                Section {
                    Button(action: changePassword) {
                        Text("确认修改")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity)
                    .disabled(newPassword.isEmpty || confirmPassword.isEmpty || currentPassword.isEmpty)
                }
                
                // 错误提示
                if showError {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                // 成功提示
                if showSuccess {
                    Section {
                        Text("密码修改成功！")
                            .foregroundColor(.green)
                    }
                }
            }
            .navigationTitle("密码设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // 修改密码
    private func changePassword() {
        // 验证当前密码
        if currentPassword != storedPassword {
            showError = true
            errorMessage = "当前密码错误"
            showSuccess = false
            return
        }
        
        // 验证新密码
        if newPassword.count < 4 {
            showError = true
            errorMessage = "新密码长度不能少于4位"
            showSuccess = false
            return
        }
        
        // 验证确认密码
        if newPassword != confirmPassword {
            showError = true
            errorMessage = "两次输入的新密码不一致"
            showSuccess = false
            return
        }
        
        // 保存新密码
        UserDefaults.standard.set(newPassword, forKey: "comicViewerPassword")
        
        // 显示成功信息
        showSuccess = true
        showError = false
        
        // 清空输入框
        currentPassword = ""
        newPassword = ""
        confirmPassword = ""
        
        // 延迟关闭视图
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }
}

#Preview("密码验证预览") {
    PasswordView(isUnlocked: .constant(false))
}

#Preview("密码修改预览") {
    PasswordChangeView()
}