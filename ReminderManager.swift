//
//  ReminderManager.swift
//  Tickme2
//
//  Created by Matala on 2026-02-26.

import Foundation
import UserNotifications

final class ReminderManager {
    static let shared = ReminderManager()
    private init() {}

    func requestPermissionIfNeeded() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .notDetermined else { return }

        do {
            _ = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            // ignore
        }
    }

    func cancelReminder(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }

    // MARK: - Scheduling

    func schedule(config: ReminderConfig, taskId: UUID, title: String, eventDate: Date) async {
        await requestPermissionIfNeeded()

        // Always clear existing for this task first (prevents duplicates)
        cancelReminder(id: primaryId(for: taskId))
        cancelReminder(id: atTimeId(for: taskId))

        guard config.offset != .none else { return }

        // Primary reminder
        if config.offset == .atTime {
            scheduleOne(
                id: primaryId(for: taskId),
                title: title,
                fireDate: eventDate,
                repeatRule: config.repeatRule
            )
        } else {
            let primaryDate = eventDate.addingTimeInterval(-config.offset.secondsBefore)
            scheduleOne(
                id: primaryId(for: taskId),
                title: title,
                fireDate: primaryDate,
                repeatRule: config.repeatRule
            )

            // Optional: also remind at time (like iPhone Calendar can do multiple alerts)
            if config.alsoAtTime {
                scheduleOne(
                    id: atTimeId(for: taskId),
                    title: title,
                    fireDate: eventDate,
                    repeatRule: config.repeatRule
                )
            }
        }
    }

    private func scheduleOne(id: String, title: String, fireDate: Date, repeatRule: RepeatRule) {
        // Don’t schedule past notifications (for non-repeating)
        if repeatRule == .none, fireDate.timeIntervalSinceNow <= 1 {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "TickMe Reminder"
        content.body = title
        content.sound = .default

        let trigger: UNNotificationTrigger

        switch repeatRule {
        case .none:
            let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

        case .daily:
            let comps = Calendar.current.dateComponents([.hour, .minute], from: fireDate)
            trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)

        case .weekly:
            let comps = Calendar.current.dateComponents([.weekday, .hour, .minute], from: fireDate)
            trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)

        case .monthly:
            let comps = Calendar.current.dateComponents([.day, .hour, .minute], from: fireDate)
            trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        }

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func primaryId(for taskId: UUID) -> String { "tickme.task.\(taskId.uuidString).primary" }
    private func atTimeId(for taskId: UUID) -> String { "tickme.task.\(taskId.uuidString).attime" }
}
