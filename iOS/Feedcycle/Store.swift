import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    static let freeLimit = 8

    @Published var items: [Feeding] = []
    @Published var isPro: Bool = false

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("feedcycle_items.json")
        load()
    }

    var canAddMore: Bool {
        isPro || items.count < Store.freeLimit
    }

    func add(_ item: Feeding) {
        items.insert(item, at: 0)
        save()
    }

    func update(_ item: Feeding) {
        if let idx = items.firstIndex(where: { $0.id == item.id }) {
            items[idx] = item
            save()
        }
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: Feeding) {
        items.removeAll { $0.id == item.id }
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([Feeding].self, from: data) else {
            items = Store.seedData()
            save()
            return
        }
        items = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    static func seedData() -> [Feeding] {
        [
        Feeding(date: Date().addingTimeInterval(-86400), plantName: "Ficus", product: "Fish emulsion", dose: "1 tbsp/gal"),
        Feeding(date: Date().addingTimeInterval(-172800), plantName: "Monstera", product: "Balanced 20-20-20", dose: "half strength"),
        Feeding(date: Date().addingTimeInterval(-259200), plantName: "Citrus Tree", product: "Citrus feed", dose: "per label")
        ]
    }
}
