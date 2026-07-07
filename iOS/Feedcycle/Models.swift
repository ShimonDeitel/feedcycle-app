import Foundation

struct Feeding: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date = Date()
    var plantName: String
    var product: String
    var dose: String
}
