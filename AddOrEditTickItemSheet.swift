//
//  AddOrEditTickItemSheet.swift
//  Tickme2
// Created by Matala on 2025-12-19.
import SwiftUI

struct AddOrEditTickItemSheet: View {

    enum Mode {
        case add(category: TickCategory)
        case edit(TickItem)
    }

    let mode: Mode
    let onSave: (TickItem) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var category: TickCategory = .today
    @State private var type: TickItemType = .note
    @State private var title: String = ""
    @State private var details: String = ""
    @State private var date: Date = Date()

    private var sheetTitle: String {
        switch mode {
        case .add: return "New Item"
        case .edit: return "Edit Item"
        }
    }

    private var cleanTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(TickCategory.allCases) { cat in
                            Label(cat.title, systemImage: cat.icon).tag(cat)
                        }
                    }
                }

                Section("Type") {
                    Picker("Type", selection: $type) {
                        ForEach(TickItemType.allCases) { t in
                            Text(t.title).tag(t)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Title") {
                    TextField(type == .note ? "Note title" : "Schedule title", text: $title)
                }

                Section("Details") {
                    TextField("Details", text: $details, axis: .vertical)
                        .lineLimit(3...8)
                }

                if type == .schedule {
                    Section("Date & Time") {
                        DatePicker("When", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    }
                }
            }
            .navigationTitle(sheetTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let item = buildItem()
                        onSave(item)
                        dismiss()
                    }
                    .disabled(cleanTitle.isEmpty)
                }
            }
            .onAppear { loadMode() }
        }
    }

    private func loadMode() {
        switch mode {
        case .add(let cat):
            category = cat
            type = .note
            title = ""
            details = ""
            date = Date()

        case .edit(let item):
            category = item.category
            type = item.type
            title = item.title
            details = item.details
            date = item.date ?? Date()
        }
    }

    private func buildItem() -> TickItem {
        switch mode {
        case .add:
            return TickItem(
                category: category,
                type: type,
                title: cleanTitle,
                details: details,
                date: (type == .schedule ? date : nil)
            )

        case .edit(let old):
            var updated = old
            updated.category = category
            updated.type = type
            updated.title = cleanTitle
            updated.details = details
            updated.date = (type == .schedule ? date : nil)
            return updated
        }
    }
}
