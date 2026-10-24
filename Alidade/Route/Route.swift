import Foundation

/// Route is the ordered station chain for one volume.
/// Its length is the page count divided by the sight cost, at least one station.
struct Route: Codable, Sendable, Equatable {
    var stations: [Station]

    var count: Int { stations.count }

    static func laid(forPageCount pageCount: Int, sightCost: Int) -> Route {
        let steps = max(1, pageCount / max(sightCost, 1))
        let stations = (0..<steps).map { index in
            Station(id: UUID(), index: index, title: "Station \(index + 1)")
        }
        return Route(stations: stations)
    }
}
