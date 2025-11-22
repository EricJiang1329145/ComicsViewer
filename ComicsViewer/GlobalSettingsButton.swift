import SwiftUI

// 全局设置按钮组件
struct GlobalSettingsButton: View {
    @StateObject private var appState = AppState.shared
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Spacer()
                    
                    // 设置按钮
                    Button(action: {
                        appState.showSettings = true
                        print("[ComicsViewer] 用户点击全局设置按钮")
                    }) {
                        Image(systemName: "gear")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .frame(width: 44, height: 44)
                            .background(Color(.systemBackground).opacity(0.8))
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 50) // 适配状态栏高度
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .allowsHitTesting(true) // 确保按钮可以点击
        .sheet(isPresented: $appState.showSettings) {
            SettingsView()
        }
    }
}