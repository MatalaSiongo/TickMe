//
//  AddCalendarEventSheet.swift
//  Tickme2
//
//  Created by Matala on 2025-12-19.
//

import SwiftUI

struct AddCalendarEventSheet: View {
    @Environment(\.dismiss) private var dismiss

    var selectedDate: Date
    var onSave: (CalendarEvent) -> Void

    @State private var title = ""
    @State private var details = ""
    @State private var date: Date

    init(selectedDate: Date, onSave: @escaping (CalendarEvent) -> Void) {
        self.selectedDate = selectedDate
        self.onSave = onSave
        _date = State(initialValue: selectedDate)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                VStack(spacing: 12) {
                    VStack(spacing: 10) {
                        TextField("What would you like to do?", text: $title)
                            .padding()
                            .background(.white)
                            .cornerRadius(12)

                        TextField("Description", text: $details, axis: .vertical)
                            .lineLimit(3...6)
                            .padding()
                            .background(.white)
                            .cornerRadius(12)

                        HStack(spacing: 12) {
                            Label("Today", systemImage: "calendar")
                                .font(.subheadline)
                                .foregroundStyle(.orange)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.orange.opacity(0.12))
                                .cornerRadius(999)

                            Spacer()

                            Image(systemName: "tag")
                                .foregroundStyle(.black.opacity(0.5))
                            Image(systemName: "paperclip")
                                .foregroundStyle(.black.opacity(0.5))
                            Image(systemName: "ellipsis")
                                .foregroundStyle(.black.opacity(0.5))
                        }

                        DatePicker("When", selection: $date)
                            .datePickerStyle(.compact)
                            .padding(.top, 4)
                    }
                    .padding()
                    .background(.white)
                    .cornerRadius(18)
                    .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.top, 12)
            }
            .navigationTitle("Add")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.headerGreen, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        onSave(CalendarEvent(title: trimmed, details: details, date: date))
                        dismiss()
                    }
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
