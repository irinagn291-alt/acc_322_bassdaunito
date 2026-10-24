import Foundation

/// AlidadeRay is the bearing written when a sight commits.
/// `routeX` is cumulative logged pages divided by the volume page count.
struct AlidadeRay: Codable, Sendable, Equatable {
    var bearingDegrees: Double
    var routeX: Double
}

/// SightMark records one committed resection.
/// It stores the ray and the drift angle after the figure advances.
struct SightMark: Codable, Sendable, Equatable, Identifiable {
    var id: UUID
    var stationID: UUID
    var ray: AlidadeRay
    var driftAngle: Double
    var pagesSpent: Int
    var recordedAt: Date
}
