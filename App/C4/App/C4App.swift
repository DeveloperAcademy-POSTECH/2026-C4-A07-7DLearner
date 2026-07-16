//
//  C4App.swift
//  C4
//
//  Created by YOOJUN PARK on 7/13/26.
//

import SwiftUI
import SwiftData

@main
struct C4App: App {
    
    // MARK: SwiftData Container 생성
    var container: ModelContainer = {
        let schema = Schema([
            Attachment.self,
            Character.self,
            Episode.self,
            Experience.self,
            Keyword.self
        ])
        let configuration = ModelConfiguration(schema: schema)
        
        do {
            return try ModelContainer(for: schema, configurations: configuration)
        } catch {
            fatalError("ModelContainer failed: \(error)")
        }
    }()
    
    // MARK: App의 진입점 설정, Container 주입
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
    
}
