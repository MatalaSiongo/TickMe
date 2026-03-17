//
//  SignInView.swift
//  Tickme2
import SwiftUI

struct SignInView: View {
    @EnvironmentObject private var auth: FirebaseAuthManager

    @State private var email: String = ""
    @State private var password: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                // ✅ Shared auth background
                AuthBackgroundView()

                VStack(spacing: 18) {
                    Spacer(minLength: 40)

                    // Logo / Icon
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.95))
                            .frame(width: 92, height: 92)

                        Image(systemName: "checkmark")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundStyle(Color(red: 0.10, green: 0.35, blue: 0.30))
                    }
                    .padding(.bottom, 6)

                    Text("TickMe")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Plan less. Do more.")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.white.opacity(0.75))
                        .padding(.bottom, 18)

                    // Email
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .keyboardType(.emailAddress)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 18)
                        .background(Color.black.opacity(0.22))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .foregroundStyle(.white)
                        .tint(.white)
                        .padding(.horizontal, 22)

                    // Password
                    SecureField("Password", text: $password)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 18)
                        .background(Color.black.opacity(0.22))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .foregroundStyle(.white)
                        .tint(.white)
                        .padding(.horizontal, 22)

                    // Forgot password
                    HStack {
                        Spacer()
                        NavigationLink("Forgot Password?") {
                            ForgotPasswordView()
                                .environmentObject(auth)
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.blue)
                        .padding(.trailing, 26)
                    }

                    // Error
                    if let err = auth.errorMessage, !err.isEmpty {
                        Text(err)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 26)
                    }

                    // Sign In button
                    Button {
                        Task {
                            await auth.signIn(email: email, password: password)
                        }
                    } label: {
                        Text(auth.isLoading ? "Please wait..." : "Sign In")
                            .font(.system(size: 20, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                            .background(Color.white.opacity(0.28))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .disabled(auth.isLoading || email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || password.isEmpty)
                    .padding(.horizontal, 22)
                    .padding(.top, 4)

                    // Sign Up link
                    HStack(spacing: 6) {
                        Text("Don't have an account?")
                            .foregroundStyle(.white.opacity(0.70))

                        NavigationLink("Sign Up") {
                            SignUpView()
                                .environmentObject(auth)
                        }
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .padding(.top, 14)

                    Spacer()
                }
            }
        }
    }
}
