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
    
    // 添加内存缓存
    private static var thumbnailCache = NSCache<NSString, UIImage>()
    private static var mainImageCache = NSCache<NSString, NSArray>() // 主图内存缓存

    // 清除所有缓存
    static func clearCaches() {
        thumbnailCache.removeAllObjects()
        mainImageCache.removeAllObjects()
    }

    var thumbnail: UIImage? {
        if let cached = Self.thumbnailCache.object(forKey: id.uuidString as NSString) {
            return cached
        }
        guard let image = images.first else { return nil }
        let thumbnail = image.resized(to: CGSize(width: 160, height: 240))
        Self.thumbnailCache.setObject(thumbnail, forKey: id.uuidString as NSString)
        return thumbnail
    }

    // 优化后的图片加载方法
    func loadImages(completion: @escaping ([UIImage]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            // 先检查主图缓存
            if let cachedImages = Self.mainImageCache.object(forKey: self.id.uuidString as NSString) as? [UIImage] {
                DispatchQueue.main.async {
                    completion(cachedImages)
                }
                return
            }
            // 缓存不存在时加载文件
            let images = self.filePaths.compactMap { path in
                UIImage(contentsOfFile: FileManager.default.documentsDirectory.appendingPathComponent(path).path)?
                    .resized(to: CGSize(width: 800, height: 1200))
            }
            // 将结果存入缓存
            if !images.isEmpty {
                Self.mainImageCache.setObject(images as NSArray, forKey: self.id.uuidString as NSString)
            }
            DispatchQueue.main.async {
                completion(images)
            }
        }
    }
}

extension FileManager {
    var documentsDirectory: URL {
        urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

extension UIImage {
    func saveToDocuments(filename: String) {
        if let data = jpegData(compressionQuality: 0.8) {
            let url = FileManager.default.documentsDirectory.appendingPathComponent(filename)
            try? data.write(to: url)
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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Group {
                    if comics.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "books.vertical.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            Text("还没有收藏的漫画")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 100)
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: 16)], spacing: 16) {
                            ForEach(comics) { comic in
                                NavigationLink {
                                    ComicDetailView(comic: comic)
                                } label: {
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(uiImage: comic.images.first ?? UIImage())
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 120)
                                            .cornerRadius(6)
                                            .clipped()
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(comic.title)
                                                .font(.headline)
                                                .lineLimit(1)
                                            Text("包含\(comic.images.count)张图片")
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                            Text(comic.createDate.formatted(date: .abbreviated, time: .omitted))
                                                .font(.caption)
                                                .foregroundStyle(.tertiary)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(12)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(10)
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            deleteSelectedComic(comic)
                                        } label: {
                                            Label("删除", systemImage: "trash")
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        deleteSelectedComic(comic)
                                    } label: {
                                        Label("删除", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("漫画书架")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
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

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    var onComplete: () -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.selectedImages.removeAll()
            
            let dispatchGroup = DispatchGroup()
            let queue = DispatchQueue(label: "image.loading", qos: .userInitiated)
            
            for result in results {
                dispatchGroup.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                    queue.async {
                        if let image = image as? UIImage {
                            DispatchQueue.main.async {
                                self?.parent.selectedImages.append(image)
                            }
                        }
                        dispatchGroup.leave()
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                picker.dismiss(animated: true)
                self.parent.onComplete()
            }
        }
    }
}

struct FileDocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    var onComplete: () -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(
            documentTypes: ["public.image"],
            in: .import
        )
        picker.allowsMultipleSelection = true
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: FileDocumentPicker
        
        init(_ parent: FileDocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.selectedImages.removeAll()
            
            // 新增：按文件名升序排序URL
            let sortedUrls = urls.sorted { $0.lastPathComponent < $1.lastPathComponent }
            
            let dispatchGroup = DispatchGroup()
            let queue = DispatchQueue(label: "file.loading", qos: .userInitiated)
            
            for url in sortedUrls {  // 修改：使用排序后的URL数组
                dispatchGroup.enter()
                queue.async {
                    if let data = try? Data(contentsOf: url),
                       let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.parent.selectedImages.append(image)
                        }
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.parent.onComplete()
            }
        }
    }
}

#Preview("默认预览") {
    ContentView()
        .modelContainer(for: ComicProject.self, inMemory: true)
}

// 添加图片处理扩展
extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
