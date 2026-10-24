import SwiftUI

/// StatsScreen is the pace readout: pages, sights, and finished expeditions.
struct StatsScreen: View {
    @Environment(TableBoard.self) private var board
    @Environment(\.dismiss) private var dismiss
    @Environment(\.coverDismiss) private var coverDismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var opening = false

    var body: some View {
        Group {
            if board.stats.pagesLogged == 0 && board.stats.totalSights == 0 && board.archive.sorties.isEmpty {
                empty
            } else {
                filled
            }
        }
        .background(DesignTokens.bg)
        .sheetChrome("Pace")
    }

    private var filled: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.s16) {
                VStack(alignment: .leading, spacing: Spacing.s12) {
                    Text("Reading pace")
                        .appFont(.headline)
                        .foregroundStyle(DesignTokens.ink)
                    metric("Pages logged", value: "\(board.stats.pagesLogged) pages")
                    metric("Sights taken", value: "\(board.stats.totalSights) sights")
                    metric("Expeditions finished", value: "\(board.stats.completedSorties) expeditions")
                }
                .cardPlate()
                Text("FINISHED EXPEDITIONS")
                    .appFont(.caption)
                    .foregroundStyle(DesignTokens.muted)
                if finished.isEmpty {
                    Text("None finished yet. The open book is still on the map.")
                        .appFont(.body)
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                        .cardPlate()
                } else {
                    VStack(spacing: Spacing.s8) {
                        ForEach(finished) { sortie in
                            finishedRow(sortie)
                        }
                    }
                }
                if let note = board.loadNote {
                    VStack(alignment: .leading, spacing: Spacing.s8) {
                        Text(note)
                            .appFont(.body)
                            .foregroundStyle(DesignTokens.ink)
                            .fixedSize(horizontal: false, vertical: true)
                        Button("Retry") {
                            Task { await board.reload() }
                        }
                        .buttonStyle(FilledCapsuleStyle())
                    }
                    .cardPlate()
                }
                Text(paceSentence)
                    .appFont(.body)
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(Spacing.s16)
            .padding(.bottom, Spacing.s24)
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: nextTap) {
                Text(nextTitle)
            }
            .buttonStyle(FilledCapsuleStyle(busy: opening))
            .disabled(opening)
            .padding(.horizontal, Spacing.s16)
            .padding(.top, Spacing.s8)
            .padding(.bottom, Spacing.s12)
            .background(DesignTokens.bg)
        }
    }

    private func metric(_ label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s4) {
            Text(label)
                .appFont(.caption)
                .foregroundStyle(DesignTokens.muted)
            Text(value)
                .appFont(.title)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .animation(Motion.travel(reduceMotion), value: value)
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            Text("No pace yet.")
                .appFont(.title)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text("Open a book and log pages.")
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

    private func finishedRow(_ sortie: Sortie) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s4) {
            Text(board.volume(for: sortie)?.title ?? "Finished book")
                .appFont(.headline)
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            HStack(alignment: .firstTextBaseline, spacing: Spacing.s4) {
                Text(sortie.sightMarks.count, format: .number)
                Text("sights,")
                Text(sortie.charge.loggedPages, format: .number)
                Text("pages")
            }
            .appFont(.body)
            .foregroundStyle(DesignTokens.muted)
            .fixedSize(horizontal: false, vertical: true)
        }
        .cardPlate()
    }

    private var finished: [Sortie] {
        board.archive.sorties.filter { !$0.isUnderway }
    }

    private var paceSentence: String {
        if let title = board.underway.flatMap({ board.volume(for: $0)?.title }) {
            return "\(title) is still open. Continue it from the map."
        }
        return "Every expedition on this device is finished. Open another book."
    }

    private var nextTitle: String {
        if board.underway != nil {
            return "Continue the expedition"
        }
        return "Open a book"
    }

    private func nextTap() {
        if board.underway != nil {
            leave()
        } else {
            openFirstBook()
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
