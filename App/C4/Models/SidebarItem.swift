//
//  SidebarItem.swift
//  C4
//
//  Created by YOOJUN PARK on 7/14/26.
//

enum SidebarItem: String, CaseIterable {
    case home = "홈"
    case experience = "경험"
    case character = "캐릭터"
    
    var icon: String {
        switch self {
        case .home: "house"
        case .experience: "tray.2"
        case .character: "person.crop.rectangle.stack"
        }
    }
}
