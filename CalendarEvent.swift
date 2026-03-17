//
//  CalendarEvent.swift
//  Tickme2
//
//  Created by Matala on 2025-12-19.
//

import Foundation

struct CalendarEvent: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var details: String
    var date: Date

    init(id: UUID = UUID(), title: String, details: String = "", date: Date) {
        self.id = id
        self.title = title
        self.details = details
        self.date = date
    }
}
