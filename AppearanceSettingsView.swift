//
//  AppearanceSettingsView.swift
//  Tickme2
//

import SwiftUI

struct AppearanceSettingsView: View {

    enum AppearanceMode: Int, CaseIterable, Identifiable {
        case system = 0
        case light = 1
        case dark = 2

        var id: Int { rawValue }

        var title: String {
            switch self {
            case .system: return "System Default"
            case .light:  return "Light Mode"
            case .dark:   return "Dark Mode"
            }
        }
    }

    @AppStorage("appearanceMode") private var appearanceModeRaw: Int = 0
    @State private var highContrast: Bool = false

    var body: some View {
        Form {
            Section {
                Text("Choose how TickMe looks on your device.")
                    .foregroundStyle(.secondary)
            }

            Section("Theme") {
                Picker("Appearance", selection: $appearanceModeRaw) {
                    ForEach(AppearanceMode.allCases) { mode in
                        Text(mode.title).tag(mode.rawValue)
                    }
                }
            }

            Section("Accessibility") {
                Toggle("High Contrast Text", isOn: $highContrast)
                Text("Appearance changes apply instantly and can be changed anytime.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)

        // This is only for previewing while you're on this screen.
        // The actual global app theme is applied in Tickme2App.swift.
        .preferredColorScheme(colorSchemeFromSetting())
    }

    private func colorSchemeFromSetting() -> ColorScheme? {
        switch AppearanceMode(rawValue: appearanceModeRaw) ?? .system {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}
