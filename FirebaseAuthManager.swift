//
//  FirebaseAuthManager.swift
//
//  FirebaseAuthManager.swift
//
import Foundation
import Combine
import FirebaseAuth

@MainActor
final class FirebaseAuthManager: ObservableObject {

    // MARK: - Published state used by UI
    @Published var user: User? = Auth.auth().currentUser
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false

    // MARK: - Auth change notifier (so views can react)
    let authStateToken = PassthroughSubject<Void, Never>()

    // MARK: - Listener
    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            Task { @MainActor in
                self.user = user
                self.errorMessage = nil
                self.authStateToken.send(())

                NotificationCenter.default.post(
                    name: .tmAuthUserDidChange,
                    object: nil,
                    userInfo: ["uid": user?.uid as Any]
                )
            }
        }
    }

    deinit {
        if let handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - Convenience
    var currentUserEmail: String? { user?.email }

    var currentUserName: String? {
        if let dn = user?.displayName,
           !dn.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return dn
        }
        if let email = user?.email, !email.isEmpty {
            return email.components(separatedBy: "@").first
        }
        return nil
    }

    // MARK: - Auth actions
    func signIn(email: String, password: String) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            let result = try await Auth.auth().signIn(withEmail: cleanEmail, password: password)
            self.user = result.user
            self.authStateToken.send(())

            NotificationCenter.default.post(
                name: .tmAuthUserDidChange,
                object: nil,
                userInfo: ["uid": result.user.uid]
            )
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func signUp(name: String, email: String, password: String) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            let result = try await Auth.auth().createUser(withEmail: cleanEmail, password: password)
            self.user = result.user

            if !cleanName.isEmpty {
                let change = result.user.createProfileChangeRequest()
                change.displayName = cleanName
                try await change.commitChanges()
                self.user = Auth.auth().currentUser
            }

            self.authStateToken.send(())

            NotificationCenter.default.post(
                name: .tmAuthUserDidChange,
                object: nil,
                userInfo: ["uid": result.user.uid]
            )
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func sendPasswordReset(email: String) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            try await Auth.auth().sendPasswordReset(withEmail: cleanEmail)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            try Auth.auth().signOut()
            self.user = nil
            self.authStateToken.send(())

            NotificationCenter.default.post(
                name: .tmAuthUserDidChange,
                object: nil,
                userInfo: ["uid": NSNull()]
            )
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Update display name (THIS is the missing sync piece)
    func updateDisplayName(_ newName: String) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        let clean = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }

        guard let current = Auth.auth().currentUser else {
            self.errorMessage = "No signed-in user."
            return
        }

        do {
            let change = current.createProfileChangeRequest()
            change.displayName = clean
            try await change.commitChanges()

            // ✅ refresh published user so Home updates immediately
            self.user = Auth.auth().currentUser
            self.authStateToken.send(())

            NotificationCenter.default.post(
                name: .tmAuthUserDidChange,
                object: nil,
                userInfo: ["uid": current.uid]
            )
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Delete account (Firebase Auth)
    func deleteAccount() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        guard let currentUser = Auth.auth().currentUser else {
            self.errorMessage = "No signed-in user."
            return
        }

        do {
            try await currentUser.delete()

            self.user = nil
            self.authStateToken.send(())

            NotificationCenter.default.post(
                name: .tmAuthUserDidChange,
                object: nil,
                userInfo: ["uid": NSNull()]
            )
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Notification name used across the app
extension Notification.Name {
    static let tmAuthUserDidChange = Notification.Name("tmAuthUserDidChange")
}
