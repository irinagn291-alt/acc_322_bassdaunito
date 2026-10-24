import XCTest
@testable import Alidade

final class AlidadeTests: XCTestCase {
    private var directory: URL!
    private var suiteName: String!

    override func setUp() async throws {
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("alidade-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        suiteName = "alidade.tests.\(UUID().uuidString)"
    }

    override func tearDown() async throws {
        UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
        try? FileManager.default.removeItem(at: directory)
    }

    private func isolatedDefaults() throws -> UserDefaults {
        try XCTUnwrap(UserDefaults(suiteName: suiteName))
    }

    func testDriftAngleAndRouteX() {
        let aligned = TableFold.driftAngle(lastEndPage: 40, total: 80, progress: 0.5)
        XCTAssertEqual(aligned, 0, accuracy: 0.000_001)
        let ahead = TableFold.driftAngle(lastEndPage: 40, total: 80, progress: 0.25)
        XCTAssertEqual(ahead, 11.25, accuracy: 0.000_001)
        XCTAssertEqual(TableFold.routeX(cumulativePages: 40, total: 80), 0.5, accuracy: 0.000_001)
        XCTAssertEqual(TableFold.driftAngle(lastEndPage: 10, total: 0, progress: 1), 0)
    }

    func testSightMarkStoresTheInvariant() throws {
        var chart = try opened(pageCount: 80)
        chart = try XCTUnwrap(log(chart, pages: 40))
        chart = try XCTUnwrap(sight(chart))
        let sortie = try XCTUnwrap(chart.sorties.first)
        let mark = try XCTUnwrap(sortie.sightMarks.first)
        let progress = TableFold.progress(sighted: 1, stationCount: sortie.route.count)
        XCTAssertEqual(sortie.route.count, 4)
        XCTAssertEqual(
            mark.driftAngle,
            TableFold.driftAngle(lastEndPage: 40, total: 80, progress: progress),
            accuracy: 0.000_001
        )
        XCTAssertEqual(mark.ray.routeX, TableFold.routeX(cumulativePages: 40, total: 80), accuracy: 0.000_001)
        XCTAssertEqual(mark.driftAngle, 11.25, accuracy: 0.000_001)
    }

    func testOpenLogAndSightPhases() throws {
        let blank = TableArchive.empty
        XCTAssertEqual(TableFold.presence(blank), .blank)
        XCTAssertEqual(TableFold.sight(blank, now: .now), .failure(.noOpenSortie))
        XCTAssertEqual(TableFold.log(blank, pages: 5, now: .now), .failure(.noOpenSortie))

        var chart = try opened(pageCount: 40)
        XCTAssertEqual(TableFold.presence(chart), .slack)
        XCTAssertEqual(chart.sorties.first?.charge.balance, 0)
        XCTAssertEqual(chart.sorties.first?.datum.label, "Datum")
        XCTAssertEqual(chart.sorties.first?.figure.stationIndex, 0)

        XCTAssertEqual(TableFold.log(chart, pages: 0, now: .now), .failure(.pagesNotPositive))
        XCTAssertEqual(TableFold.log(chart, pages: -3, now: .now), .failure(.pagesNotPositive))
        XCTAssertEqual(TableFold.open(chart, volume: sample(pageCount: 40), now: .now), .failure(.sortieUnderway))

        chart = try XCTUnwrap(log(chart, pages: 19))
        XCTAssertEqual(TableFold.presence(chart), .slack)
        chart = try XCTUnwrap(sight(chart))
        XCTAssertEqual(chart.sorties.first?.earlyMarks.count, 1)
        XCTAssertEqual(chart.sorties.first?.sightMarks.count, 0)
        XCTAssertEqual(chart.sorties.first?.phase, .slack)
        XCTAssertEqual(chart.sorties.first?.earlyMarks.first?.nextAction, "Log")

        chart = try XCTUnwrap(log(chart, pages: 1))
        XCTAssertEqual(TableFold.presence(chart), .charged)
        chart = try XCTUnwrap(sight(chart))
        XCTAssertEqual(chart.sorties.first?.charge.balance, 0)
        XCTAssertEqual(chart.sorties.first?.figure.stationIndex, 1)
        XCTAssertEqual(TableFold.presence(chart), .slack)

        chart = try XCTUnwrap(log(chart, pages: 40))
        XCTAssertEqual(TableFold.presence(chart), .charged)
        chart = try XCTUnwrap(sight(chart))
        XCTAssertEqual(TableFold.presence(chart), .arrived)
        XCTAssertEqual(chart.sorties.first?.charge.balance, 20)
        XCTAssertFalse(chart.sorties.first?.isUnderway ?? true)
        XCTAssertEqual(TableFold.log(chart, pages: 5, now: .now), .failure(.alreadyArrived))
        XCTAssertEqual(TableFold.sight(chart, now: .now), .failure(.alreadyArrived))

        let again = TableFold.open(chart, volume: sample(pageCount: 20, title: "Second"), now: .now)
        XCTAssertEqual(TableFold.presence(try XCTUnwrap(again.get())), .slack)
    }

    func testChargedSightKeepsChargedUntilTheLastStation() throws {
        var chart = try opened(pageCount: 80)
        chart = try XCTUnwrap(log(chart, pages: 40))
        chart = try XCTUnwrap(sight(chart))
        XCTAssertEqual(TableFold.presence(chart), .charged)
        XCTAssertEqual(chart.sorties.first?.charge.balance, 20)
        XCTAssertEqual(chart.sorties.first?.figure.stationIndex, 1)
    }

    func testEmptyVolumeIsRefused() {
        let volume = Volume(id: UUID(), title: "   ", author: "A", pageCount: 10)
        XCTAssertEqual(TableFold.open(.empty, volume: volume, now: .now), .failure(.volumeUnusable))
        let zero = Volume(id: UUID(), title: "Pages", author: "A", pageCount: 0)
        XCTAssertEqual(TableFold.open(.empty, volume: zero, now: .now), .failure(.volumeUnusable))
    }

    func testDemoSeedOpensOnAChargedSortie() {
        let demo = TableArchive.makeDemo()
        XCTAssertTrue(demo.onboardingComplete)
        XCTAssertEqual(TableFold.presence(demo), .charged)
        XCTAssertGreaterThanOrEqual(demo.sorties.last?.charge.balance ?? 0, Charge.sightCost)
        XCTAssertEqual(TableStats.reading(demo).completedSorties, 2)
        XCTAssertGreaterThan(demo.volumes.count, 2)
        XCTAssertEqual(demo.sorties.last?.phase, .charged)
    }

    func testArchiveRoundTripAndCorruptFallback() async throws {
        let store = TableStore(directory: directory, suiteName: suiteName, debounce: .milliseconds(20))
        var chart = try opened(pageCount: 40)
        chart = try XCTUnwrap(log(chart, pages: 5))
        chart = try XCTUnwrap(sight(chart))
        await store.scheduleSave(chart)
        await store.flush()
        let later = try XCTUnwrap(log(chart, pages: 20))
        await store.scheduleSave(later)
        await store.flush()

        let reloaded = TableStore(directory: directory, suiteName: suiteName)
        let loaded = await reloaded.load()
        XCTAssertEqual(loaded.archive, later)
        XCTAssertNil(loaded.note)
        let mirrored = try XCTUnwrap(isolatedDefaults().data(forKey: TableArchive.defaultsKey))
        XCTAssertEqual(try TableArchive.decode(mirrored), later)

        let fileURL = directory.appendingPathComponent("table-archive.json")
        try Data("not-json".utf8).write(to: fileURL, options: .atomic)
        let restored = await reloaded.load()
        XCTAssertEqual(restored.archive, chart)
        XCTAssertNotNil(restored.note)

        await reloaded.reset()
        let cleared = await TableStore(directory: directory, suiteName: suiteName).load()
        XCTAssertEqual(cleared.archive, .empty)
        XCTAssertNil(try isolatedDefaults().data(forKey: TableArchive.defaultsKey))
    }

    @MainActor
    func testBoardAppliesTheFoldAndKeepsMemoryWhenReset() async throws {
        let store = TableStore(directory: directory, suiteName: suiteName, debounce: .milliseconds(30))
        let board = TableBoard(store: store, seedsOnSimulator: false)
        await board.prepare()
        await board.open(volume: sample(pageCount: 40))
        let opened = board.reading
        XCTAssertEqual(opened.presence, .slack)
        await board.sight()
        let early = board.reading
        let earlyRefusal = board.lastRefusal
        XCTAssertEqual(early.earlyMarks, 1)
        XCTAssertEqual(early.presence, .slack)
        XCTAssertNil(earlyRefusal)
        await board.log(pages: 20)
        let charged = board.reading
        XCTAssertTrue(charged.canSight)
        XCTAssertEqual(charged.presence, .charged)
        await board.open(volume: sample(pageCount: 80, title: "Other"))
        let refusal = board.lastRefusal
        let sortieCount = board.archive.sorties.count
        XCTAssertEqual(refusal, .sortieUnderway)
        XCTAssertEqual(sortieCount, 1)
        await board.flush()
        let loaded = await TableStore(directory: directory, suiteName: suiteName).load()
        XCTAssertEqual(loaded.archive.sorties.count, 1)
        XCTAssertEqual(loaded.archive.sorties.first?.charge.balance, 20)
        await board.resetAllData()
        let blank = board.reading
        XCTAssertEqual(blank.presence, .blank)
        let afterReset = await TableStore(directory: directory, suiteName: suiteName).load()
        XCTAssertEqual(afterReset.archive, .empty)
    }

    func testUnknownSchemaDoesNotDecode() {
        let payload = #"{"onboardingComplete":false,"schemaVersion":9,"sorties":[],"volumes":[]}"#
        XCTAssertThrowsError(try TableArchive.decode(Data(payload.utf8)))
    }

    func testReviewLaunchParsesScreenArgument() {
        XCTAssertNil(ReviewLaunch.screen(from: ["Alidade"]))
        XCTAssertNil(ReviewLaunch.screen(from: ["Alidade", "-ReviewScreen"]))
        XCTAssertEqual(ReviewLaunch.screen(from: ["Alidade", "-ReviewScreen", "today"]), "today")
        XCTAssertEqual(ReviewLaunch.screen(from: ["Alidade", "-ReviewScreen", "log"]), "log")
        XCTAssertEqual(ReviewLaunch.screen(from: ["Alidade", "-ReviewScreen", "goals"]), "goals")
        XCTAssertEqual(ReviewLaunch.screen(from: ["Alidade", "-ReviewScreen", "catalogue"]), "catalogue")
        XCTAssertEqual(ReviewLaunch.screen, ReviewLaunch.screen(from: ProcessInfo.processInfo.arguments))
    }

    private func sample(pageCount: Int, title: String = "Coast") -> Volume {
        Volume(id: UUID(), title: title, author: "M. Hale", pageCount: pageCount)
    }

    private func opened(pageCount: Int) throws -> TableArchive {
        try XCTUnwrap(TableFold.open(.empty, volume: sample(pageCount: pageCount), now: .now).get())
    }

    private func log(_ archive: TableArchive, pages: Int) -> TableArchive? {
        if case .success(let next) = TableFold.log(archive, pages: pages, now: .now) {
            return next
        }
        return nil
    }

    private func sight(_ archive: TableArchive) -> TableArchive? {
        if case .success(let next) = TableFold.sight(archive, now: .now) {
            return next
        }
        return nil
    }
}
