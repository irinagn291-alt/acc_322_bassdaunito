import Foundation

/// Charge is the page pool that gates a sight.
/// Sessions keep every logged page. Balance is sessions minus pages spent on sights.
struct ChargeSession: Codable, Sendable, Equatable, Identifiable {
    var id: UUID
    var pages: Int
    var loggedAt: Date
}

struct Charge: Sendable, Equatable {
    static let sightCost = 20

    var sessions: [ChargeSession]
    var spentPages: Int

    var loggedPages: Int {
        sessions.reduce(0) { $0 + $1.pages }
    }

    var balance: Int {
        loggedPages - spentPages
    }

    var meetsSightCost: Bool {
        balance >= Self.sightCost
    }
}
