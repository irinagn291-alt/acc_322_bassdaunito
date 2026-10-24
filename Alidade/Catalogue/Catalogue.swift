import Foundation

/// Catalogue is the local shelf that moors a volume into a sortie.
/// Open writes the sortie at Datum. A second open while one is underway is refused.
enum Catalogue {
    static let shelf: [Volume] = [
        Volume(id: pinned("A1D00001-0000-4000-8000-000000000001"), title: "The Surveyor's Coast", author: "M. Hale", pageCount: 240),
        Volume(id: pinned("A1D00001-0000-4000-8000-000000000002"), title: "Night Latitude", author: "I. Voss", pageCount: 180),
        Volume(id: pinned("A1D00001-0000-4000-8000-000000000003"), title: "Paper Meridian", author: "C. Orth", pageCount: 320),
        Volume(id: pinned("A1D00001-0000-4000-8000-000000000004"), title: "Glass Bearing", author: "A. Quinn", pageCount: 160)
    ]

    private static func pinned(_ string: String) -> UUID {
        if let id = UUID(uuidString: string) {
            return id
        }
        return UUID()
    }

    static func moor(_ volume: Volume, into archive: TableArchive, now: Date) -> Result<TableArchive, FoldRefusal> {
        TableFold.open(archive, volume: volume, now: now)
    }
}
