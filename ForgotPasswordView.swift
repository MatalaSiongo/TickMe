//
//  ForgotPasswordView.swift
//  Tickme2
//
//  Created by Matala on 2026-02-13.
//

import Foundation
import SwiftUI

struct ForgotPasswordView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var auth: FirebaseAuthManager

    @State private var email: String = ""
    @State private var isLoading = false
    @State private var successMessage: String?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 18) {

                HStack {
                    Button("Cancel") { dismiss() }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.12))
                        .foregroundStyle(.white)
                        .cornerRadius(18)
                    Spacer()
                }
                .padding(.top, 10)

                Spacer().frame(height: 10)

                Image(systemName: "key.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Color.cyan)

                Text("Reset Password")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundStyle(.white)

                Text("Enter your email address and we'll send you a link to reset your password")
                    .font(.headline)
                    .foregroundStyle(Color.white.opacity(0.6))
                    .multilineTextAlignment(.center)

                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 14)
                    .background(Color.white.opacity(0.10))
                    .cornerRadius(14)
                    .foregroundStyle(.white)
                    .padding(.top, 8)

                Button {
                    Task { await reset() }
                } label: {
                    Text(isLoading ? "Sending..." : "Send Reset Link")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.55))
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }
                .disabled(isLoading || email.isEmpty)

                if let successMessage {
                    Text(successMessage)
                        .foregroundStyle(Color.green.opacity(0.95))
                        .multilineTextAlignment(.center)
                        .padding(.top, 6)
                        .padding(.horizontal, 16)
                } else if let err = auth.errorMessage, !err.isEmpty {
                    Text(err)
                        .foregroundStyle(Color.red.opacity(0.95))
                        .multilineTextAlignment(.center)
                        .padding(.top, 6)
                        .padding(.horizontal, 16)
                }

                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }

    private func reset() async {
        isLoading = true
        defer { isLoading = false }

        auth.errorMessage = nil
        successMessage = nil

        await auth.sendPasswordReset(email: email.trimmingCharacters(in: .whitespacesAndNewlines))

        if auth.errorMessage == nil {
            successMessage = "Reset link sent. Check your email."
        }
    }
}
