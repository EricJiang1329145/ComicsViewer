import SwiftUI
import PhotosUI
import UIKit
import SwiftData // 新增SwiftData引入

@main
struct ComicApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: ComicProject.self) // 初始化模型容器
    }
}

@Model // 添加SwiftData模型宏
class ComicProject: Identifiable {
    var id = UUID()
    var filePaths: [String] // 改为存储文件路径
    var title: String
    var createDate = Date()
    
    // 计算属性用于访问图片
    var images: [UIImage] {
        filePaths.compactMap { path in
            UIImage(contentsOfFile: FileManager.default.documentsDirectory.appendingPathComponent(path).path)
        }
    }
    
    init(images: [UIImage], title: String) {
        self.title = title
        self.filePaths = images.enumerated().map { index, image in
            let filename = "\(UUID().uuidString)_\(index).jpg"
            image.saveToDocuments(filename: filename)
            return filename
        }
    }
    
    // 删除关联文件的方法
    func deleteFiles() {
        filePaths.forEach { path in
            let fullPath = FileManager.default.documentsDirectory.appendingPathComponent(path)
            try? FileManager.default.removeItem(at: fullPath)
        }
    }
}

extension FileManager {
    var documentsDirectory: URL {
        urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

extension UIImage {
    func normalizedOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage ?? self
    }
    func saveToDocuments(filename: String) -> Bool {
        guard let data = jpegData(compressionQuality: 0.8),
              let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(filename) else {
            return false
        }
        
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            try data.write(to: url, options: .atomic)
            return true
        } catch {
            print("Save failed: \(error.localizedDescription)")
            return false
        }
    }
}

struct ComicDetailView: View {
    @Bindable var comic: ComicProject // 改为使用Bindable
    @State private var isEditing = false
    @State private var tempTitle: String
    
    init(comic: ComicProject) {
        self.comic = comic
        self.tempTitle = comic.title
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(comic.images, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 350) // 调整最大宽度
                        .padding(.vertical, 2)
                        .frame(maxWidth: .infinity, alignment: .center) // 添加居中对齐
                }
            }
        }
        .navigationTitle(isEditing ? "" : comic.title)  // 编辑时隐藏原标题
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditing {
                    // 完成编辑按钮
                    Button("完成") {
                        comic.title = tempTitle  // 更新原数据标题
                        isEditing = false
                    }
                } else {
                    // 进入编辑按钮
                    Button("编辑") {
                        tempTitle = comic.title  // 同步当前标题到临时变量
                        isEditing = true
                    }
                }
            }
        }
        .overlay {
            if isEditing {
                // 编辑输入框覆盖层
                VStack {
                    TextField("输入漫画名称", text: $tempTitle)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                }
                .padding()
                .background(Color(.systemBackground).opacity(0.9))
                .cornerRadius(12)
            }
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var comics: [ComicProject]
    
    @State private var selectedImages: [UIImage] = []
    @State private var showPicker = false
    @State private var showFilePicker = false
    @State private var isEditMode = false
    @State private var selectedComics = Set<UUID>()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: 16)], spacing: 16) {
                    ForEach(comics) { comic in
                        ComicGridItem(comic: comic, isEditMode: $isEditMode, isSelected: .constant(selectedComics.contains(comic.id)))
                            .onTapGesture {
                                if isEditMode {
                                    if selectedComics.contains(comic.id) {
                                        selectedComics.remove(comic.id)
                                    } else {
                                        selectedComics.insert(comic.id)
                                    }
                                }
                            }
                    }
                }
                .padding(16)
            }
            .navigationTitle("我的漫画库")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(isEditMode ? "取消" : "编辑") {
                        isEditMode.toggle()
                        if !isEditMode {
                            selectedComics.removeAll()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isEditMode && !selectedComics.isEmpty {
                        Button(role: .destructive) {
                            deleteSelectedComics()
                        } label: {
                            Text("删除(\(selectedComics.count))")
                        }
                    }
                }
            }
        }
    }

    private func deleteSelectedComics() {
        comics.filter { selectedComics.contains($0.id) }.forEach { comic in
            comic.deleteFiles()
            modelContext.delete(comic)
        }
        selectedComics.removeAll()
        isEditMode = false
    }
}

struct ComicGridItem: View {
    let comic: ComicProject
    @Binding var isEditMode: Bool
    @Binding var isSelected: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            NavigationLink {
                ComicDetailView(comic: comic)
            } label: {
                HStack(spacing: 12) {
                    Image(uiImage: comic.images.first ?? UIImage())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 150)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                
                    VStack(alignment: .leading, spacing: 8) {
                        Text(comic.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("包含\(comic.images.count)张图片")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(comic.createDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 8)
                }
                .padding(12)
                .background(Color(.systemBackground))
                .cornerRadius(16)
            }
            .disabled(isEditMode)
            
            if isEditMode {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .padding(8)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("点击+号添加漫画")
                .font(.title3)
                .foregroundColor(.gray)
        }
        .padding(.top, 100)
    }
}

// 删除整个FolderComicPicker结构体定义

#Preview("带数据预览") {
    ContentView()
        .modelContainer(for: ComicProject.self, inMemory: true)
}

#Preview("空数据预览") {
    ContentView()
        .modelContainer(for: ComicProject.self, inMemory: true)
}
