//
//  TagsManager.swift
//  Povareshka
//
//  Created by user on 20.06.2025.
//

import UIKit

final class TagsManager {
    private(set) var tags: [String]
    var onChange: (([String]) -> Void)?
    
    init(tags: [String] = []) {
        self.tags = tags
    }
    
    func addTag(_ tag: String) {
        let trimmedTag = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTag.isEmpty, !tags.contains(trimmedTag) else { return }
        tags.append(trimmedTag)
        onChange?(tags)
    }
    
    func removeTag(at index: Int) {
        guard tags.indices.contains(index) else { return }
        tags.remove(at: index)
        onChange?(tags)
    }
    
    func setTags(_ newTags: [String]) {
        tags = newTags
        onChange?(tags)
    }
}
