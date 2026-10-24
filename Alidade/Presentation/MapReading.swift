import Foundation

/// MapReading is the chart the map will draw.
/// It is folded from the archive. It never reads the store.
struct MapReading: Sendable, Equatable {
    var presence: TablePresence
    var chargeBalance: Int
    var loggedPages: Int
    var figureIndex: Int
    var stationCount: Int
    var driftAngle: Double
    var routeX: Double
    var volumeTitle: String?
    var canSight: Bool
    var canLog: Bool
    var canOpen: Bool
    var earlyMarks: Int
    var sightMarks: Int

    init(_ archive: TableArchive) {
        presence = TableFold.presence(archive)
        guard let sortie = archive.sorties.last(where: \.isUnderway) ?? archive.sorties.last else {
            chargeBalance = 0
            loggedPages = 0
            figureIndex = 0
            stationCount = 0
            driftAngle = 0
            routeX = 0
            volumeTitle = nil
            canSight = false
            canLog = false
            canOpen = true
            earlyMarks = 0
            sightMarks = 0
            return
        }
        let total = archive.volumes.first(where: { $0.id == sortie.volumeID })?.pageCount ?? 0
        let progress = TableFold.progress(sighted: sortie.figure.stationIndex, stationCount: sortie.route.count)
        chargeBalance = sortie.charge.balance
        loggedPages = sortie.charge.loggedPages
        figureIndex = sortie.figure.stationIndex
        stationCount = sortie.route.count
        driftAngle = TableFold.driftAngle(lastEndPage: loggedPages, total: total, progress: progress)
        routeX = TableFold.routeX(cumulativePages: loggedPages, total: total)
        volumeTitle = archive.volumes.first(where: { $0.id == sortie.volumeID })?.title
        canSight = sortie.isUnderway
        canLog = sortie.isUnderway
        canOpen = !sortie.isUnderway
        earlyMarks = sortie.earlyMarks.count
        sightMarks = sortie.sightMarks.count
    }
}
