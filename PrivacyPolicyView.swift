//
//  PrivacyPolicyView.swift
//  Tickme2
//
//  Created by Matala on 2025-12-22.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Privacy Policy")
                    .font(.title2).fontWeight(.bold)

                Text("""
                TickMe respects your privacy.

                • TickMe only requests permissions when needed for features you choose to use.
                • Your data stays on your device unless you choose to share it.
                • TickMe does not sell personal data.
                """)
                .foregroundStyle(.secondary)

                Divider().padding(.vertical, 8)

                Text("Contact")
                    .font(.headline)

                Link("Email: \(TickMeLinks.supportEmail)", destination: URL(string: "mailto:\(TickMeLinks.supportEmail)")!)
                    .foregroundStyle(AppTheme.headerGreen)


                Spacer(minLength: 20)
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}
