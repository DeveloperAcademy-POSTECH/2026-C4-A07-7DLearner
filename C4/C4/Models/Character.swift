//
//  Character.swift
//  C4
//
//  Created by YOOJUN PARK on 7/13/26.
//

import SwiftData
import Foundation

@Model
final class Character {
    var id: UUID
    
    @Relationship(inverse: \Keyword.characters)
    var keywords: [Keyword] = []
    
    init(name: String) {
        self.id = UUID()
    }
}
