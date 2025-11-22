import SwiftUI
import SwiftData
import UIKit

// 共享应用状态
class AppState: ObservableObject {
    static let shared = AppState()
    @Published var isUnlocked: Bool = false
    
    /// 立即锁定应用
    func lockImmediately() {
        print("[ComicsViewer] 用户触发立即锁定操作")
        isUnlocked = false
        print("[ComicsViewer] 应用已锁定")
    }
}

@main
struct ComicApp: App {
    // 应用解锁状态
    @StateObject private var appState = AppState.shared
    
    // 监听应用生命周期变化
    @Environment(\.scenePhase) private var scenePhase
    
    // 自定义应用委托，用于处理应用生命周期事件
    class AppDelegate: NSObject, UIApplicationDelegate {
        func applicationDidEnterBackground(_ application: UIApplication) {
            // 应用进入后台时锁定
            print("[ComicsViewer] 应用进入后台，自动锁定")
            AppState.shared.isUnlocked = false
        }
    }
    
    // 注册应用委托
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            if appState.isUnlocked {
                ContentView()
            } else {
                PasswordView(isUnlocked: $appState.isUnlocked)
            }
        }
        .modelContainer(for: ComicProject.self)
        .onChange(of: scenePhase) { phase in
            // 当应用进入后台时重新锁定
            if phase == .background {
                print("[ComicsViewer] 场景变化检测到应用进入后台，触发锁定")
                appState.isUnlocked = false
            }
        }
    }
}