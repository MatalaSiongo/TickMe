//
//  TickRootView.swift
//  Tickme2
//
//  Created by Matala on 2025-12-19.
import SwiftUI

struct TickRootView: View {
    @State private var selected: TickCategory = .today
    @State private var showingSheet = false
    @State private var editItem: TickItem? = nil

    @State private var items: [TickItem] = [] // simple local storage for now

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Category", selection: $selected) {
                        ForEach(TickCategory.allCases) { cat in
                            Label(cat.title, systemImage: cat.icon).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section {
                    let filtered = items.filter { $0.category == selected }
                    if filtered.isEmpty {
                        Text("No items here yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(filtered) { item in
                            Button {
                                editItem = item
                                showingSheet = true
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title).font(.headline)
                                    if !item.details.isEmpty {
                                        Text(item.details).font(.subheadline).foregroundStyle(.secondary)
                                    }
                                    if item.type == .schedule, let d = item.date {
                                        Text(d.formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        .onDelete { idx in
                            let filtered = items.enumerated().filter { $0.element.category == selected }
                            for i in idx {
                                let originalIndex = filtered[i].offset
                                items.remove(at: originalIndex)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Tick")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editItem = nil
                        showingSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingSheet) {
                if let editItem {
                    AddOrEditTickItemSheet(mode: .edit(editItem)) { updated in
                        if let idx = items.firstIndex(where: { $0.id == updated.id }) {
                            items[idx] = updated
                        }
                    }
                } else {
                    AddOrEditTickItemSheet(mode: .add(category: selected)) { newItem in
                        items.insert(newItem, at: 0)
                    }
                }
            }
        }
    }
}

