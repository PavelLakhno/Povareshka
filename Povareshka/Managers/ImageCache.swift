//
//  ImageCache.swift
//  Povareshka
//
//  Created by user on 05.08.2025.
//

import UIKit


final class ImageCache {
    @MainActor static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    func image(for key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func setImage(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}
