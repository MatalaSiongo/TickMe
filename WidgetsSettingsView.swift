//
//  WidgetsSettingsView.swift
//  Tickme2
//
//  Created by Matala on 2025-12-22.
//

import SwiftUI

struct WidgetsSettingsView: View {
    @AppStorage("widgetsEnabled") private var widgetsEnabled: Bool = true
    @AppStorage("widgetShowTodayCount") private var widgetShowTodayCount: Bool = true

    var body: some View {
        Form {
            Section {
                Text("Widgets let you see your most important TickMe updates directly on your Home Screen.")
                    .foregroundStyle(.secondary)
            }

            Section("Widget Preferences") {
                Toggle("Enable Widgets", isOn: $widgetsEnabled)

                Toggle("Show Today Count", isOn: $widgetShowTodayCount)
                    .disabled(!widgetsEnabled)

                Text("These options will apply when TickMe widgets are added to your Home Screen.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("How to Add Widgets") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("1. Long-press an empty area on your Home Screen")
                    Text("2. Tap the + button")
                    Text("3. Search for “TickMe”")
                    Text("4. Choose a widget size and add it")
                }
                .foregroundStyle(.secondary)
            }

            Section {
                Button("Open iPhone Settings") {
                    openAppSettings()
                }

                Text("If you don’t see TickMe in the widget list yet, widgets may be added in a future update.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Widgets")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
