//
//  GeneralSettingsView.swift
//  Tickme2
//
//  Created by Matala on 2025-12-22.
//

import SwiftUI

struct GeneralSettingsView: View {
    @AppStorage("defaultStartTab") private var defaultStartTab: Int = 0
    @State private var showResetConfirm = false

    var body: some View {
        Form {
            Section("App Preferences") {
                Picker("Default Start Screen", selection: $defaultStartTab) {
                    Text("Home").tag(0)
                    Text("Account").tag(1)
                    Text("Tick").tag(2)
                    Text("Calendar").tag(3)
                    Text("Settings").tag(4)
                }
            }

            Section("System") {
                HStack {
                    Text("Language")
                    Spacer()
                    Text("Uses device language")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Time Format")
                    Spacer()
                    Text("Uses device settings")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Data") {
                Text("If you reset TickMe, your local tasks, notes, and saved settings on this device will be removed.")
                    .foregroundStyle(.secondary)

                Button(role: .destructive) {
                    showResetConfirm = true
                } label: {
                    Text("Reset TickMe Data")
                }
            }
        }
        .navigationTitle("General")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Reset TickMe Data?", isPresented: $showResetConfirm) {
            Button("Reset", role: .destructive) {
                resetLocalAppData()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will delete local TickMe data on this device. This action cannot be undone.")
        }
    }

    private func resetLocalAppData() {
        // Safest reset: clear only known user settings keys.
        let defaults = UserDefaults.standard
        let keys = [
            "defaultStartTab",
            "appearanceMode",
            "showTabBadges",
            "enableHaptics",
            "largeTabIcons",
            "notifSoundsEnabled",
            "notifBadgesEnabled"
        ]
        keys.forEach { defaults.removeObject(forKey: $0) }

        // If later you persist Tick/Calendar items to UserDefaults, clear those keys here too.

        NotificationCenter.default.post(name: .tickMeDidResetData, object: nil)
    }
}

extension Notification.Name {
    static let tickMeDidResetData = Notification.Name("tickMeDidResetData")
}

