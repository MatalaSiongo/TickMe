//
//  AboutView.swift
//  Tickme2
//
//  Created by Matala on 2025-12-22.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(AppTheme.headerGreen)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(AppInfo.appName)
                            .font(.title2).fontWeight(.bold)
                        Text("Version \(AppInfo.version) (\(AppInfo.build))")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                }
                .padding(.bottom, 8)

                Text("""
                TickMe helps you stay organised by bringing your tasks, notes, schedules, and reminders into one simple place.

                Plan your day with confidence, track what matters, and keep your routine consistent — without missing important activities.
                """)
                .foregroundStyle(.secondary)

                Divider().padding(.vertical, 6)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Support")
                        .font(.headline)

                    Link("Email: \(TickMeLinks.supportEmail)", destination: URL(string: "mailto:\(TickMeLinks.supportEmail)")!)
                        .foregroundStyle(AppTheme.headerGreen)

                }

                Divider().padding(.vertical, 6)

                Text("© 2025 TickMe. All rights reserved.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 20)
            }
            .padding()
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

