//
//  TabBarSettingsView.swift
//  Tickme2
//
//  Created by Matala on 2025-12-22.
//

import SwiftUI

struct TabBarSettingsView: View {
    @AppStorage("showTabBadges") private var showBadges: Bool = true
    @AppStorage("enableHaptics") private var enableHaptics: Bool = true
    @AppStorage("largeTabIcons") private var largeIcons: Bool = false
    @AppStorage("defaultStartTab") private var defaultStartTab: Int = 0

    var body: some View {
        Form {
            Section {
                Text("Customise how the bottom tab bar behaves.")
                    .foregroundStyle(.secondary)
            }

            Section("Options") {
                Toggle("Show Badge Alerts", isOn: $showBadges)
                Toggle("Haptic Feedback", isOn: $enableHaptics)
                Toggle("Large Icons (Easier to tap)", isOn: $largeIcons)
            }

            Section("Default Tab") {
                Picker("Default Tab", selection: $defaultStartTab) {
                    Text("Home").tag(0)
                    Text("Account").tag(1)
                    Text("Tick").tag(2)
                    Text("Calendar").tag(3)
                    Text("Settings").tag(4)
                }
            }

            Section {
                Text("These settings only affect your experience on this device.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Tab Bar")
        .navigationBarTitleDisplayMode(.inline)
    }
}
