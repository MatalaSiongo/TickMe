//
//  PasskeyView.swift
//  Tickme2
//
//  Created by Matala on 2025-12-19.
//

import SwiftUI

struct PasskeyView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "key.fill").font(.system(size: 40)).foregroundStyle(.orange)
            Text("Passkeys").font(.title2).fontWeight(.semibold)
            Text("You can add passkey setup here later.")
                .foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal)
            Spacer()
        }
        .padding(.top, 30)
        .navigationTitle("Create Passkey")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TwoStepView: View {
    @State private var enabled = false
    var body: some View {
        Form {
            Toggle("Enable 2-Step Verification", isOn: $enabled)
            Text("We’ll add SMS / Auth App options later.")
                .foregroundStyle(.secondary)
        }
        .navigationTitle("2-Step Verification")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ThirdPartyView: View {
    @Binding var isGoogleLinked: Bool
    @Binding var isAppleLinked: Bool
    var displayName: String

    var body: some View {
        List {
            Section {
                HStack {
                    Label("Google", systemImage: "g.circle.fill")
                    Spacer()
                    Button(isGoogleLinked ? "Unlink" : "Link") { isGoogleLinked.toggle() }
                }

                HStack {
                    Label("Apple", systemImage: "apple.logo")
                    Spacer()
                    Button(isAppleLinked ? "Unlink" : "Link") { isAppleLinked.toggle() }
                }
            }
        }
        .navigationTitle("Linked Accounts")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct UpgradeView: View {
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "crown.fill").font(.system(size: 42)).foregroundStyle(.orange)
            Text("Premium").font(.title2).fontWeight(.semibold)
            Text("Add subscription options here later.")
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.top, 30)
        .navigationTitle("Upgrade")
        .navigationBarTitleDisplayMode(.inline)
    }
}
