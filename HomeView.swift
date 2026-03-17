//
//  HomeView.swift
//  Tickme2
import SwiftUI
import UIKit
import FirebaseAuth

struct HomeView: View {
    @EnvironmentObject var store: TaskStore
    @EnvironmentObject private var auth: FirebaseAuthManager   // ✅ IMPORTANT: for live name sync

    @State private var showAddTask = false
    @State private var showTodayTasks = false
    @State private var showCompletedToday = false
    @State private var showUpcoming = false

    // ✨ Welcome animation
    @State private var animateWelcome = false

    // 👤 Dynamic name (reads from FirebaseAuthManager so it updates instantly)
    private var displayName: String {
        if let name = auth.currentUserName,
           !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name
        }
        return "there"
    }

    // 📊 Progress ring values (Today)
    private var todayTotal: Int { store.tasks(on: Date()).count }
    private var todayCompleted: Int { store.completed(on: Date()).count }
    private var todayProgress: Double {
        guard todayTotal > 0 else { return 0 }
        return Double(todayCompleted) / Double(todayTotal)
    }

    var body: some View {
        VStack(spacing: 0) {

            // ✅ Header (KEEP: this is the layout that works on all devices)
            ZStack(alignment: .bottomLeading) {
                AppTheme.headerGreen
                    .ignoresSafeArea(edges: .top)

                VStack(alignment: .leading, spacing: 8) {

                    // ✨ Animated Welcome
                    Text("Welcome \(displayName) 👋")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(animateWelcome ? 1 : 0)
                        .offset(y: animateWelcome ? 0 : 10)
                        .animation(.spring(response: 0.55, dampingFraction: 0.85), value: animateWelcome)

                    Text("Today • Completed • Upcoming")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.85))

                    // 📊 Subtle progress ring under header
                    HStack(spacing: 12) {
                        ProgressRing(progress: todayProgress)
                            .frame(width: 34, height: 34)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Today Progress")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.85))
                            Text("\(todayCompleted) / \(todayTotal) done")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.85))
                        }

                        Spacer()
                    }
                    .padding(.top, 2)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
            .frame(height: 170)

            // ✅ Content
            VStack(spacing: 20) {

                HStack(spacing: 16) {
                    StatCard(
                        title: "Today",
                        count: todayTotal,
                        onTap: { showTodayTasks = true }
                    )

                    StatCard(
                        title: "Completed",
                        count: todayCompleted,
                        onTap: { showCompletedToday = true }
                    )

                    StatCard(
                        title: "Upcoming",
                        count: store.upcomingTasks(from: Date()).count,
                        onTap: { showUpcoming = true }
                    )
                }
                .padding(.horizontal)

                Spacer()

                Button {
                    showAddTask = true
                } label: {
                    Label("Add Task", systemImage: "plus")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                .padding(.horizontal)
            }
            .padding(.top, 16)
            .padding(.bottom, 16)
        }
        .onAppear {
            // ✨ Trigger animation once after layout settles
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                animateWelcome = true
            }
        }

        // Sheets (KEEP: unchanged so nothing breaks)
        .sheet(isPresented: $showAddTask) {
            AddTaskInlineSheet(defaultDate: Date())
                .environmentObject(store)
        }
        .sheet(isPresented: $showTodayTasks) {
            TaskListSheet(
                title: "Today's Tasks",
                items: store.tasks(on: Date()),
                onToggle: { item in store.toggleCompletion(id: item.id) }
            )
            .environmentObject(store)
        }
        .sheet(isPresented: $showCompletedToday) {
            TaskListSheet(
                title: "Completed Today",
                items: store.completed(on: Date()),
                onToggle: { item in store.toggleCompletion(id: item.id) }
            )
            .environmentObject(store)
        }
        .sheet(isPresented: $showUpcoming) {
            TaskListSheet(
                title: "Upcoming",
                items: store.upcomingTasks(from: Date()),
                onToggle: { item in store.toggleCompletion(id: item.id) }
            )
            .environmentObject(store)
        }
    }
}

// MARK: - Glassmorphic Stat Card + Haptics

private struct StatCard: View {
    let title: String
    let count: Int
    let onTap: () -> Void

    var body: some View {
        Button {
            // 🎯 Micro haptic
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onTap()
        } label: {
            VStack(spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("\(count)")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 14)

            // 🧊 Glassmorphic card (proper & readable in both modes)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Subtle Progress Ring

private struct ProgressRing: View {
    let progress: Double  // 0...1

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.22), lineWidth: 4)

            Circle()
                .trim(from: 0, to: max(0, min(1, progress)))
                .stroke(
                    Color.white.opacity(0.85),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            Text("\(Int(progress * 100))%")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
        }
        .accessibilityLabel("Today progress \(Int(progress * 100)) percent")
    }
}
