//
//  SidebarItem.swift
//  C4
//
//  Created by YOOJUN PARK on 7/14/26.
//

enum SidebarItem: String, CaseIterable {
    case keyword = "키워드"
    case character = "캐릭터"
    case office = "오피스"
    case draft = "임시저장"
    case trash = "휴지통"
    
    var icon: String {
        switch self {
        case .keyword: "tag"
        case .character: "person"
        case .office: "building.2"
        case .draft: "archivebox"
        case .trash: "trash"
        }
    }
    
    var isPrimarySection: Bool {
        switch self {
        case .keyword, .character, .office: true
        case .draft, .trash: false
        }
    }
}
