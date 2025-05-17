import SwiftUI
import PhotosUI
import UIKit

@main
struct ComicApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ComicProject: Identifiable {
    let id = UUID()
    var images: [UIImage]
    var title: String
    var createDate = Date()
}

struct ContentView: View {
    @State private var comics: [ComicProject] = []
    @State private var selectedImages: [UIImage] = []
    @State private var showPicker = false
    @State private var showFilePicker = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(comics) { comic in
                    NavigationLink {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(comic.images, id: \.self) { image in
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 2)
                                }
                            }
                        }
                        .navigationTitle(comic.title)
                    } label: {
                        HStack {
                            Image(uiImage: comic.images.first ?? UIImage())
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 120)
                                .cornerRadius(4)
                                .clipped()
                            
                            VStack(alignment: .leading) {
                                Text(comic.title)
                                    .font(.headline)
                                Text("\(comic.images.count)张 · \(comic.createDate.formatted())")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                        }
                        .padding(.vertical, 8)
                        .contextMenu {
                            Button(role: .destructive) {
                                deleteSelectedComic(comic)
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                    }
                }
                .onDelete(perform: deleteComic)
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
        comics.append(newComic)
        selectedImages.removeAll()
    }
    
    private func deleteComic(at offsets: IndexSet) {
        comics.remove(atOffsets: offsets)
    }
    
    private func deleteSelectedComic(_ comic: ComicProject) {
        if let index = comics.firstIndex(where: { $0.id == comic.id }) {
            comics.remove(at: index)
        }
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
}
