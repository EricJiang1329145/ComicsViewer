import SwiftUI
import UIKit
import SwiftData

@Model
class ComicProject: Identifiable {
    var id = UUID()
    var filePaths: [String]
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
    private static let thumbnailCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 50 // 限制缓存数量
        cache.totalCostLimit = 1024 * 1024 * 100 // 100MB内存限制
        return cache
    }()
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