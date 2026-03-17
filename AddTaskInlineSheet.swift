//
//  AddTaskInlineSheet.swift
//  Tickme2
//
//  Created by Matala on 2026-02-17.
import SwiftUI

struct AddTaskInlineSheet: View {
    @EnvironmentObject var store: TaskStore
    @Environment(\.dismiss) private var dismiss

    let defaultDate: Date

    @State private var title: String = ""
    @State private var when: Date

    // 🔔 Reminder options (like iPhone Calendar)
    @State private var reminderOffset: ReminderOffset = .none
    @State private var alsoAtTime: Bool = false
    @State private var repeatRule: RepeatRule = .none

    init(defaultDate: Date) {
        self.defaultDate = defaultDate
        _when = State(initialValue: defaultDate)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    TextField("Task title", text: $title)
                        .textInputAutocapitalization(.sentences)
                        .disableAutocorrection(true)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)

                    DatePicker(
                        "Date & Time",
                        selection: $when,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                    .padding(.horizontal)

                    // 🔔 Reminder section
                    VStack(alignment: .leading, spacing: 12) {

                        Text("Reminder")
                            .font(.headline)
                            .padding(.horizontal)

                        Picker("Remind me", selection: $reminderOffset) {
                            ForEach(ReminderOffset.allCases, id: \.self) { option in
                                Text(option.title).tag(option)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal)

                        // Show this only if user picked something "before"
                        if reminderOffset != .none && reminderOffset != .atTime {
                            Toggle("Also remind me at time", isOn: $alsoAtTime)
                                .padding(.horizontal)
                        } else {
                            // If they choose none/atTime, keep toggle off (avoids weird configs)
                            EmptyView()
                                .onAppear { alsoAtTime = false }
                        }

                        Picker("Repeat", selection: $repeatRule) {
                            ForEach(RepeatRule.allCases, id: \.self) { rule in
                                Text(rule.title).tag(rule)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal)

                        Text(reminderHintText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    }
                    .padding(.top, 4)

                    Button {
                        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !cleanTitle.isEmpty else { return }

                        let newItem = TickItem(
                            category: .today,
                            type: .schedule,
                            title: cleanTitle,
                            details: "",
                            date: when,
                            isCompleted: false
                        )

                        // 1) Save the task
                        store.addTask(item: newItem)

                        // 2) Save reminder config for this task (TaskStore schedules automatically)
                        let config = ReminderConfig(offset: reminderOffset, alsoAtTime: alsoAtTime, repeatRule: repeatRule)
                        store.setReminder(for: newItem.id, config: config)

                        dismiss()
                    } label: {
                        Text("Save Task")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 52)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    Spacer(minLength: 10)
                }
                .padding(.top, 12)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .onChange(of: reminderOffset) { _, newValue in
            // If user chooses none/atTime, "also at time" should be off.
            if newValue == .none || newValue == .atTime {
                alsoAtTime = false
            }
        }
    }

    private var reminderHintText: String {
        switch reminderOffset {
        case .none:
            return "No reminder will be scheduled."
        case .atTime:
            return repeatRule == .none
                ? "You’ll be notified at the task time."
                : "You’ll be notified at this time, repeating \(repeatRule.title.lowercased())."
        default:
            let base = "You’ll be notified \(reminderOffset.title.lowercased())."
            if alsoAtTime {
                return repeatRule == .none
                    ? base + " Also at the exact time."
                    : base + " Also at the exact time, repeating \(repeatRule.title.lowercased())."
            } else {
                return repeatRule == .none
                    ? base
                    : base + " Repeats \(repeatRule.title.lowercased())."
            }
        }
    }
}
