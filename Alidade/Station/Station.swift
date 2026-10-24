import Foundation

/// Station is one resection point on a route.
/// Sight advances the Figure onto the next station. The last sight arrives.
struct Station: Codable, Sendable, Equatable, Identifiable {
    var id: UUID
    var index: Int
    var title: String
}
