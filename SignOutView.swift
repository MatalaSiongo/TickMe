 //done on 12/02 at 00:37

import SwiftUI

struct SignOutView: View {
    @EnvironmentObject private var auth: FirebaseAuthManager

    var body: some View {
        NavigationStack {
            ZStack {
                // ✅ Shared auth background
                AuthBackgroundView()

                VStack(spacing: 16) {
                    Spacer()

                    VStack(spacing: 12) {
                        Text("Sign Out")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)

                        Text("Are you sure you want to sign out?")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white.opacity(0.75))
                            .multilineTextAlignment(.center)

                        Button(role: .destructive) {
                            auth.signOut()
                        } label: {
                            Text("Sign Out")
                                .font(.system(size: 18, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(Color.white.opacity(0.20))
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .padding(.top, 10)
                    }
                    .padding(.vertical, 22)
                    .padding(.horizontal, 22)
                    .background(Color.black.opacity(0.18))
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .padding(.horizontal, 22)

                    Spacer()
                }
            }
        }
    }
}
