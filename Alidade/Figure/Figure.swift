import Foundation

/// Figure is the surveyor standing on the open route.
/// `stationIndex` counts committed sights. Zero means the figure is still on Datum.
struct Figure: Codable, Sendable, Equatable {
    var stationIndex: Int
}
