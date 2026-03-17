//
//  AccountScreens.swift
//  Tickme2
//
//  Created by Matala on 2026-02-13.
//

import Foundation
import SwiftUI
import FirebaseAuth
import UIKit

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var displayName = Auth.auth().currentUser?.displayName ?? ""
    @State private var message: String?

    var body: some View {
        Form {
            Section("Profile") {
                TextField("Display name", text: $displayName)
            }

            if let message {
                Text(message)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Edit Profile")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let name = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !name.isEmpty else { return }
                    let req = Auth.auth().currentUser?.createProfileChangeRequest()
                    req?.displayName = name
                    req?.commitChanges { err in
                        if let err { message = err.localizedDescription }
                        else { message = "Saved"; DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { dismiss() } }
                    }
                }
            }
        }
    }
}

struct ChangePasswordView: View {
    @State private var email = Auth.auth().currentUser?.email ?? ""
    @State private var message: String?
    @State private var isSending = false

    var body: some View {
        Form {
            Section("Reset Password") {
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)

                Button(isSending ? "Sending..." : "Send Reset Link") {
                    let clean = email.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !clean.isEmpty else { return }
                    isSending = true
                    Auth.auth().sendPasswordReset(withEmail: clean) { err in
                        isSending = false
                        if let err { message = err.localizedDescription }
                        else { message = "Password reset link sent to \(clean)." }
                    }
                }
                .disabled(isSending)
            }

            if let message {
                Section {
                    Text(message).foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Change Password")
    }
}

struct NotificationsView: View {
    @AppStorage("TickMe.notifications.enabled") private var enabled = true
    @AppStorage("TickMe.notifications.sound") private var sound = true

    var body: some View {
        Form {
            Section("Notifications") {
                Toggle("Enable notifications", isOn: $enabled)
                Toggle("Sound", isOn: $sound)
                    .disabled(!enabled)
            }

            Section {
                Button("Open iOS Settings") {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }
            }
        }
        .navigationTitle("Notifications")
    }
}

struct PrivacySecurityView: View {
    var body: some View {
        Form {
            Section("Privacy") {
                Text("TickMe uses your account details to sign you in and sync your data securely. You can manage permissions anytime in iOS Settings.")
                    .foregroundStyle(.secondary)
            }

            Section("Security") {
                Text("We recommend using a strong password and enabling device security (Face ID / Passcode).")
                    .foregroundStyle(.secondary)
            }

            Section {
                Button("Open iOS Settings") {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }
            }
        }
        .navigationTitle("Privacy & Security")
    }
}
