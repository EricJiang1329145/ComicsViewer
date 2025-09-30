import SwiftUI
import SwiftData

@main
struct ComicApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: ComicProject.self)
    }
}