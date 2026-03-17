//
//  TickStore.swift
//  Tickme2
//
//  Created by Matala on 2025-12-19.
//

import Foundation
import Combine

final class TickStore: ObservableObject {

    @Published var items: [TickItem] = []

    // MARK: - Queries
    func items(for category: TickCategory) -> [TickItem] {
        items.filter { $0.category == category }
    }

    // MARK: - CRUD
    func add(_ item: TickItem) {
        items.insert(item, at: 0)
    }

    func update(_ item: TickItem) {
        guard let i = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[i] = item
    }

    func delete(_ item: TickItem) {
        items.removeAll { $0.id == item.id }
    }
}
