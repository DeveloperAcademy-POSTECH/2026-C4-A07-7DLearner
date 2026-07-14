//
//  Keyword.swift
//  C4
//
//  Created by YOOJUN PARK on 7/13/26.
//

import SwiftData

@Model
final class Keyword {
    // MARK: keyword 이름
    @Attribute(.unique) var name: String
    
    // MARK: keyword와 연결된 experience/character (Inverse Relationship)
    var experiences: [Experience] = []
    var characters: [Character] = []
    
    init(name: String) {
        self.name = name
    }
}
