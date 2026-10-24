import Foundation

/// SortiePhase is the active fold of one expedition.
/// Slack is under the sight cost, Charged can sight, Arrived has sighted the last station.
enum SortiePhase: String, Codable, Sendable, Equatable {
    case slack
    case charged
    case arrived
}

/// Sortie is one expedition over a moored volume.
/// Sessions, sight marks, and early marks are the events. Phase, charge, and figure fold from them.
struct Sortie: Codable, Sendable, Equatable, Identifiable {
    var id: UUID
    var volumeID: UUID
    var openedAt: Date
    var datum: StationDatum
    var route: Route
    var sessions: [ChargeSession]
    var sightMarks: [SightMark]
    var earlyMarks: [EarlyMark]

    var figure: Figure {
        Figure(stationIndex: sightMarks.count)
    }

    var charge: Charge {
        Charge(sessions: sessions, spentPages: sightMarks.count * Charge.sightCost)
    }

    var isUnderway: Bool {
        route.count > 0 && sightMarks.count < route.count
    }

    var phase: SortiePhase {
        if !isUnderway {
            return .arrived
        }
        if charge.meetsSightCost {
            return .charged
        }
        return .slack
    }
}
