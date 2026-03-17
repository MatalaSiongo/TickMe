//
//  ReminderConfig.swift
//  Tickme2
//
//  Created by Matala on 2026-02-26.
//

import Foundation
import Foundation

enum RepeatRule: String, Codable, CaseIterable {
    case none
    case daily
    case weekly
    case monthly

    var title: String {
        switch self {
        case .none: return "Never"
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        }
    }
}

enum ReminderOffset: String, Codable, CaseIterable {
    case none
    case atTime
    case fiveMinBefore
    case fifteenMinBefore
    case oneHourBefore
    case oneDayBefore

    var title: String {
        switch self {
        case .none: return "None"
        case .atTime: return "At time of event"
        case .fiveMinBefore: return "5 minutes before"
        case .fifteenMinBefore: return "15 minutes before"
        case .oneHourBefore: return "1 hour before"
        case .oneDayBefore: return "1 day before"
        }
    }

    var secondsBefore: TimeInterval {
        switch self {
        case .none: return 0
        case .atTime: return 0
        case .fiveMinBefore: return 5 * 60
        case .fifteenMinBefore: return 15 * 60
        case .oneHourBefore: return 60 * 60
        case .oneDayBefore: return 24 * 60 * 60
        }
    }
}

struct ReminderConfig: Codable, Equatable {
    var offset: ReminderOffset = .none
    var alsoAtTime: Bool = false
    var repeatRule: RepeatRule = .none

    static let none = ReminderConfig(offset: .none, alsoAtTime: false, repeatRule: .none)
}
