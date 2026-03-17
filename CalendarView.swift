//CalendarView 
import SwiftUI

struct CalendarView: View {
    @ObservedObject var store: TaskStore

    @State private var showAdd = false
    @State private var monthOffset: Int = 0

    // Reminder edit sheet
    @State private var editingReminderItem: TickItem? = nil

    // Delete confirmation
    @State private var deleteCandidate: TickItem? = nil
    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {

                    MonthCalendarCard(
                        monthDate: displayedMonthDate,
                        selectedDate: $store.selectedDate,
                        onPrev: { monthOffset -= 1 },
                        onNext: { monthOffset += 1 },
                        hasEvent: { date in store.hasTasks(on: date) }
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    Text(store.selectedDate.formatted(date: .long, time: .omitted))
                        .font(.title3.bold())
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)

                    DayTasksCard(
                        items: store.tasks(on: store.selectedDate),
                        onToggle: { item in store.toggleCompletion(id: item.id) },
                        onEditReminder: { item in
                            editingReminderItem = item
                        },
                        onDeleteRequest: { item in
                            deleteCandidate = item
                            showDeleteConfirm = true
                        }
                    )
                    .padding(.horizontal, 16)

                    Spacer(minLength: 30)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)

            .toolbarBackground(AppTheme.headerGreen, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)

            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .accessibilityLabel("Add schedule")
                }
            }

            .sheet(isPresented: $showAdd) {
                AddScheduleSheet(store: store, date: store.selectedDate)
            }
            .sheet(item: $editingReminderItem) { item in
                ReminderEditSheet(item: item)
            }

            .alert("Delete Schedule?", isPresented: $showDeleteConfirm) {
                Button("Delete", role: .destructive) {
                    guard let item = deleteCandidate else { return }

                    ReminderManager.shared.cancelReminder(id: "tickme.task.\(item.id.uuidString).primary")
                    ReminderManager.shared.cancelReminder(id: "tickme.task.\(item.id.uuidString).attime")
                    ReminderLocalStore.remove(for: item.id)

                    store.deleteTask(id: item.id)

                    deleteCandidate = nil
                }
                Button("Cancel", role: .cancel) {
                    deleteCandidate = nil
                }
            } message: {
                Text("This will remove the schedule and its reminders.")
            }
        }
    }

    private var displayedMonthDate: Date {
        let cal = Calendar.current
        return cal.date(byAdding: .month, value: monthOffset, to: Date()) ?? Date()
    }
}

// MARK: - Month Calendar Card

private struct MonthCalendarCard: View {
    let monthDate: Date
    @Binding var selectedDate: Date
    let onPrev: () -> Void
    let onNext: () -> Void
    let hasEvent: (Date) -> Bool

    private let cal = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 7)

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: onPrev) {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                }

                Spacer()

                Text(monthTitle)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                Button(action: onNext) {
                    Image(systemName: "chevron.right")
                        .font(.headline)
                }
            }
            .foregroundStyle(.primary)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }

                ForEach(daysForGrid, id: \.self) { day in
                    if let day {
                        DayCell(
                            date: day,
                            isSelected: cal.isDate(day, inSameDayAs: selectedDate),
                            hasEvent: hasEvent(day)
                        )
                        .onTapGesture { selectedDate = day }
                    } else {
                        Color.clear.frame(height: 34)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: Color.black.opacity(0.12), radius: 18, x: 0, y: 10)
    }

    private var monthTitle: String {
        monthDate.formatted(.dateTime.year().month(.wide))
    }

    private var weekdaySymbols: [String] {
        cal.shortWeekdaySymbols
    }

    private var daysForGrid: [Date?] {
        let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: monthDate)) ?? monthDate
        let range = cal.range(of: .day, in: .month, for: startOfMonth) ?? 1..<2

        let firstWeekday = cal.component(.weekday, from: startOfMonth)
        let leadingBlanks = firstWeekday - 1

        var result: [Date?] = Array(repeating: nil, count: leadingBlanks)

        for day in range {
            if let date = cal.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                result.append(date)
            }
        }

        while result.count % 7 != 0 { result.append(nil) }
        return result
    }
}

private struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let hasEvent: Bool

    private let cal = Calendar.current

    var body: some View {
        ZStack {
            if isSelected {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.primary.opacity(0.10))
            }

            VStack(spacing: 4) {
                Text("\(cal.component(.day, from: date))")
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                Circle()
                    .fill(hasEvent ? Color.primary : Color.clear)
                    .frame(width: 5, height: 5)
            }
            .frame(maxWidth: .infinity, minHeight: 34)
        }
        .frame(height: 34)
    }
}

// MARK: - Day Tasks Card

private struct DayTasksCard: View {
    let items: [TickItem]
    let onToggle: (TickItem) -> Void
    let onEditReminder: (TickItem) -> Void
    let onDeleteRequest: (TickItem) -> Void

