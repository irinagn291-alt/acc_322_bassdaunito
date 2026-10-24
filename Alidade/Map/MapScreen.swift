import SwiftUI
import UIKit

/// MapScreen is the root. The map stays. Other destinations arrive as sheets.
struct MapScreen: View {
    @Binding var sheet: TableSheet?
    var placeholder: Bool

    @Environment(TableBoard.self) private var board
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pageDraft = 8
    @State private var logging = false
    @State private var sighting = false
    @State private var reloading = false
    @State private var opening = false
    @State private var pulse = 0

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.s12) {
                    header
                    if let note = board.loadNote {
                        noteBanner(note)
                    }
                    if placeholder || board.reading.presence == .slack || board.reading.presence == .charged {
                        liveColumn
                    } else if board.reading.presence == .blank {
                        emptyColumn
                    } else {
                        finishedColumn
                    }
                }
                .padding(.horizontal, Spacing.s16)
                .padding(.top, Spacing.s12)
                .padding(.bottom, Spacing.s24)
                .frame(maxWidth: .infinity, minHeight: proxy.size.height, alignment: .top)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(DesignTokens.bg.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            HStack(alignment: .firstTextBaseline, spacing: Spacing.s12) {
                Text("MAP")
                    .appFont(.caption)
                    .foregroundStyle(DesignTokens.muted)
                TimelineView(.everyMinute) { context in
                    DayKey.text(for: context.date)
                        .appFont(.mono)
                        .foregroundStyle(DesignTokens.ink)
                }
                Spacer(minLength: Spacing.s8)
            }
            ViewThatFits(in: .horizontal) {
                Text("Log pages, then sight the next stop.")
                    .appFont(.display)
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: true)
                Text("Log pages, then sight the next stop.")
                    .appFont(.title)
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            toolRow
        }
    }

    private var toolRow: some View {
        VStack(spacing: Spacing.s8) {
            HStack(spacing: Spacing.s8) {
                tool("Shelf", systemName: "books.vertical", next: .shelf)
                tool("Session", systemName: "square.and.pencil", next: .session)
                tool("Expedition", systemName: "map", next: .expedition)
            }
            HStack(spacing: Spacing.s8) {
                tool("Pace", systemName: "chart.bar", next: .pace)
                tool("Settings", systemName: "gearshape", next: .settings)
            }
        }
    }

    private var liveColumn: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            rail
            factStrip
            PhaseAnimator([false, true], trigger: pulse) { phase in
                PlaneHero(
                    reading: board.reading,
                    bookTitle: bookTitle,
                    pulse: pulse,
                    onShelf: { sheet = .shelf }
                )
                .scaleEffect(heroScale(phase))
                .opacity(heroOpacity(phase))
            } animation: { phase in
                if reduceMotion {
                    return Motion.fade
                }
                return phase ? Motion.commit : Motion.ease
            }
            .frame(maxWidth: .infinity)
            .frame(height: Spacing.s48 * 3)
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }

    private func heroScale(_ phase: Bool) -> CGFloat {
        if reduceMotion || !phase {
            return 1
        }
        return Motion.swell
    }

    private func heroOpacity(_ phase: Bool) -> CGFloat {
        if reduceMotion && phase {
            return Motion.fadeOpacity
        }
        return 1
    }

    private var rail: some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            Text(statusLine)
                .appFont(.body)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: Spacing.s8) {
                stepButton("Fewer pages", systemName: "minus", delta: -1)
                Text(pageDraft, format: .number)
                    .appFont(.mono)
                    .foregroundStyle(DesignTokens.ink)
                    .contentTransition(.numericText(value: Double(pageDraft)))
                    .animation(Motion.travel(reduceMotion), value: pageDraft)
                    .frame(maxWidth: .infinity)
                stepButton("More pages", systemName: "plus", delta: 1)
            }
            Button(action: logPages) {
                Text("Log")
            }
            .buttonStyle(FilledCapsuleStyle(role: logLeads ? .primary : .quiet, busy: logging))
            .disabled(!canLog || logging || sighting)
            Button(action: sightNow) {
                Text("Sight")
            }
            .buttonStyle(FilledCapsuleStyle(role: sightLeads ? .primary : .quiet, busy: sighting))
            .disabled(!sightLeads || sighting || logging)
        }
        .cardPlate()
    }

    private var factStrip: some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            Text(bookTitle)
                .appFont(.headline)
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            HStack(alignment: .firstTextBaseline, spacing: Spacing.s16) {
                VStack(alignment: .leading, spacing: Spacing.s4) {
                    Text("Drift")
                        .appFont(.caption)
                        .foregroundStyle(DesignTokens.muted)
                    Text(driftReadout)
                        .appFont(.mono)
                        .foregroundStyle(DesignTokens.ink)
                        .contentTransition(.numericText(value: board.reading.driftAngle))
                        .animation(Motion.travel(reduceMotion), value: board.reading.driftAngle)
                        .fixedSize(horizontal: true, vertical: true)
                }
                VStack(alignment: .leading, spacing: Spacing.s4) {
                    Text("Page pool")
                        .appFont(.caption)
                        .foregroundStyle(DesignTokens.muted)
                    Text("\(board.reading.chargeBalance) pages")
                        .appFont(.mono)
                        .foregroundStyle(DesignTokens.ink)
                        .contentTransition(.numericText(value: Double(board.reading.chargeBalance)))
                        .animation(Motion.travel(reduceMotion), value: board.reading.chargeBalance)
                        .fixedSize(horizontal: true, vertical: true)
                }
                Spacer(minLength: Spacing.s8)
            }
        }
        .cardPlate()
    }

    private var emptyColumn: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                    .fill(DesignTokens.surface)
                Image("ald_EmptyHome")
                    .resizable()
                    .scaledToFit()
                    .padding(Spacing.s16)
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                    .fill(.regularMaterial)
            }
            Text("No expedition yet.")
                .appFont(.display)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text("Open a book to start.")
                .appFont(.body)
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            if let refusal = board.lastRefusal {
                Text(RefusalCopy.line(refusal))
                    .appFont(.body)
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Button(action: openFirstBook) {
                Text("Open a book")
            }
            .buttonStyle(FilledCapsuleStyle(busy: opening))
            .disabled(opening)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var finishedColumn: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            Text("This expedition is finished.")
                .appFont(.display)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(bookTitle)
                .appFont(.body)
                .foregroundStyle(DesignTokens.muted)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Button(action: openFirstBook) {
                Text("Open a book")
            }
            .buttonStyle(FilledCapsuleStyle(busy: opening))
            .disabled(opening)
            factStrip
        }
    }

    private func noteBanner(_ note: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            Text(note)
                .appFont(.body)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                Task {
                    reloading = true
                    await board.reload()
                    reloading = false
                }
            } label: {
                Text("Retry")
            }
            .buttonStyle(FilledCapsuleStyle(busy: reloading))
            .disabled(reloading)
        }
        .cardPlate()
    }

    private func tool(_ title: String, systemName: String, next: TableSheet) -> some View {
        Button {
            sheet = next
        } label: {
            VStack(spacing: Spacing.s4) {
                Image(systemName: systemName)
                    .appFont(.headline)
                    .foregroundStyle(DesignTokens.ink)
                Text(title)
                    .appFont(.caption)
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, minHeight: Spacing.s48)
            .padding(.vertical, Spacing.s8)
            .background {
                RoundedRectangle(cornerRadius: Radius.chip, style: .continuous)
                    .fill(.regularMaterial)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PressStyle())
        .accessibilityLabel(title)
    }

    private func stepButton(_ title: String, systemName: String, delta: Int) -> some View {
        Button {
            let next = pageDraft + delta
            if next >= 1 && next <= 200 {
                pageDraft = next
            }
        } label: {
            Image(systemName: systemName)
                .appFont(.headline)
                .foregroundStyle(DesignTokens.ink)
                .frame(width: Spacing.s48, height: Spacing.s48)
                .background {
                    RoundedRectangle(cornerRadius: Radius.chip, style: .continuous)
                        .fill(DesignTokens.surface)
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(PressStyle())
        .accessibilityLabel(title)
    }

    private var bookTitle: String {
        board.reading.volumeTitle ?? "unknown"
    }

    private var sightLeads: Bool {
        board.reading.presence == .charged
    }

    private var logLeads: Bool {
        board.reading.canLog && !sightLeads
    }

    private var canLog: Bool {
        board.reading.canLog && pageDraft > 0
    }

    private var showsDrift: Bool {
        abs(board.reading.driftAngle) > 0.05 && board.reading.loggedPages > 0 && board.reading.stationCount > 0
    }

    private var driftReadout: String {
        let degrees = board.reading.driftAngle.formatted(.number.precision(.fractionLength(0...1)))
        return showsDrift ? "\(degrees)°" : "0°"
    }

    private var statusLine: String {
        if let refusal = board.lastRefusal {
            return RefusalCopy.line(refusal)
        }
        switch board.reading.presence {
        case .charged:
            return "Ready to sight."
        case .slack:
            return "Log pages, then sight."
        case .arrived:
            return "This expedition is finished."
        case .blank:
            return "Open a book."
        }
    }

    private func logPages() {
        guard canLog, !logging else { return }
        logging = true
        let pages = pageDraft
        Task {
            await board.log(pages: pages)
            logging = false
        }
    }

    private func sightNow() {
        guard sightLeads, !sighting else { return }
        sighting = true
        let before = board.reading.sightMarks
        Task {
            await board.sight()
            sighting = false
            if board.lastRefusal == nil, board.reading.sightMarks > before {
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                pulse += 1
            }
        }
    }

    private func openFirstBook() {
        guard let volume = Catalogue.shelf.first, !opening else { return }
        opening = true
        Task {
            await board.moorFromShelf(volume)
            opening = false
        }
    }
}
