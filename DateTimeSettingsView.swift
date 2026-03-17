//
//  DateTimeSettingsView.swift
//  Tickme2
//
//  Created by Matala on 2025-12-22.
//

import SwiftUI

struct DateTimeSettingsView: View {
    @AppStorage("use24HourTime") private var use24HourTime: Bool = false
    @AppStorage("weekStartsOnMonday") private var weekStartsOnMonday: Bool = true
    @AppStorage("defaultReminderLeadMinutes") private var defaultReminderLeadMinutes: Int = 15

    private let leadOptions = [0, 5, 10, 15, 30, 60, 120]

    var body: some View {
        Form {
            Section {
                Text("TickMe uses your iPhone’s date & time settings by default. You can also set a few preferences for how dates are displayed inside the app.")
                    .foregroundStyle(.secondary)
            }

            Section("Device Info") {
                infoRow("Time Zone", TimeZone.current.identifier)
                infoRow("Locale", Locale.current.identifier)

                infoRow("Region",
                        Locale.current.region?.identifier ?? "Unknown")

                infoRow("Calendar", String(describing: Calendar.current.identifier))


            }

            Section("TickMe Preferences") {
                Toggle("Use 24-Hour Time", isOn: $use24HourTime)
                Toggle("Week Starts on Monday", isOn: $weekStartsOnMonday)

                Picker("Default Reminder Lead Time", selection: $defaultReminderLeadMinutes) {
                    ForEach(leadOptions, id: \.self) { mins in
                        Text(labelForMinutes(mins)).tag(mins)
                    }
                }
            }

            Section {
                Button("Open iPhone Date & Time Settings") {
                    openDateTimeSettings()
                }

                Text("If times look incorrect, check that “Set Automatically” is enabled in your iPhone settings.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Date & Time")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func infoRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }

    private func labelForMinutes(_ mins: Int) -> String {
        if mins == 0 { return "At time of event" }
        if mins < 60 { return "\(mins) min before" }
        let hours = mins / 60
        return "\(hours) hr before"
    }

    private func openDateTimeSettings() {
        // iOS doesn’t provide a direct deep link to Date & Time settings.
        // Best practice: open the app’s settings page.
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

