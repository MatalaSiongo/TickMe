//
//  FollowUsView.swift
//  Tickme2
//
//  Created by Matala on 2025-12-22.
//
import SwiftUI

struct FollowUsView: View {
    var body: some View {
        Form {
            Section {
                Text("Stay connected with TickMe for updates, tips, and new features.")
                    .foregroundStyle(.secondary)
            }

            Section("Contact") {
                Link("Email Us", destination: URL(string: "mailto:\(TickMeLinks.supportEmail)")!)
            }

            Section("Social (Coming Soon)") {
                HStack {
                    Text("Website")
                    Spacer()
                    Text("Coming soon").foregroundStyle(.secondary)
                }
                HStack {
                    Text("Instagram")
                    Spacer()
                    Text("Coming soon").foregroundStyle(.secondary)
                }
            }

            Section {
                Text("Links marked “Coming soon” will be enabled in a future update.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Follow Us")
        .navigationBarTitleDisplayMode(.inline)
    }
}
