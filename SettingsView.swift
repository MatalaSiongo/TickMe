//
//  SettingsView.swift
//  Tickme2
//
//  Created by Matala on 2025-12-19.

//  SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var auth: FirebaseAuthManager

    @State private var showDeleteConfirm = false
    @State private var deleting = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // ✅ Fixed Header (does NOT move)
                ZStack(alignment: .bottomLeading) {
                    AppTheme.headerGreen
                        .frame(height: 150)
                        .ignoresSafeArea(edges: .top)

                    Text("Settings")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                }

                // ✅ Only this List scrolls
                List {

                    // MARK: - App
                    Section {
                        NavigationLink { TabBarSettingsView() } label: {
                            row("Tab Bar", "rectangle.bottomthird.inset.filled")
                        }
                        NavigationLink { AppearanceSettingsView() } label: {
                            row("Appearance", "paintbrush")
                        }
                        NavigationLink { SoundsNotificationsView() } label: {
                            row("Sounds & Notifications", "bell.badge")
                        }
                        NavigationLink { DateTimeSettingsView() } label: {
                            row("Date & Time", "clock")
                        }
                        NavigationLink { WidgetsSettingsView() } label: {
                            row("Widgets", "square.grid.2x2")
                        }
                    }

                    // MARK: - Data
                    Section {
                        NavigationLink { GeneralSettingsView() } label: {
                            row("General", "gearshape")
                        }
                        NavigationLink { ImportIntegrationView() } label: {
                            row("Import & Integration", "arrow.down.doc")
                        }
                    }

                    // MARK: - Privacy & Permissions
                    Section("Privacy & Permissions") {
                        NavigationLink { PrivacyPermissionsView() } label: {
                            row("Privacy & Permissions", "hand.raised")
                        }
                        NavigationLink { PrivacyPolicyView() } label: {
                            row("Privacy Policy", "doc.text")
                        }
                    }

                    // MARK: - Support
                    Section {
                        NavigationLink { HelpFeedbackView() } label: {
                            row("Help & Feedback", "questionmark.circle")
                        }
                        NavigationLink { FollowUsView() } label: {
                            row("Follow Us", "person.2")
                        }
                        NavigationLink { AboutView() } label: {
                            row("About", "info.circle")
                        }
                    }

                    // MARK: - Sign out / Delete
                    Section {
                        NavigationLink {
                            SignOutView()
                        } label: {
                            Text("Sign Out")
                                .foregroundStyle(.red)
                        }

                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            Text("Delete Account")
                        }
                        .disabled(deleting || auth.isLoading)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))
            }
            .ignoresSafeArea(edges: .top)
            .alert("Delete your account?", isPresented: $showDeleteConfirm) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        deleting = true
                        await auth.deleteAccount()
                        deleting = false
                    }
                }
            } message: {
                Text("""
                This will permanently delete your TickMe account and sign you out.
                This action cannot be undone.

                Note: If you see an error about “recent login”, please sign in again and retry.
                """)
            }
        }
    }

    private func row(_ title: String, _ systemImage: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .frame(width: 24)
                .foregroundStyle(.secondary)

            Text(title)
            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        .contentShape(Rectangle())
    }
}
