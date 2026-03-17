//
//  TickModels.swift
//  Tickme2
// Created by Matala on 2026-02-17.
import Foundation
import SwiftUI

enum TickCategory: String, CaseIterable, Identifiable, Codable {
    case persona, work, welcome, inbox, today

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .persona: return "person.fill"
        case .work: return "briefcase.fill"
        case .welcome: return "hand.wave.fill"
        case .inbox: return "tray.fill"
        case .today: return "sun.max.fill"
        }
    }

    var title: String { rawValue.capitalized }
}

enum TickItemType: String, CaseIterable, Identifiable, Codable {
    case note, schedule

    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}




