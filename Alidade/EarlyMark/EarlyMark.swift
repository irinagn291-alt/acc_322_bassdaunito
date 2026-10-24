import Foundation

/// EarlyMark records a sight attempted while the table is Slack.
/// The station does not advance. The next useful tap is to log pages.
struct EarlyMark: Codable, Sendable, Equatable, Identifiable {
    var id: UUID
    var chargeBalance: Int
    var recordedAt: Date
    var nextAction: String
}
