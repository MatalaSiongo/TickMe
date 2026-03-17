//
//  AccountView.swift
//  Tickme2
import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseStorage
import UIKit

struct AccountView: View {
    @EnvironmentObject private var auth: FirebaseAuthManager

    @State private var pickedItem: PhotosPickerItem? = nil
    @State private var showEditName = false
    @State private var draftName: String = ""

    @State private var remotePhotoURL: URL? = Auth.auth().currentUser?.photoURL
    @State private var isUploadingPhoto = false

    private var uid: String { Auth.auth().currentUser?.uid ?? "guest" }

    private func userKey(_ base: String) -> String { "\(base).\(uid)" }

    private var storedName: String {
        UserDefaults.standard.string(forKey: userKey("tm_display_name")) ?? ""
    }

    private var displayName: String {
        let local = storedName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !local.isEmpty { return local }

        if let n = auth.currentUserName, !n.isEmpty { return n }
        if let email = auth.currentUserEmail, let prefix = email.split(separator: "@").first { return String(prefix) }
        return "User"
    }

    private var emailText: String { auth.currentUserEmail ?? "" }

    private var profileImageData: Data? {
        UserDefaults.standard.data(forKey: userKey("tm_profile_image"))
    }

    // ✅ Adaptive card background (works in dark + light)
    private var cardFill: Color { Color(.secondarySystemGroupedBackground) }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(.systemGroupedBackground).ignoresSafeArea()

                AppTheme.headerGreen
                    .frame(height: 170)
                    .ignoresSafeArea(edges: .top)

                // ✅ No ScrollView — fixed screen
                VStack(spacing: 18) {

                    Text("Account")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.top, 40)

                    // Profile Card
                    VStack(spacing: 12) {

                        ZStack {
                            if let url = remotePhotoURL {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable().scaledToFill()
                                    case .failure:
                                        fallbackLocalOrDefaultImage
                                    default:
                                        ProgressView()
                                    }
                                }
                            } else {
                                fallbackLocalOrDefaultImage
                            }
                        }
                        .frame(width: 92, height: 92)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 10)

                        PhotosPicker(selection: $pickedItem, matching: .images) {
                            if isUploadingPhoto {
                                HStack(spacing: 8) {
                                    ProgressView()
                                    Text("Uploading...")
                                }
                                .font(.headline)
                                .foregroundStyle(.primary)
                            } else {
                                Text("Change Photo")
                                    .font(.headline)
                                    .foregroundStyle(.primary) // black in light, white in dark (on adaptive card)
                            }
                        }
                        .disabled(isUploadingPhoto)

                        Text(displayName)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.primary)

                        // ✅ FIX: email will show in dark mode (secondary on adaptive card)
                        Text(emailText)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)

                        Button {
                            draftName = displayName
                            showEditName = true
                        } label: {
                            Text("Edit Name")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(width: 180, height: 44)
                                .background(Color.black)
                                .clipShape(Capsule())
                        }
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 26)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(cardFill) // ✅ adaptive
                            .shadow(color: .black.opacity(0.10), radius: 18, x: 0, y: 12)
                    )
                    .padding(.horizontal, 18)
                    .padding(.top, 12)

                    // Menu Card
                    VStack(spacing: 0) {
                        NavigationLink { DeviceManagementView() } label: {
                            row(title: "Device Management", systemImage: "iphone")
                        }
                        Divider()

                        NavigationLink { PrivacyPermissionsView() } label: {
                            row(title: "Privacy & Security", systemImage: "lock.shield")
                        }
                        Divider()

                        NavigationLink { HelpFeedbackView() } label: {
                            row(title: "Help & Feedback", systemImage: "questionmark.circle")
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(cardFill) // ✅ adaptive
                            .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 12)
                    )
                    .padding(.horizontal, 18)

                    Spacer(minLength: 24)
                }
            }
        }
        .onAppear {
            remotePhotoURL = Auth.auth().currentUser?.photoURL
        }
        .onChange(of: pickedItem) { _, newItem in
            guard let newItem else { return }
            Task { await loadPickedImageAndUpload(newItem) }
        }
        .sheet(isPresented: $showEditName) {
            NavigationStack {
                Form {
                    Section("Name") {
                        TextField("Your name", text: $draftName)
                    }
                }
                .navigationTitle("Edit Name")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showEditName = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            let clean = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
                            UserDefaults.standard.set(clean, forKey: userKey("tm_display_name"))

                            Task {
                                await auth.updateDisplayName(clean)
                                showEditName = false
                            }
                        }
                        .disabled(draftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
        }
    }

    private var fallbackLocalOrDefaultImage: some View {
        Group {
            if let data = profileImageData, let ui = UIImage(data: data) {
                Image(uiImage: ui).resizable().scaledToFill()
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .foregroundStyle(.gray.opacity(0.4))
            }
        }
    }

    private func row(title: String, systemImage: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 20))
                .foregroundStyle(.primary) // ✅ not blue

            Text(title)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.primary) // ✅ not blue

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
    }

    // MARK: - Pick + Save Local + Upload to Firebase Storage + Update FirebaseAuth photoURL
    private func loadPickedImageAndUpload(_ item: PhotosPickerItem) async {
        guard uid != "guest" else { return }

        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let ui = UIImage(data: data) {

                if let jpgLocal = ui.jpegData(compressionQuality: 0.85) {
                    UserDefaults.standard.set(jpgLocal, forKey: userKey("tm_profile_image"))
                }

                isUploadingPhoto = true
                defer { isUploadingPhoto = false }

                if let jpg = ui.jpegData(compressionQuality: 0.80) {
                    if let url = try await uploadProfilePhotoToFirebaseStorage(jpg, uid: uid) {
                        remotePhotoURL = url
                    }
                }
            }
        } catch {
            // ignore
        }
    }

    private func uploadProfilePhotoToFirebaseStorage(_ imageData: Data, uid: String) async throws -> URL? {
        let storageRef = Storage.storage().reference()
            .child("users/\(uid)/profile.jpg")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()

        if let user = Auth.auth().currentUser {
            let change = user.createProfileChangeRequest()
            change.photoURL = downloadURL
            try await change.commitChanges()
            remotePhotoURL = Auth.auth().currentUser?.photoURL
        }

        return downloadURL
    }
}
