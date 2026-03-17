//
//  TaskStore.swift
import Foundation
import SwiftUI
import Combine

final class TaskStore: ObservableObject {

    @Published var allTasks: [TickItem] = []
    @Published var selectedDate: Date = Date()

    private var currentUID: String? = nil

    // ✅ per-task reminder settings (saved to UserDefaults too)
    @Published private(set) var reminderConfigs: [UUID: ReminderConfig] = [:]

    init() {
        loadTasks()
        loadReminderConfigs()

        // After loading, ensure reminders are scheduled for future items
        Task { await rescheduleAllFutureReminders() }
    }

    // MARK: - User switching (optional but safe)
    func setCurrentUser(uid: String?) {
        currentUID = uid
        loadTasks()
        loadReminderConfigs()
        Task { await rescheduleAllFutureReminders() }
    }

    func clearForSignOut() {
        currentUID = nil
        allTasks = []
        reminderConfigs = [:]
        selectedDate = Date()
        // We do NOT auto-cancel all iOS notifications here (safe).
    }

    // MARK: - CRUD
    func addTask(item: TickItem) {
        allTasks.append(item)
        saveTasks()

        // If this new task already has a config set later, scheduling happens in setReminder(...)
        // If you want default behavior, leave it as none until user chooses.
        Task { await scheduleReminderIfNeeded(for: item) }
    }

    func toggleCompletion(id: UUID) {
        guard let idx = allTasks.firstIndex(where: { $0.id == id }) else { return }
        allTasks[idx].isCompleted.toggle()
        let item = allTasks[idx]
        saveTasks()

        if item.isCompleted {
            cancelReminders(for: item.id)
        } else {
            Task { await scheduleReminderIfNeeded(for: item) }
        }
    }

    func deleteTask(id: UUID) {
        cancelReminders(for: id)

        reminderConfigs[id] = nil
        saveReminderConfigs()

        allTasks.removeAll { $0.id == id }
        saveTasks()
    }

    // MARK: - Reminder API (called from AddScheduleSheet UI)
    func setReminder(for taskId: UUID, config: ReminderConfig) {
        reminderConfigs[taskId] = config
        saveReminderConfigs()

        if let item = allTasks.first(where: { $0.id == taskId }) {
            if item.isCompleted {
                cancelReminders(for: taskId)
            } else {
                Task { await scheduleReminderIfNeeded(for: item) }
            }
        }
    }

    func reminderConfig(for taskId: UUID) -> ReminderConfig {
        reminderConfigs[taskId] ?? .none
    }

    // MARK: - Queries (used by HomeView / CalendarView)
    func tasks(on date: Date) -> [TickItem] {
        allTasks
            .filter { Calendar.current.isDate($0.date ?? Date.distantPast, inSameDayAs: date) }
            .sorted { ($0.date ?? Date.distantPast) < ($1.date ?? Date.distantPast) }
    }

    func completed(on date: Date) -> [TickItem] {
        tasks(on: date).filter { $0.isCompleted }
    }

    func upcomingTasks(from date: Date) -> [TickItem] {
        let start = Calendar.current.startOfDay(for: date)
        return allTasks
            .filter { ($0.date ?? Date.distantPast) >= start && !$0.isCompleted }
            .sorted { ($0.date ?? Date.distantPast) < ($1.date ?? Date.distantPast) }
    }

    func hasTasks(on date: Date) -> Bool {
        !tasks(on: date).isEmpty
    }

    // MARK: - Persistence
    private var storageKey: String {
        if let uid = currentUID, !uid.isEmpty {
            return "tasks_\(uid)"
        } else {
            return "tasks_guest"
        }
    }

    private var reminderKey: String {
        "\(storageKey)_reminders"
    }

    private func saveTasks() {
        do {
            let data = try JSONEncoder().encode(allTasks)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            // silent
        }
    }

    private func loadTasks() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            allTasks = []
            return
        }
        do {
            allTasks = try JSONDecoder().decode([TickItem].self, from: data)
        } catch {
            allTasks = []
        }
    }

    private func saveReminderConfigs() {
        do {
            let data = try JSONEncoder().encode(reminderConfigs)
            UserDefaults.standard.set(data, forKey: reminderKey)
        } catch {
            // silent
        }
    }

    private func loadReminderConfigs() {
        guard let data = UserDefaults.standard.data(forKey: reminderKey) else {
            reminderConfigs = [:]
            return
        }
        do {
            reminderConfigs = try JSONDecoder().decode([UUID: ReminderConfig].self, from: data)
        } catch {
            reminderConfigs = [:]
        }
    }

    // MARK: - Scheduling helpers

    private func isScheduleItem(_ item: TickItem) -> Bool {
        // Your app uses .schedule
        return item.type == .schedule || item.category == .schedule
    }

    private func cancelReminders(for taskId: UUID) {
        ReminderManager.shared.cancelReminder(id: "tickme.task.\(taskId.uuidString).primary")
        ReminderManager.shared.cancelReminder(id: "tickme.task.\(taskId.uuidString).attime")
    }

    private func scheduleReminderIfNeeded(for item: TickItem) async {
        guard isScheduleItem(item) else { return }
        guard item.isCompleted == false else { return }
        guard let date = item.date else { return }

        let config = reminderConfigs[item.id] ?? .none
        if config.offset == .none {
            // no reminder configured
            cancelReminders(for: item.id)
            return
        }

        await ReminderManager.shared.schedule(
            config: config,
            taskId: item.id,
            title: item.title,
            eventDate: date
        )
    }

    private func rescheduleAllFutureReminders() async {
        for item in allTasks {
            if item.isCompleted {
                cancelReminders(for: item.id)
            } else {
                await scheduleReminderIfNeeded(for: item)
            }
        }
    }
}
