//
//  ImportIntegrationView.swift
//  Tickme2
//
//  Created by Matala on 2025-12-22.
//

import SwiftUI

struct ImportIntegrationView: View {
    var body: some View {
        Form {
            Section {
                Text("TickMe supports simple integrations to help you organise your schedule and reminders.")
                    .foregroundStyle(.secondary)
            }

            Section("Current Features") {
                Label("Calendar access to help you view and plan events", systemImage: "calendar")
                Label("Local storage for tasks and notes on your device", systemImage: "internaldrive")
                Label("Reminders & notifications to keep you on track", systemImage: "bell.badge")
            }

            Section("Coming Soon") {
                Label("Export tasks and notes (PDF / CSV)", systemImage: "square.and.arrow.up")
                Label("Cloud sync across devices", systemImage: "icloud")
                Label("Additional integrations", systemImage: "link")
            }

            Section {
                Text("TickMe only requests permissions when needed for features you choose to use.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Import & Integration")
        .navigationBarTitleDisplayMode(.inline)
    }
}
