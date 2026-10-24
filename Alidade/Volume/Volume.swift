import Foundation

/// Volume is a moored book on the table.
/// Catalogue opens one into a Sortie. Page count fixes the route length.
struct Volume: Codable, Sendable, Equatable, Identifiable {
    var id: UUID
    var title: String
    var author: String
    var pageCount: Int
}
