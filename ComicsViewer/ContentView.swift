import SwiftUI
import PhotosUI
import UIKit
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var comics: [ComicProject]
    
    @State private var selectedImages: [UIImage] = []
    @State private var showPicker = false
    @State private var showFilePicker = false
    @State private var selectedComic: ComicProject?
    @State private var showSettings = false
    
    var body: some View {
        NavigationSplitView {
            List(comics, selection: $selectedComic) { comic in
                NavigationLink(value: comic) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(uiImage: comic.thumbnail ?? UIImage())
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 90)
                            .cornerRadius(4)
                            .clipped()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(comic.title)
                                .font(.subheadline)
                                .lineLimit(2)
                            Text(comic.createDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        deleteSelectedComic(comic)
                    } label: {
                        Label("删除", systemImage: "trash")
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("漫画库")
            .toolbar {
                // 设置按钮
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gear")
                            .font(.title2)
                    }
                }
                
                // 立即锁定按钮
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // 调用立即锁定方法
                        AppState.shared.lockImmediately()
                    }) {
                        Image(systemName: "lock")
                            .font(.title2)
                    }
                }
                
                // 主操作按钮
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            showFilePicker = true
                        } label: {
                            Label("从文件导入", systemImage: "folder")
                        }
                        
                        Button {
                            showPicker = true
                        } label: {
                            Label("从图库导入", systemImage: "photo")
                        }
                        
                        Button(role: .destructive) {
                            clearCaches()
                        } label: {
                            Label("释放缓存", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2.bold())
                    }
                }
            }
            
            // 设置页面
            .sheet(isPresented: $showSettings) {
                PasswordChangeView()
            }
        } detail: {
            if let selectedComic {
                ComicDetailView(comic: selectedComic)
            } else {
                Text("请选择漫画")
                    .foregroundStyle(.secondary)
            }
        }
        .sheet(isPresented: $showPicker) {
            ImagePicker(selectedImages: $selectedImages) {
                createNewComic()
            }
        }
        .sheet(isPresented: $showFilePicker) {
            FileDocumentPicker(selectedImages: $selectedImages) {
                createNewComic()
            }
        }
    }
    
    // 新增分页加载方法
    private func loadMoreContentIfNeeded(currentItem comic: ComicProject) {
        guard let index = comics.firstIndex(where: { $0.id == comic.id }),
              index == comics.count - 2 else { return }
        
        // 模拟分页加载，实际应替换为真实数据加载逻辑
        let newComics = (0..<5).map { i in
            ComicProject(images: [], title: "新漫画 \(comics.count + i)")
        }
        newComics.forEach(modelContext.insert)
    }
    
    private func createNewComic() {
        let newComic = ComicProject(
            images: selectedImages,
            title: "漫画\(comics.count + 1)"
        )
        modelContext.insert(newComic)
        selectedImages.removeAll()
    }
    
    private func deleteComic(at offsets: IndexSet) {
        for index in offsets {
            let comic = comics[index]
            comic.deleteFiles()
            modelContext.delete(comic)
        }
    }
    
    private func deleteSelectedComic(_ comic: ComicProject) {
        comic.deleteFiles()
        modelContext.delete(comic)
    }

    private func clearCaches() {
        ComicProject.clearCaches()
    }
}

#Preview("默认预览") {
    ContentView()
        .modelContainer(for: ComicProject.self, inMemory: true)
}
