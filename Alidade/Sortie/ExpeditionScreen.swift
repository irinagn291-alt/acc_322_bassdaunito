import SwiftUI

/// SortieScreen is the cover name for the open expedition.
struct SortieScreen: View {
    var body: some View {
        ExpeditionScreen()
    }
}

/// ExpeditionScreen reads the open line of stops, sights, and early attempts.
struct ExpeditionScreen: View {
    @Environment(TableBoard.self) private var board
    @Environment(\.dismiss) private var dismiss
    @Environment(\.coverDismiss) private var coverDismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("ald.wholeDegrees") private var wholeDegrees = false
    @State private var opening = false
    @State private var working = false
    @State private var pageDraft = 8

    var body: some View {
        Group {
            if let sortie = board.latestSortie {
                filled(sortie)
            } else {
                empty
            }
        }
        .background(DesignTokens.bg)
        .sheetChrome("Expedition")
    }

    private func filled(_ sortie: Sortie) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.s12) {
                summary(sortie)
                Text("STOPS")
                    .appFont(.caption)
                    .foregroundStyle(DesignTokens.muted)
                ForEach(sortie.route.stations) { station in
                    stopRow(station, sortie: sortie)
                }
                if !sortie.sightMarks.isEmpty {
                    Text("SIGHTS")
                        .appFont(.caption)
                        .foregroundStyle(DesignTokens.muted)
                    ForEach(sortie.sightMarks) { mark in
                        HStack(alignment: .firstTextBaseline, spacing: Spacing.s8) {
                            Text(mark.recordedAt, format: .dateTime.month(.abbreviated).day().hour().minute())
                                .appFont(.body)
                                .foregroundStyle(DesignTokens.ink)
                                .lineLimit(1)
                            Spacer(minLength: Spacing.s8)
                            Text(bearing(mark.ray.bearingDegrees))
                                .appFont(.mono)
                                .foregroundStyle(DesignTokens.ink)
                        }
                        .cardPlate()
                    }
                }
                if board.reading.presence == .slack && sortie.isUnderway {
                    pageStepper
                }
            }
            .padding(Spacing.s16)
            .padding(.bottom, Spacing.s24)
        }
        .safeAreaInset(edge: .bottom) {
            primaryAction(sortie)
                .padding(.horizontal, Spacing.s16)
                .padding(.top, Spacing.s8)
                .padding(.bottom, Spacing.s12)
                .background(DesignTokens.bg)
        }
    }

    private func summary(_ sortie: Sortie) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            Text(board.volume(for: sortie)?.title ?? "Open book")
                .appFont(.headline)
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            if driftKnown(sortie) {
                Text(driftValue(sortie), format: .number.precision(.fractionLength(wholeDegrees ? 0...0 : 0...1)))
                    .appFont(.display)
                    .foregroundStyle(DesignTokens.ink)
                    .contentTransition(.numericText(value: driftValue(sortie)))
                    .animation(Motion.travel(reduceMotion), value: driftValue(sortie))
                Text("degrees of drift")
                    .appFont(.caption)
                    .foregroundStyle(DesignTokens.muted)
            }
            Text(progressLine(sortie))
                .appFont(.body)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .cardPlate()
    }

    private func stopRow(_ station: Station, sortie: Sortie) -> some View {
        let status = stopStatus(station, sortie: sortie)
        let pages = pageMilestone(station, sortie: sortie)
        return HStack(alignment: .firstTextBaseline, spacing: Spacing.s8) {
            VStack(alignment: .leading, spacing: Spacing.s4) {
                Text(station.title)
                    .appFont(.headline)
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(1)
                Text("Page \(pages)")
                    .appFont(.body)
                    .foregroundStyle(DesignTokens.muted)
            }
            Spacer(minLength: Spacing.s8)
            Text(status)
                .appFont(.caption)
                .foregroundStyle(status == "Next" ? DesignTokens.accent : DesignTokens.ink)
        }
        .cardPlate()
    }

    private var pageStepper: some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            Text("Pages to log")
                .appFont(.body)
                .foregroundStyle(DesignTokens.ink)
            HStack(spacing: Spacing.s8) {
                Button {
                    if pageDraft > 1 { pageDraft -= 1 }
                } label: {
                    Text("Fewer")
                        .appFont(.headline)
                        .foregroundStyle(DesignTokens.ink)
                        .frame(maxWidth: .infinity, minHeight: Spacing.s48)
                        .background {
                            RoundedRectangle(cornerRadius: Radius.chip, style: .continuous)
                                .fill(DesignTokens.surface)
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressStyle())
                Text("\(pageDraft) pages")
                    .appFont(.mono)
                    .foregroundStyle(DesignTokens.ink)
                    .frame(minWidth: Spacing.s48 * 2)
                Button {
                    if pageDraft < 200 { pageDraft += 1 }
                } label: {
                    Text("More")
                        .appFont(.headline)
                        .foregroundStyle(DesignTokens.ink)
                        .frame(maxWidth: .infinity, minHeight: Spacing.s48)
                        .background {
                            RoundedRectangle(cornerRadius: Radius.chip, style: .continuous)
                                .fill(DesignTokens.surface)
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressStyle())
            }
        }
        .cardPlate()
    }

    private func primaryAction(_ sortie: Sortie) -> some View {
        Button(action: { act(on: sortie) }) {
            Text(primaryTitle(sortie))
        }
        .buttonStyle(FilledCapsuleStyle(busy: working || opening))
        .disabled(working || opening || primaryTitle(sortie) == "Expedition finished")
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            Text("No expedition yet.")
                .appFont(.title)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text("Open a book to lay the stops.")
                .appFont(.body)
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: Spacing.s16)
            Button(action: openFirstBook) {
                Text("Open a book")
            }
            .buttonStyle(FilledCapsuleStyle(busy: opening))
            .disabled(opening)
        }
        .padding(Spacing.s16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func progressLine(_ sortie: Sortie) -> String {
        let seen = min(sortie.figure.stationIndex, sortie.route.count)
        let logged = sortie.charge.loggedPages
        return "\(seen) of \(sortie.route.count) stops sighted. \(logged) pages logged."
    }

    private func stopStatus(_ station: Station, sortie: Sortie) -> String {
        if station.index < sortie.figure.stationIndex {
            return "Sighted"
        }
        if station.index == sortie.figure.stationIndex && sortie.isUnderway {
            return "Next"
        }
        return "Ahead"
    }

    private func pageMilestone(_ station: Station, sortie: Sortie) -> Int {
        let total = board.volume(for: sortie)?.pageCount ?? 0
        let raw = (station.index + 1) * Charge.sightCost
        if total > 0 {
            return min(total, raw)
        }
        return raw
    }

    private func primaryTitle(_ sortie: Sortie) -> String {
        if !sortie.isUnderway {
            return "Open a book"
        }
        if board.reading.presence == .charged {
            return "Sight the next stop"
        }
        return "Log \(pageDraft) pages"
    }

    private func bearing(_ degrees: Double) -> String {
        let shown = degrees.formatted(.number.precision(.fractionLength(wholeDegrees ? 0...0 : 0...1)))
        return "\(shown)°"
    }

    private func driftKnown(_ sortie: Sortie) -> Bool {
        board.volume(for: sortie) != nil && sortie.charge.loggedPages > 0
    }

    private func driftValue(_ sortie: Sortie) -> Double {
        guard let volume = board.volume(for: sortie), volume.pageCount > 0 else { return 0 }
        let progress = TableFold.progress(sighted: sortie.figure.stationIndex, stationCount: sortie.route.count)
        return TableFold.driftAngle(
            lastEndPage: sortie.charge.loggedPages,
            total: volume.pageCount,
            progress: progress
        )
    }

    private func act(on sortie: Sortie) {
        if !sortie.isUnderway {
            openFirstBook()
            return
        }
        if board.reading.presence == .charged {
            guard !working else { return }
            working = true
            Task {
                await board.sight()
                working = false
            }
            return
        }
        guard !working, pageDraft > 0 else { return }
        working = true
        let pages = pageDraft
        Task {
            await board.log(pages: pages)
            working = false
        }
    }

    private func leave() {
        if let coverDismiss {
            coverDismiss()
        } else {
            dismiss()
        }
    }

    private func openFirstBook() {
        guard let volume = Catalogue.shelf.first, !opening else { return }
        opening = true
        Task {
            await board.moorFromShelf(volume)
            opening = false
            if board.lastRefusal == nil {
                leave()
            }
        }
    }
}
