import Foundation

/// StationDatum is the anchor where a sortie opens.
/// The Figure starts here, before the first station is sighted.
struct StationDatum: Codable, Sendable, Equatable {
    var anchoredAt: Date
    var label: String
}
