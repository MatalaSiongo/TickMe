//
//  SignUpView.swift
//  Tickme2
import SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var auth: FirebaseAuthManager
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""

    @State private var isLoading: Bool = false

    var body: some View {
        ZStack {
            // ✅ Uses the shared auth background (same as SignIn/SignOut)
            AuthBackgroundView()

            VStack(spacing: 16) {
                Spacer(minLength: 40)

                // Title
                Text("Create Account")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                Text("Start ticking off goals in minutes.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.75))
                    .padding(.bottom, 10)

                // Fields
                Group {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled(true)

                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled(true)

                    SecureField("Password", text: $password)
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .background(.white.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.white.opacity(0.15), lineWidth: 1)
                )
                .foregroundStyle(.white)

                // Error
                if let err = auth.errorMessage, !err.isEmpty {
                    Text(err)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }

                // Create account
                Button {
                    Task { await signUp() }
                } label: {
                    Text(isLoading ? "Creating..." : "Create Account")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, minHeight: 54)
                }
                .background(Color.black.opacity(0.85))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .padding(.top, 6)
                .disabled(isLoading)

                // Back to sign in
                Button("Already have an account? Sign In") {
                    dismiss()
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.blue)
                .padding(.top, 6)
                .disabled(isLoading)

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func signUp() async {
        isLoading = true
        defer { isLoading = false }

        await auth.signUp(
            name: name,
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password
        )

        // If user created successfully, AuthGateView typically switches automatically.
        // Still dismiss SignUp screen so UI returns cleanly.
        if auth.user != nil {
            dismiss()
        }
    }
}
