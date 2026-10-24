import Foundation

/// TableArchive is the single chart stored on device.
/// It holds moored volumes, sortie history, and the preferences the table needs to reopen.
struct TableArchive: Codable, Sendable, Equatable {
    static let schemaVersion = 1
    static let defaultsKey = "ald.table.archive.v1"
    static let demoKey = "ald.demo.v1"

    var schemaVersion: Int
    var volumes: [Volume]
    var sorties: [Sortie]
    var onboardingComplete: Bool

    static let empty = TableArchive(
        schemaVersion: schemaVersion,
        volumes: [],
        sorties: [],
        onboardingComplete: false
    )

    init(schemaVersion: Int, volumes: [Volume], sorties: [Sortie], onboardingComplete: Bool) {
        self.schemaVersion = schemaVersion
        self.volumes = volumes
        self.sorties = sorties
        self.onboardingComplete = onboardingComplete
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let version = try container.decode(Int.self, forKey: .schemaVersion)
        switch version {
        case 1:
            schemaVersion = version
            volumes = try container.decode([Volume].self, forKey: .volumes)
            sorties = try container.decode([Sortie].self, forKey: .sorties)
            onboardingComplete = try container.decode(Bool.self, forKey: .onboardingComplete)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: container,
                debugDescription: "Unknown table schema \(version)."
            )
        }
    }

    func encoded() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(self)
    }

    static func decode(_ data: Data) throws -> TableArchive {
        try JSONDecoder().decode(TableArchive.self, from: data)
    }

    /// Simulator seed: finished expeditions plus one underway sortie already charged.
    static func makeDemo(now: Date = Date(timeIntervalSince1970: 1_700_000_000)) -> TableArchive {
        var archive = TableArchive.empty
        archive.onboardingComplete = true
        let finished: [(String, String, Int)] = [
            ("The Surveyor's Coast", "M. Hale", 40),
            ("Night Latitude", "I. Voss", 40)
        ]
        for (offset, book) in finished.enumerated() {
            archive = walkToArrival(
                archive,
                title: book.0,
                author: book.1,
                pageCount: book.2,
                now: now.addingTimeInterval(Double(offset) * 3600)
            )
        }
        let live = Volume(id: UUID(), title: "Paper Meridian", author: "C. Orth", pageCount: 80)
        let shelf = Volume(id: UUID(), title: "Glass Bearing", author: "A. Quinn", pageCount: 160)
        archive.volumes.append(shelf)
        if case .success(let opened) = TableFold.open(archive, volume: live, now: now.addingTimeInterval(10_000)) {
            archive = opened
        }
        if case .success(let logged) = TableFold.log(archive, pages: 40, now: now.addingTimeInterval(11_000)) {
            archive = logged
        }
        return archive
    }

    private static func walkToArrival(
        _ archive: TableArchive,
        title: String,
        author: String,
        pageCount: Int,
        now: Date
    ) -> TableArchive {
        let volume = Volume(id: UUID(), title: title, author: author, pageCount: pageCount)
        guard case .success(var chart) = TableFold.open(archive, volume: volume, now: now) else {
            return archive
        }
        let stations = max(1, pageCount / TableFold.sightCost)
        for step in 0..<stations {
            let moment = now.addingTimeInterval(Double(step + 1) * 60)
            guard case .success(let logged) = TableFold.log(chart, pages: TableFold.sightCost, now: moment) else {
                return chart
            }
            guard case .success(let sighted) = TableFold.sight(logged, now: moment.addingTimeInterval(1)) else {
                return logged
            }
            chart = sighted
        }
        return chart
    }
}
