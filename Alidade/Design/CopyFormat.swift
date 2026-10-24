import SwiftUI

/// RefusalCopy turns a fold refusal into a short next step.
enum RefusalCopy {
    static func line(_ refusal: FoldRefusal) -> String {
        switch refusal {
        case .sortieUnderway:
            "A book is already open. Finish it first."
        case .noOpenSortie:
            "Open a book first."
        case .alreadyArrived:
            "This expedition is finished."
        case .pagesNotPositive:
            "Enter a whole number above zero."
        case .volumeUnusable:
            "Add a title and a page count above zero."
        case .volumeMissing:
            "That book is missing."
        }
    }
}

/// PageEntry accepts a whole page count and rejects junk on the fly.
enum PageEntry {
    static func whole(_ text: String) -> Int? {
        let locale = Locale.current
        let grouping = locale.groupingSeparator ?? ","
        let decimal = locale.decimalSeparator ?? "."
        if text.contains(decimal) || text.contains("-") {
            return nil
        }
        let cleaned = text
            .replacingOccurrences(of: grouping, with: "")
            .trimmingCharacters(in: .whitespaces)
        guard !cleaned.isEmpty, cleaned.allSatisfy(\.isNumber) else { return nil }
        guard let value = Int(cleaned), value > 0 else { return nil }
        return value
    }
}

/// DayKey formats the local start of day as YYYYMMDD.
enum DayKey {
    static func text(for date: Date) -> Text {
        let start = Calendar.current.startOfDay(for: date)
        return Text(
            start,
            format: Date.VerbatimFormatStyle(
                format: "\(year: .padded(4))\(month: .twoDigits)\(day: .twoDigits)",
                timeZone: .current,
                calendar: .current
            )
        )
    }
}
