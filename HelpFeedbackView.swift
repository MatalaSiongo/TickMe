//
//  HelpFeedbackView.swift
//  Tickme2
//
//  Created by Matala on 2025-12-22.
//
import SwiftUI

struct HelpFeedbackView: View {
    private func openMail(subject: String, body: String) {
        if let url = TickMeLinks.mailtoURL(subject: subject, body: body) {
            UIApplication.shared.open(url)
        }
    }

    var body: some View {
        Form {
            Section {
                Text("Need help, want to report a bug, or have an idea to improve TickMe? We’d love to hear from you.")
                    .foregroundStyle(.secondary)
            }

            Section("Quick Actions") {
                Button("Contact Support") {
                    openMail(
                        subject: "TickMe Support Request",
                        body: """
                        Hello TickMe Team,

                        I need help with:
                        (Write your message here)

                        Device: \(UIDevice.current.model)
                        iOS: \(UIDevice.current.systemVersion)
                        App Version: \(AppInfo.version) (\(AppInfo.build))
                        """
                    )
                }

                Button("Report a Bug") {
                    openMail(
                        subject: "TickMe Bug Report",
                        body: """
                        Hello TickMe Team,

                        Bug description:
                        (What happened?)

                        Steps to reproduce:
                        1)
                        2)
                        3)

                        Expected result:
                        Actual result:

                        Device: \(UIDevice.current.model)
                        iOS: \(UIDevice.current.systemVersion)
                        App Version: \(AppInfo.version) (\(AppInfo.build))
                        """
                    )
                }

                Button("Suggest a Feature") {
                    openMail(
                        subject: "TickMe Feature Suggestion",
                        body: """
                        Hello TickMe Team,

                        Feature idea:
                        (Describe your idea)

                        Why it would help:
                        (Explain briefly)

                        App Version: \(AppInfo.version) (\(AppInfo.build))
                        """
                    )
                }
            }

            Section {
                Text("We typically respond within 24–48 hours.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Help & Feedback")
        .navigationBarTitleDisplayMode(.inline)
    }
}

