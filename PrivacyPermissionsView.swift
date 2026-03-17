//  PrivacyPermissionsView.swift
//  Tickme2
//  Created by Matala on 2025-12-22.
import SwiftUI
import UserNotifications
import EventKit
import UIKit

struct PrivacyPermissionsView: View {
    @State private var notifStatus: UNAuthorizationStatus = .notDetermined
    @State private var calendarStatus: EKAuthorizationStatus = .notDetermined

    private let eventStore = EKEventStore()

    var body: some View {
        Form {
            Section {
                Text("TickMe respects your privacy. Permissions are only used for features you choose to use.")
                    .foregroundStyle(.secondary)
            }

            Section("Permissions") {
                permissionRow(
                    title: "Notifications",
                    subtitle: "TickMe can send reminders for tasks, schedules, and important activities.",
                    status: notificationStatusText(notifStatus),
                    actionTitle: notificationButtonTitle
                ) {
                    handleNotificationAction()
                }

                permissionRow(
                    title: "Calendar",
                    subtitle: "TickMe can use calendar access to show and manage your events and reminders.",
                    status: calendarStatusText(calendarStatus),
                    actionTitle: calendarButtonTitle
                ) {
                    handleCalendarAction()
                }

                permissionRow(
                    title: "Photos",
                    subtitle: "TickMe can use photo access if you want to choose a profile picture.",
                    status: "Managed in iPhone Settings",
                    actionTitle: "Open Settings"
                ) {
                    openSystemSettings()
                }
            }

            Section("Privacy") {
                NavigationLink("Privacy Policy") {
                    PrivacyPolicyView()
                }

                NavigationLink("Data & App Privacy") {
                    AppPrivacyInfoView()
                }
            }
        }
        .navigationTitle("Privacy & Permissions")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            refreshStatuses()
        }
    }

    @ViewBuilder
    private func permissionRow(
        title: String,
        subtitle: String,
        status: String,
        actionTitle: String,
        action: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)

                    Text(status)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(actionTitle) {
                    action()
                }
            }

            Text(subtitle)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private var notificationButtonTitle: String {
        switch notifStatus {
        case .notDetermined:
            return "Continue"
        case .denied, .authorized, .provisional, .ephemeral:
            return "Open Settings"
        @unknown default:
            return "Open Settings"
        }
    }

    private func handleNotificationAction() {
        switch notifStatus {
        case .notDetermined:
            requestNotifications()
        case .denied, .authorized, .provisional, .ephemeral:
            openSystemSettings()
        @unknown default:
            openSystemSettings()
        }
    }

    private var calendarButtonTitle: String {
        isCalendarAllowed ? "Open Settings" : "Continue"
    }

    private func handleCalendarAction() {
        if isCalendarAllowed {
            openSystemSettings()
        } else {
            requestCalendar()
        }
    }

    private var isCalendarAllowed: Bool {
        if #available(iOS 17.0, *) {
            return calendarStatus == .fullAccess || calendarStatus == .writeOnly
        } else {
            return calendarStatus == .authorized
        }
    }

    private func refreshStatuses() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notifStatus = settings.authorizationStatus
            }
        }

        calendarStatus = EKEventStore.authorizationStatus(for: .event)
    }

    private func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
            DispatchQueue.main.async {
                refreshStatuses()
            }
        }
    }

    private func requestCalendar() {
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents { _, _ in
                DispatchQueue.main.async {
                    refreshStatuses()
                }
            }
        } else {
            eventStore.requestAccess(to: .event) { _, _ in
                DispatchQueue.main.async {
                    refreshStatuses()
                }
            }
        }
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    private func notificationStatusText(_ s: UNAuthorizationStatus) -> String {
        switch s {
        case .notDetermined:
            return "Not requested"
        case .denied:
            return "Turned off in Settings"
        case .authorized:
            return "Allowed"
        case .provisional:
            return "Provisional"
        case .ephemeral:
            return "Temporary"
        @unknown default:
            return "Unknown"
        }
    }

    private func calendarStatusText(_ s: EKAuthorizationStatus) -> String {
        switch s {
        case .notDetermined:
            return "Not requested"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Turned off in Settings"
        case .authorized:
            return "Allowed"
        case .fullAccess:
            return "Full access"
        case .writeOnly:
            return "Write only"
        @unknown default:
            return "Unknown"
        }
    }
}

struct AppPrivacyInfoView: View {
    var body: some View {
        Form {
            Section {
                Text("TickMe stores your tasks and notes on your device. Permissions are used only to enable features like reminders and calendar scheduling.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Data & App Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}
