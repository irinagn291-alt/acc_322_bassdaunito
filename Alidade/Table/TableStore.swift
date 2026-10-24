import Foundation

/// TableStore is the only seam between the chart and disk.
/// The board keeps the in-memory chart. This actor writes that chart after the fold.
actor TableStore {
    struct LoadResult: Sendable, Equatable {
        var archive: TableArchive
        var note: String?
    }

    private let directory: URL
    private let suiteName: String?
    private let debounce: Duration
    private let demoKey: String
    private let fileURL: URL
    private let backupURL: URL
    private var latest: TableArchive?
    private var generation = 0
    private var pendingSave: Task<Void, Never>?
    private(set) var writeNote: String?

    init(directory: URL, suiteName: String?, debounce: Duration = .milliseconds(300), demoKey: String = TableArchive.demoKey) {
        self.directory = directory
        self.suiteName = suiteName
        self.debounce = debounce
        self.demoKey = demoKey
        fileURL = directory.appendingPathComponent("table-archive.json")
        backupURL = directory.appendingPathComponent("table-archive.json.backup")
    }

    static func live() -> TableStore {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        let directory = (root ?? URL(fileURLWithPath: NSTemporaryDirectory()))
            .appendingPathComponent("BassDaunito", isDirectory: true)
        return TableStore(directory: directory, suiteName: nil)
    }

    /// A new defaults object stays inside this actor. `nil` suite is the standard domain.
    private func defaults() -> UserDefaults? {
        guard let suiteName else { return .standard }
        return UserDefaults(suiteName: suiteName)
    }

    func load() -> LoadResult {
        switch read(fileURL) {
        case .missing:
            if let data = defaults()?.data(forKey: TableArchive.defaultsKey) {
                do {
                    return LoadResult(archive: try TableArchive.decode(data), note: nil)
                } catch {
                    return LoadResult(archive: .empty, note: "The saved chart could not be read. The table started blank.")
                }
            }
            return LoadResult(archive: .empty, note: nil)
        case .decoded(let archive):
            return LoadResult(archive: archive, note: nil)
        case .unreadable:
            switch read(backupURL) {
            case .decoded(let archive):
                return LoadResult(
                    archive: archive,
                    note: "The chart file was unreadable. The previous chart was restored."
                )
            case .missing, .unreadable:
                return LoadResult(
                    archive: .empty,
                    note: "The chart file was unreadable. The table started blank."
                )
            }
        }
    }

    func scheduleSave(_ archive: TableArchive) {
        latest = archive
        generation += 1
        let ticket = generation
        pendingSave?.cancel()
        pendingSave = Task {
            do {
                try await Task.sleep(for: debounce)
            } catch is CancellationError {
                return
            } catch {
                return
            }
            await self.commit(ticket: ticket)
        }
    }

    func flush() async {
        generation += 1
        pendingSave?.cancel()
        pendingSave = nil
        guard let latest else { return }
        await write(latest)
    }

    func reset() async {
        generation += 1
        pendingSave?.cancel()
        pendingSave = nil
        latest = TableArchive.empty
        defaults()?.removeObject(forKey: TableArchive.defaultsKey)
        let manager = FileManager.default
        for url in [fileURL, backupURL] where manager.fileExists(atPath: url.path) {
            do {
                try manager.removeItem(at: url)
            } catch {
                writeNote = "The chart file could not be removed."
            }
        }
    }

    func demoAlreadySeeded() -> Bool {
        defaults()?.bool(forKey: demoKey) ?? false
    }

    func markDemoSeeded() {
        defaults()?.set(true, forKey: demoKey)
    }

    private func commit(ticket: Int) async {
        guard ticket == generation, let latest else { return }
        await write(latest)
    }

    private func write(_ archive: TableArchive) async {
        do {
            let data = try archive.encoded()
            try ensureDirectory()
            let manager = FileManager.default
            if manager.fileExists(atPath: fileURL.path) {
                if manager.fileExists(atPath: backupURL.path) {
                    try manager.removeItem(at: backupURL)
                }
                try manager.copyItem(at: fileURL, to: backupURL)
            }
            try data.write(to: fileURL, options: .atomic)
            defaults()?.set(data, forKey: TableArchive.defaultsKey)
            writeNote = nil
        } catch {
            writeNote = "The chart could not be saved."
        }
    }

    private func ensureDirectory() throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    private enum ReadBody {
        case missing
        case decoded(TableArchive)
        case unreadable
    }

    private func read(_ url: URL) -> ReadBody {
        let manager = FileManager.default
        guard manager.fileExists(atPath: url.path) else { return .missing }
        do {
            let data = try Data(contentsOf: url)
            return .decoded(try TableArchive.decode(data))
        } catch {
            return .unreadable
        }
    }
}
