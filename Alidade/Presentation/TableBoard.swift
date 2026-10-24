import Foundation
import Observation

/// TableBoard is the in-memory table between the fold and the screens.
/// Screens call open, log, and sight here. They do not touch the archive file.
@MainActor
@Observable
final class TableBoard {
    private(set) var archive: TableArchive
    private(set) var loadNote: String?
    private(set) var lastRefusal: FoldRefusal?
    private(set) var isReady = false
    /// Launch key captured once, after onboarding, from `ReviewLaunch.screen`.
    private(set) var launchKey: String?
    private let store: TableStore
    private let seedsOnSimulator: Bool
    private var prepared = false
    private var didReadLaunch = false

    init(store: TableStore = .live(), archive: TableArchive = .empty, seedsOnSimulator: Bool = true) {
        self.store = store
        self.archive = archive
        self.seedsOnSimulator = seedsOnSimulator
    }

    var reading: MapReading {
        MapReading(archive)
    }

    var stats: TableStats {
        TableStats.reading(archive)
    }

    var underway: Sortie? {
        archive.sorties.last { $0.isUnderway }
    }

    var latestSortie: Sortie? {
        underway ?? archive.sorties.last
    }

    func volume(for sortie: Sortie) -> Volume? {
        archive.volumes.first { $0.id == sortie.volumeID }
    }

    func prepare() async {
        guard !prepared else { return }
        prepared = true
        defer { isReady = true }
        let loaded = await store.load()
        if Task.isCancelled { return }
        archive = loaded.archive
        loadNote = loaded.note
        #if targetEnvironment(simulator)
        let seeded = await store.demoAlreadySeeded()
        if seedsOnSimulator && !seeded && archive.sorties.isEmpty && !archive.onboardingComplete {
            archive = TableArchive.makeDemo()
            loadNote = nil
            await store.scheduleSave(archive)
            await store.flush()
            await store.markDemoSeeded()
        } else if !seeded {
            await store.markDemoSeeded()
        }
        #endif
    }

    /// Reads `ReviewLaunch.screen` a single time, and only once onboarding is done.
    func consumeLaunchScreenIfNeeded() {
        guard archive.onboardingComplete, !didReadLaunch else { return }
        didReadLaunch = true
        launchKey = ReviewLaunch.screen
    }

    func clearLaunchKey() {
        launchKey = nil
    }

    func completeOnboarding() async {
        guard !archive.onboardingComplete else { return }
        var next = archive
        next.onboardingComplete = true
        archive = next
        await store.scheduleSave(next)
        await store.flush()
    }

    func reopenIntro() async {
        var next = archive
        next.onboardingComplete = false
        archive = next
        await store.scheduleSave(next)
        await store.flush()
    }

    func reload() async {
        let loaded = await store.load()
        if Task.isCancelled { return }
        archive = loaded.archive
        loadNote = loaded.note
    }

    func open(volume: Volume, now: Date = Date()) async {
        await apply(TableFold.open(archive, volume: volume, now: now))
    }

    func moorFromShelf(_ volume: Volume, now: Date = Date()) async {
        await apply(Catalogue.moor(volume, into: archive, now: now))
    }

    func log(pages: Int, now: Date = Date()) async {
        await apply(TableFold.log(archive, pages: pages, now: now))
    }

    func sight(now: Date = Date()) async {
        await apply(TableFold.sight(archive, now: now))
    }

    func flush() async {
        await store.flush()
    }

    func resetAllData() async {
        archive = .empty
        lastRefusal = nil
        loadNote = nil
        await store.reset()
    }

    private func apply(_ result: Result<TableArchive, FoldRefusal>) async {
        switch result {
        case .success(let next):
            archive = next
            lastRefusal = nil
            await store.scheduleSave(next)
        case .failure(let refusal):
            lastRefusal = refusal
        }
    }
}
