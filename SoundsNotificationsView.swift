//
//  SoundsNotificationsView.swift
//  Tickme2
//
//  Created by Matala on 2025-12-22.
//

import SwiftUI
import UserNotifications

struct SoundsNotificationsView: View {
    @State private var notifStatus: UNAuthorizationStatus = .notDetermined

    @AppStorage("notifSoundsEnabled") private var soundsEnabled: Bool = true
    @AppStorage("notifBadgesEnabled") private var badgesEnabled: Bool = true

    var body: some View {
        Form {
            Section {
                Text("Turn on notifications so TickMe can remind you about tasks, schedules, and important activities.")
                    .foregroundStyle(.secondary)
            }

            Section("Notification Permission") {
                HStack {
                    Text("Status")
                    Spacer()
                    Text(statusText(notifStatus))
                        .foregroundStyle(.secondary)
                }

                if notifStatus == .denied {
                    Text("Notifications are disabled for TickMe. Open iPhone Settings to enable them.")
                        .foregroundStyle(.secondary)

                    Button("Open iPhone Settings") {
                        TickMeLinks.openSystemSettings()
                    }
                } else if notifStatus == .notDetermined {
                    Button("Enable Notifications") {
                        requestNotifications()
                    }
                } else {
                    Button("Manage in iPhone Settings") {
                        TickMeLinks.openSystemSettings()
                    }
                }
            }

            Section("Preferences") {
                Toggle("Sounds", isOn: $soundsEnabled)
                Toggle("Badge Count", isOn: $badgesEnabled)

                Text("TickMe only sends reminders you create. We do not send spam notifications.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Sounds & Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { refreshStatus() }
    }

    private func refreshStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async { notifStatus = settings.authorizationStatus }
        }
    }

    private func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
            refreshStatus()
        }
    }

    private func statusText(_ s: UNAuthorizationStatus) -> String {
        switch s {
        case .notDetermined: return "Not requested"
        case .denied: return "Denied"
        case .authorized: return "Allowed"
        case .provisional: return "Provisional"
        case .ephemeral: return "Ephemeral"
        @unknown default: return "Unknown"
        }
    }
}
