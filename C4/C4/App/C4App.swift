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
            Keyword.self
        ])
        let configuration = ModelConfiguration(schema: schema)
        
        guard let container = try? ModelContainer(for: schema, configurations: configuration) else {
            fatalError("ModelContainer failed")
        }
        return container
    }()
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}
