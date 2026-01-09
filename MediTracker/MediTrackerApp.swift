//
//  MediTrackerApp.swift
//  MediTracker
//
//  Created by πcanmar on 25/11/25.
//

import SwiftUI
import SwiftData

@main
struct MediTrackerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Medicamento.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
            GerenciadorNotificacao.instance.pedirPermissao()
        }

    var body: some Scene {
        WindowGroup {
            SplashView()
        }
        .modelContainer(sharedModelContainer)
    }
}
