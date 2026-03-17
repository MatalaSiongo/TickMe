 
//TickItem.swift
import Foundation

// MARK: - Category (used by TickStore + UI filters)
enum TickCategory: String, CaseIterable, Identifiable, Codable {
    case welcome
    case today
    case schedule

    var id: String { rawValue }
}

// MARK: - Type (note vs schedule)
enum TickItemType: String, CaseIterable, Identifiable, Codable {
    case note
    case schedule

    var id: String { rawValue }
}

// MARK: - Model
struct TickItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var category: TickCategory
    var type: TickItemType
    var title: String
    var details: String
    var date: Date? = nil
    var isCompleted: Bool = false
}

