import SwiftUI

struct AddTaskSheet: View {
    @ObservedObject var store: TaskStore
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var dueDate: Date = Date().addingTimeInterval(60 * 60)

    private var cleanTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("Title", text: $title)
                        .textInputAutocapitalization(.sentences)
                        .disableAutocorrection(true)

                    DatePicker(
                        "Due",
                        selection: $dueDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let item = TickItem(
                            category: .schedule,
                            type: .schedule,
                            title: cleanTitle,
                            details: "",
                            date: dueDate,
                            isCompleted: false
                        )

                        store.addTask(item: item)
                        dismiss()
                    }
                    .disabled(cleanTitle.isEmpty)
                }
            }
        }
    }
}
