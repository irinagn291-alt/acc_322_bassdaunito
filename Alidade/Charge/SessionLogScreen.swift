import SwiftUI

/// SessionLogScreen is the page log. Logging fills the pool. Sight stays on the map.
struct SessionLogScreen: View {
    @Environment(TableBoard.self) private var board
    @Environment(\.dismiss) private var dismiss
    @Environment(\.coverDismiss) private var coverDismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var pagesFocused: Bool
    @State private var draft = ""
    @State private var logging = false
    @State private var opening = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.s16) {
                Image("ald_TwistHero")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: Spacing.s48 * 3)
                    .background(DesignTokens.surface)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
                    .clipped()
                    .accessibilityHidden(true)
                Text("Log pages, then sight.")
                    .appFont(.title)
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(statusLine)
                    .appFont(.body)
                    .foregroundStyle(DesignTokens.muted)
                    .fixedSize(horizontal: false, vertical: true)
                if board.latestSortie == nil {
                    Button(action: openFirstBook) {
                        Text("Open a book")
                    }
                    .buttonStyle(FilledCapsuleStyle(busy: opening))
                    .disabled(opening)
                } else {
                    field
                    Button(action: commit) {
                        Text("Log")
                    }
                    .buttonStyle(FilledCapsuleStyle(role: .primary, busy: logging))
                    .disabled(parsed == nil || logging || !board.reading.canLog)
                }
                if lines.isEmpty {
                    Text("No pages logged yet.")
                        .appFont(.body)
                        .foregroundStyle(DesignTokens.muted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .cardPlate()
                } else {
                    VStack(alignment: .leading, spacing: Spacing.s8) {
                        ForEach(lines) { line in
                            sessionRow(line)
                        }
                    }
                }
            }
            .padding(Spacing.s16)
            .padding(.bottom, Spacing.s24)
        }
        .scrollDismissesKeyboard(.immediately)
        .background(DesignTokens.bg)
        .sheetChrome("Session")
        .onAppear {
            if draft.isEmpty {
                draft = 8.formatted(.number)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { pagesFocused = false }
            }
        }
    }

    private var field: some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            Text("PAGES")
                .appFont(.caption)
                .foregroundStyle(DesignTokens.muted)
            TextField("Pages", text: $draft)
                .keyboardType(.decimalPad)
                .focused($pagesFocused)
                .appFont(.mono)
                .foregroundStyle(DesignTokens.ink)
                .frame(minHeight: Spacing.s48)
            if let fault {
                Text(fault)
                    .appFont(.body)
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .cardPlate()
    }

    private func sessionRow(_ line: SessionLine) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.s8) {
            VStack(alignment: .leading, spacing: Spacing.s4) {
                Text(line.book)
                    .appFont(.headline)
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(line.loggedAt, format: .dateTime.month(.abbreviated).day().hour().minute())
                    .appFont(.body)
                    .foregroundStyle(DesignTokens.muted)
            }
            Spacer(minLength: Spacing.s8)
            Text(line.pages, format: .number)
                .appFont(.mono)
                .foregroundStyle(DesignTokens.ink)
                .contentTransition(.numericText(value: Double(line.pages)))
                .animation(Motion.travel(reduceMotion), value: line.pages)
                .layoutPriority(1)
        }
        .cardPlate()
    }

    private var parsed: Int? {
        PageEntry.whole(draft)
    }

    private var fault: String? {
        if draft.trimmingCharacters(in: .whitespaces).isEmpty || parsed != nil {
            return nil
        }
        return "Enter a whole number above zero."
    }

    private var statusLine: String {
        if let refusal = board.lastRefusal {
            return RefusalCopy.line(refusal)
        }
        if board.reading.presence == .charged {
            return "Ready to sight."
        }
        return "Twenty pages, then sight on the map."
    }

    private var lines: [SessionLine] {
        board.archive.sorties.flatMap { sortie in
            let book = board.volume(for: sortie)?.title ?? "unknown"
            return sortie.sessions.map {
                SessionLine(id: $0.id, pages: $0.pages, loggedAt: $0.loggedAt, book: book)
            }
        }
        .sorted { $0.loggedAt > $1.loggedAt }
    }

    private func commit() {
        guard let pages = parsed, !logging else { return }
        logging = true
        pagesFocused = false
        Task {
            await board.log(pages: pages)
            logging = false
        }
    }

    private func openFirstBook() {
        guard let volume = Catalogue.shelf.first, !opening else { return }
        opening = true
        Task {
            await board.moorFromShelf(volume)
            opening = false
            if board.lastRefusal == nil {
                if let coverDismiss {
                    coverDismiss()
                } else {
                    dismiss()
                }
            }
        }
    }
}

private struct SessionLine: Identifiable {
    var id: UUID
    var pages: Int
    var loggedAt: Date
    var book: String
}
