import UIKit

extension UIImage {
    func saveToDocuments(filename: String) {
        if let data = jpegData(compressionQuality: 0.8) {
            let url = FileManager.default.documentsDirectory.appendingPathComponent(filename)
            try? data.write(to: url)
        }
    }
    
    func resized(to size: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}