import Foundation

/// TableSheet is a cover destination. today, log, and goals are launch keys, not tabs.
enum TableSheet: String, Identifiable {
    case session
    case pace
    case shelf
    case expedition
    case settings

    var id: String { rawValue }

    static func resolve(_ key: String?) -> TableSheet? {
        switch key {
        case "log", "sessionlog":
            .session
        case "goals", "stats":
            .pace
        case "catalogue":
            .shelf
        case "sortie", "expedition":
            .expedition
        case "settings":
            .settings
        default:
            nil
        }
    }
}
