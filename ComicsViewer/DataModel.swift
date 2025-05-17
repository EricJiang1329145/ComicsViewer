import Foundation
import SwiftUI
import UIKit

@Observable
class DataModel {
    var comicPages: [URL] = []
    let imageCache = NSCache<NSURL, UIImage>()
    
    func addPages(_ urls: [URL]) {
        comicPages.append(contentsOf: urls)
        preloadImages(for: urls)
    }
    
    func cachedImage(for url: URL) -> UIImage? {
        return imageCache.object(forKey: url as NSURL)
    }
    
    private func preloadImages(for urls: [URL]) {
        DispatchQueue.global(qos: .userInitiated).async {
            for url in urls {
                if let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {
                    self.imageCache.setObject(image, forKey: url as NSURL)
                }
            }
        }
    }
}