//
//  Tickme2App.swift
//  Tickme2
//

import SwiftUI
import FirebaseCore

@main
struct Tickme2App: App {
    @StateObject private var auth = FirebaseAuthManager()
    @StateObject private var taskStore = TaskStore()

    // Global appearance setting (0 = System, 1 = Light, 2 = Dark)
    @AppStorage("appearanceMode") private var appearanceModeRaw: Int = 0

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            AuthGateView()
                .environmentObject(auth)
                .environmentObject(taskStore)
                .preferredColorScheme(colorSchemeFromSetting())
        }
    }

    private func colorSchemeFromSetting() -> ColorScheme? {
        switch appearanceModeRaw {
        case 1: return .light
        case 2: return .dark
        default: return nil // System default
        }
    }
}