    var body: some View {
        VStack(spacing: 0) {
            if items.isEmpty {
                VStack(spacing: 10) {
                    Text("You have a free day")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("Take it easy")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(28)
            } else {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    HStack(spacing: 12) {

                        Button {
                            onToggle(item)
                        } label: {
                            Image(systemName: item.isCompleted ? "checkmark.square.fill" : "square")
                                .font(.title3)
                                .foregroundStyle(.primary)
                        }
                        .buttonStyle(.plain)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title)
                                .font(.headline)
                                .foregroundStyle(.primary)

                            if let date = item.date {
                                Text(date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer()

                        Menu {
                            Button {
                                onEditReminder(item)
                            } label: {
                                Label("Reminder", systemImage: "bell")
                            }

                            Button(role: .destructive) {
                                onDeleteRequest(item)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundStyle(Color.primary)
                                .opacity(0.95)
                        }
                        .accessibilityLabel("Options")
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 18)

                    if index < items.count - 1 {
                        Divider().padding(.leading, 18)
                    }
                }
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: Color.black.opacity(0.12), radius: 18, x: 0, y: 10)
    }
}

// MARK: - Add Schedule Sheet

private struct AddScheduleSheet: View {
    @ObservedObject var store: TaskStore
    let date: Date

    @State private var title: String = ""
    @State private var time: Date = Date()

    @Environment(\.dismiss) private var dismiss

    init(store: TaskStore, date: Date) {
        self.store = store
        self.date = date

        let cal = Calendar.current
        let defaultTime = cal.date(bySettingHour: 9, minute: 0, second: 0, of: date) ?? date
        _time = State(initialValue: defaultTime)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Schedule") {
                    TextField("Title", text: $title)
                        .textInputAutocapitalization(.sentences)

                    DatePicker("Time", selection: $time, displayedComponents: [.hourAndMinute])
                }
            }
            .navigationTitle("Add Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !cleanTitle.isEmpty else { return }

                        let cal = Calendar.current
                        let hour = cal.component(.hour, from: time)
                        let minute = cal.component(.minute, from: time)
                        let combined = cal.date(bySettingHour: hour, minute: minute, second: 0, of: date) ?? date

                        let item = TickItem(
                            category: .schedule,
                            type: .schedule,
                            title: cleanTitle,
                            details: "",
                            date: combined,
                            isCompleted: false
                        )

                        store.addTask(item: item)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

// MARK: - Reminder Edit Sheet

private struct ReminderEditSheet: View {
    let item: TickItem

    @Environment(\.dismiss) private var dismiss

    @State private var offset: ReminderOffset = .none
    @State private var alsoAtTime: Bool = false
    @State private var repeatRule: RepeatRule = .none

    var body: some View {
        NavigationStack {
            Form {
                Section("Reminder") {
                    Picker("Remind", selection: $offset) {
                        ForEach(ReminderOffset.allCases, id: \.self) { opt in
                            Text(opt.title).tag(opt)
                        }
                    }

                    if offset != .none && offset != .atTime {
                        Toggle("Also remind me at time", isOn: $alsoAtTime)
                    } else {
                        if alsoAtTime {
                            Text("“Also at time” is only available when you choose “before”.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Repeat") {
                    Picker("Repeat", selection: $repeatRule) {
                        ForEach(RepeatRule.allCases, id: \.self) { rule in
                            Text(rule.title).tag(rule)
                        }
                    }
                }

                Section {
                    Text(helperText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                let cfg = ReminderLocalStore.load(for: item.id)
                offset = cfg.offset
                alsoAtTime = cfg.alsoAtTime
                repeatRule = cfg.repeatRule
            }
            .onChange(of: offset) { _, newValue in
                if newValue == .none || newValue == .atTime {
                    alsoAtTime = false
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            let cfg = ReminderConfig(offset: offset, alsoAtTime: alsoAtTime, repeatRule: repeatRule)
                            ReminderLocalStore.save(cfg, for: item.id)

                            if cfg.offset == .none {
                                ReminderManager.shared.cancelReminder(id: "tickme.task.\(item.id.uuidString).primary")
                                ReminderManager.shared.cancelReminder(id: "tickme.task.\(item.id.uuidString).attime")
                            } else if let eventDate = item.date {
                                await ReminderManager.shared.schedule(
                                    config: cfg,
                                    taskId: item.id,
                                    title: item.title,
                                    eventDate: eventDate
                                )
                            }

                            dismiss()
                        }
                    }
                }
            }
        }
    }

    private var helperText: String {
        switch offset {
        case .none:
            return "No reminder will be sent for this schedule."
        case .atTime:
            return "You’ll be reminded at the exact time of the schedule."
        default:
            return "You’ll be reminded before the schedule. You can also enable an extra reminder at time."
        }
    }
}

// MARK: - Local store for reminder config

private enum ReminderLocalStore {
    private static func key(for id: UUID) -> String { "tm.reminder.config.\(id.uuidString)" }

    static func load(for id: UUID) -> ReminderConfig {
        guard let data = UserDefaults.standard.data(forKey: key(for: id)),
              let cfg = try? JSONDecoder().decode(ReminderConfig.self, from: data)
        else { return .none }
        return cfg
    }

    static func save(_ cfg: ReminderConfig, for id: UUID) {
        if let data = try? JSONEncoder().encode(cfg) {
            UserDefaults.standard.set(data, forKey: key(for: id))
        }
    }

    static func remove(for id: UUID) {
        UserDefaults.standard.removeObject(forKey: key(for: id))
    }
}
