//
//  MindSparkApp.swift
//  MindSpark
//
//  Created on 2026-01-25.
//

import SwiftUI

@main
struct MindSparkApp: App {
    @StateObject private var appState = AppStateManager()
    @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.currentTheme == .dark ? .dark : .light)
        }
    }
}
