import SwiftUI

// 密码验证视图
struct PasswordView: View {
    @Binding var isUnlocked: Bool
    @State private var password: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    // 默认密码为 081201
    private let defaultPassword = "081201"
    
    // 从UserDefaults获取存储的密码，如果不存在则使用默认密码
    private var storedPassword: String {
        UserDefaults.standard.string(forKey: "comicViewerPassword") ?? defaultPassword
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // 应用标题
            Text("漫画查看器")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // 密码输入框
            SecureField("请输入密码", text: $password)
                .padding()
                .frame(maxWidth: 300)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .font(.title2)
                .keyboardType(.numberPad)
                .textContentType(.password)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.none)
                .onSubmit {
                    verifyPassword()
                }
            
            // 登录按钮
            Button(action: verifyPassword) {
                Text("登录")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 300)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .disabled(password.isEmpty)
            
            // 错误提示
            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.subheadline)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    // 验证密码
    private func verifyPassword() {
        if password == storedPassword {
            isUnlocked = true
            showError = false
        } else {
            showError = true
            errorMessage = "密码错误，请重试"
            password = ""
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