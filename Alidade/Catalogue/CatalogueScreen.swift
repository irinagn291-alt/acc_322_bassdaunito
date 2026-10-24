import SwiftUI

/// CatalogueScreen moors a shelf book or a typed title into a new expedition.
struct CatalogueScreen: View {
    @Environment(TableBoard.self) private var board
    @Environment(\.dismiss) private var dismiss
    @Environment(\.coverDismiss) private var coverDismiss
    @FocusState private var focus: MoorField?
    @State private var query = ""
    @State private var title = ""
    @State private var author = ""
    @State private var pages = ""
    @State private var adding = false
    @State private var mooring = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.s16) {
                searchField
                Text("SHELF")
                    .appFont(.caption)
                    .foregroundStyle(DesignTokens.muted)
                if matches.isEmpty {
                    emptyCopy
                } else {
                    VStack(spacing: Spacing.s8) {
                        ForEach(matches) { volume in
                            Button {
                                moor(volume)
                            } label: {
                                shelfRow(volume)
                            }
                            .buttonStyle(PressStyle())
                            .disabled(mooring)
                        }
                    }
                }
                addSection
            }
            .padding(Spacing.s16)
            .padding(.bottom, Spacing.s32)
        }
        .scrollDismissesKeyboard(.immediately)
        .background(DesignTokens.bg)
        .sheetChrome("Shelf")
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focus = nil }
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: Spacing.s8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(DesignTokens.muted)
                .accessibilityHidden(true)
            TextField("Title or author", text: $query)
                .appFont(.body)
                .foregroundStyle(DesignTokens.ink)
                .textInputAutocapitalization(.words)
                .submitLabel(.search)
            if !query.isEmpty {
                Button("Clear") { query = "" }
                    .appFont(.caption)
                    .foregroundStyle(DesignTokens.ink)
            }
        }
        .padding(.horizontal, Spacing.s12)
        .frame(minHeight: Spacing.s48)
        .background {
            RoundedRectangle(cornerRadius: Radius.chip, style: .continuous)
                .fill(DesignTokens.surface)
        }
    }

    private var emptyCopy: some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            Text("No book matches.")
                .appFont(.title)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text("Clear the search and try another title.")
                .appFont(.body)
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardPlate()
    }

    private var addSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            Button {
                adding.toggle()
                if !adding { focus = nil }
            } label: {
                HStack {
                    Text(adding ? "Hide new book" : "Add a book")
                        .appFont(.headline)
                        .foregroundStyle(DesignTokens.ink)
                    Spacer(minLength: Spacing.s8)
                    Image(systemName: adding ? "chevron.up" : "chevron.down")
                        .foregroundStyle(DesignTokens.muted)
                        .accessibilityHidden(true)
                }
                .frame(minHeight: Spacing.s48)
                .contentShape(Rectangle())
            }
            .buttonStyle(PressStyle())
            if adding {
                TextField("Title", text: $title)
                    .focused($focus, equals: .title)
                    .submitLabel(.next)
                    .onSubmit { focus = .author }
                    .appFont(.body)
                    .foregroundStyle(DesignTokens.ink)
                TextField("Author", text: $author)
                    .focused($focus, equals: .author)
                    .submitLabel(.next)
                    .onSubmit { focus = .pages }
                    .appFont(.body)
                    .foregroundStyle(DesignTokens.ink)
                TextField("Pages", text: $pages)
                    .focused($focus, equals: .pages)
                    .keyboardType(.decimalPad)
                    .appFont(.mono)
                    .foregroundStyle(DesignTokens.ink)
                if let fault {
                    Text(fault)
                        .appFont(.body)
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Button(action: addTyped) {
                    Text("Add book")
                }
                .buttonStyle(FilledCapsuleStyle(busy: mooring))
                .disabled(typedPages == nil || titleTrimmed.isEmpty || mooring)
            }
        }
        .cardPlate()
    }

    private func shelfRow(_ volume: Volume) -> some View {
        HStack(alignment: .center, spacing: Spacing.s8) {
            VStack(alignment: .leading, spacing: Spacing.s4) {
                Text(volume.title)
                    .appFont(.headline)
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Text(volume.author)
                    .appFont(.body)
                    .foregroundStyle(DesignTokens.muted)
                    .lineLimit(1)
            }
            Spacer(minLength: Spacing.s8)
            VStack(alignment: .trailing, spacing: Spacing.s4) {
                HStack(alignment: .firstTextBaseline, spacing: Spacing.s4) {
                    Text(volume.pageCount, format: .number)
                    Text("pages")
                }
                .appFont(.mono)
                .foregroundStyle(DesignTokens.ink)
                Text(isOpen(volume) ? "Open" : "Add")
                    .appFont(.caption)
                    .foregroundStyle(isOpen(volume) ? DesignTokens.accent : DesignTokens.ink)
            }
        }
        .padding(Spacing.s12)
        .frame(maxWidth: .infinity, minHeight: Spacing.s48, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                .fill(.regularMaterial)
        }
        .contentShape(Rectangle())
    }

    private var matches: [Volume] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return Catalogue.shelf }
        return Catalogue.shelf.filter {
            $0.title.localizedCaseInsensitiveContains(trimmed)
                || $0.author.localizedCaseInsensitiveContains(trimmed)
        }
    }

    private var titleTrimmed: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var typedPages: Int? {
        PageEntry.whole(pages)
    }

    private var fault: String? {
        if pages.trimmingCharacters(in: .whitespaces).isEmpty || typedPages != nil {
            return board.lastRefusal.map(RefusalCopy.line)
        }
        return "Enter a whole number above zero."
    }

    private func isOpen(_ volume: Volume) -> Bool {
        board.underway?.volumeID == volume.id
    }

    private func leave() {
        if let coverDismiss {
            coverDismiss()
        } else {
            dismiss()
        }
    }

    private func moor(_ volume: Volume) {
        guard !mooring else { return }
        mooring = true
        focus = nil
        Task {
            let before = board.archive.sorties.count
            await board.moorFromShelf(volume)
            mooring = false
            if board.lastRefusal == nil, board.archive.sorties.count > before {
                leave()
            }
        }
    }

    private func addTyped() {
        guard let count = typedPages, !titleTrimmed.isEmpty, !mooring else { return }
        mooring = true
        focus = nil
        let volume = Volume(
            id: UUID(),
            title: titleTrimmed,
            author: author.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Unknown" : author.trimmingCharacters(in: .whitespacesAndNewlines),
            pageCount: count
        )
        Task {
            let before = board.archive.sorties.count
            await board.open(volume: volume)
            mooring = false
            if board.lastRefusal == nil, board.archive.sorties.count > before {
                leave()
            }
        }
    }
}

private enum MoorField: Hashable {
    case title
    case author
    case pages
}
