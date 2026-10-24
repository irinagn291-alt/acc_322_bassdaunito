import Foundation

/// TablePresence is the fold of the whole chart.
/// Blank means no sortie has been written. Arrived means every sortie has finished.
enum TablePresence: String, Codable, Sendable, Equatable {
    case blank
    case slack
    case charged
    case arrived
}

/// FoldRefusal names a transition the table will not apply.
/// Sight while Slack is not a refusal: it writes an EarlyMark and stays Slack.
enum FoldRefusal: String, Error, Codable, Sendable, Equatable {
    case sortieUnderway
    case noOpenSortie
    case alreadyArrived
    case pagesNotPositive
    case volumeUnusable
    case volumeMissing
}

/// TableFold is the plane-table aggregate.
/// Open, log, and sight are the only writers. Each returns the next chart or a refusal.
enum TableFold {
    static let sightCost = Charge.sightCost

    static func presence(_ archive: TableArchive) -> TablePresence {
        if let open = archive.sorties.last(where: \.isUnderway) {
            return open.phase == .charged ? .charged : .slack
        }
        if archive.sorties.isEmpty {
            return .blank
        }
        return .arrived
    }

    /// driftAngle = (lastEndPage / total − progress) × 45°.
    static func driftAngle(lastEndPage: Int, total: Int, progress: Double) -> Double {
        guard total > 0 else { return 0 }
        let fraction = Double(lastEndPage) / Double(total)
        return (fraction - progress) * 45
    }

    /// Route x is cumulative logged pages divided by the volume page count.
    static func routeX(cumulativePages: Int, total: Int) -> Double {
        guard total > 0 else { return 0 }
        return Double(cumulativePages) / Double(total)
    }

    static func progress(sighted: Int, stationCount: Int) -> Double {
        guard stationCount > 0 else { return 0 }
        return Double(sighted) / Double(stationCount)
    }

    static func open(_ archive: TableArchive, volume: Volume, now: Date) -> Result<TableArchive, FoldRefusal> {
        if archive.sorties.contains(where: \.isUnderway) {
            return .failure(.sortieUnderway)
        }
        let title = volume.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty, volume.pageCount > 0 else {
            return .failure(.volumeUnusable)
        }
        var next = archive
        var stored = volume
        stored.title = title
        if let existing = next.volumes.firstIndex(where: { $0.id == stored.id }) {
            next.volumes[existing] = stored
        } else {
            next.volumes.append(stored)
        }
        let sortie = Sortie(
            id: UUID(),
            volumeID: stored.id,
            openedAt: now,
            datum: StationDatum(anchoredAt: now, label: "Datum"),
            route: Route.laid(forPageCount: stored.pageCount, sightCost: sightCost),
            sessions: [],
            sightMarks: [],
            earlyMarks: []
        )
        next.sorties.append(sortie)
        return .success(next)
    }

    static func log(_ archive: TableArchive, pages: Int, now: Date) -> Result<TableArchive, FoldRefusal> {
        guard pages > 0 else { return .failure(.pagesNotPositive) }
        guard let index = underwayIndex(in: archive) else {
            return .failure(archive.sorties.isEmpty ? .noOpenSortie : .alreadyArrived)
        }
        var next = archive
        next.sorties[index].sessions.append(
            ChargeSession(id: UUID(), pages: pages, loggedAt: now)
        )
        return .success(next)
    }

    static func sight(_ archive: TableArchive, now: Date) -> Result<TableArchive, FoldRefusal> {
        guard let index = underwayIndex(in: archive) else {
            return .failure(archive.sorties.isEmpty ? .noOpenSortie : .alreadyArrived)
        }
        var next = archive
        var sortie = next.sorties[index]
        if sortie.phase == .slack {
            sortie.earlyMarks.append(
                EarlyMark(
                    id: UUID(),
                    chargeBalance: sortie.charge.balance,
                    recordedAt: now,
                    nextAction: "Log"
                )
            )
            next.sorties[index] = sortie
            return .success(next)
        }
        guard let volume = next.volumes.first(where: { $0.id == sortie.volumeID }) else {
            return .failure(.volumeMissing)
        }
        guard sortie.figure.stationIndex < sortie.route.stations.count else {
            return .failure(.alreadyArrived)
        }
        let station = sortie.route.stations[sortie.figure.stationIndex]
        let sightedAfter = sortie.sightMarks.count + 1
        let progress = progress(sighted: sightedAfter, stationCount: sortie.route.count)
        let ray = AlidadeRay(
            bearingDegrees: (Double(station.index) + 0.5) / Double(sortie.route.count) * 180,
            routeX: routeX(cumulativePages: sortie.charge.loggedPages, total: volume.pageCount)
        )
        let angle = driftAngle(
            lastEndPage: sortie.charge.loggedPages,
            total: volume.pageCount,
            progress: progress
        )
        sortie.sightMarks.append(
            SightMark(
                id: UUID(),
                stationID: station.id,
                ray: ray,
                driftAngle: angle,
                pagesSpent: sightCost,
                recordedAt: now
            )
        )
        next.sorties[index] = sortie
        return .success(next)
    }

    private static func underwayIndex(in archive: TableArchive) -> Int? {
        archive.sorties.lastIndex(where: \.isUnderway)
    }
}

/// TableStats folds completed expeditions, sights, and logged pages.
/// The numbers are derived from sorties. They are not stored on the chart.
struct TableStats: Sendable, Equatable {
    var completedSorties: Int
    var totalSights: Int
    var pagesLogged: Int

    static func reading(_ archive: TableArchive) -> TableStats {
        TableStats(
            completedSorties: archive.sorties.filter { !$0.isUnderway }.count,
            totalSights: archive.sorties.reduce(0) { $0 + $1.sightMarks.count },
            pagesLogged: archive.sorties.reduce(0) { $0 + $1.charge.loggedPages }
        )
    }
}
