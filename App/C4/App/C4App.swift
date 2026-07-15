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
    var container: ModelContainer = {
        let schema = Schema([
            Character.self,
            Experience.self,
            Keyword.self,
            Attachment.self,
            Episode.self
        ])
        let configuration = ModelConfiguration(schema: schema)
        
        do {
            return try ModelContainer(for: schema, configurations: configuration)
        } catch {
            fatalError("ModelContainer failed: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}
