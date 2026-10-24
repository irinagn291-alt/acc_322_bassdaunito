import SwiftUI

/// SettingsScreen holds the intro, the reset, and the contact link.
struct SettingsScreen: View {
    @Environment(TableBoard.self) private var board
    @Environment(\.dismiss) private var dismiss
    @Environment(\.coverDismiss) private var coverDismiss
    @AppStorage("ald.wholeDegrees") private var wholeDegrees = false
    @State private var confirmReset = false
    @State private var resetting = false
    @State private var reloading = false

    private let contactURL = URL(string: "https://alidade-table.pro/contact-us")

    var body: some View {
        Form {
            if board.archive.sorties.isEmpty {
                Section {
                    Text("Nothing stored yet.")
                        .appFont(.body)
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                Section {
                    LabeledContent {
                        Text(board.stats.pagesLogged, format: .number)
                            .appFont(.mono)
                            .foregroundStyle(DesignTokens.ink)
                    } label: {
                        Text("Pages logged")
                            .appFont(.body)
                            .foregroundStyle(DesignTokens.ink)
                    }
                    LabeledContent {
                        Text(board.archive.volumes.count, format: .number)
                            .appFont(.mono)
                            .foregroundStyle(DesignTokens.ink)
                    } label: {
                        Text("Books")
                            .appFont(.body)
                            .foregroundStyle(DesignTokens.ink)
                    }
                } header: {
                    Text("ON THIS DEVICE")
                        .appFont(.caption)
                }
            }
            Section {
                Toggle("Whole degrees", isOn: $wholeDegrees)
                    .appFont(.body)
                    .foregroundStyle(DesignTokens.ink)
                    .frame(minHeight: Spacing.s48)
            } header: {
                Text("AIM")
                    .appFont(.caption)
            }
            Section {
                Button("Show intro again") {
                    Task {
                        await board.reopenIntro()
                        leave()
                    }
                }
                .appFont(.body)
                .foregroundStyle(DesignTokens.ink)
                .frame(minHeight: Spacing.s48)
                Button("Delete all data") {
                    confirmReset = true
                }
                .appFont(.body)
                .foregroundStyle(DesignTokens.ink)
                .frame(minHeight: Spacing.s48)
                .disabled(resetting)
            }
            Section {
                if let contactURL {
                    Link(destination: contactURL) {
                        HStack {
                            Text("Contact")
                                .appFont(.body)
                                .foregroundStyle(DesignTokens.ink)
                            Spacer(minLength: Spacing.s8)
                            Image(systemName: "arrow.up.right")
                                .foregroundStyle(DesignTokens.accent)
                                .frame(width: Spacing.s48, height: Spacing.s48)
                                .accessibilityHidden(true)
                        }
                        .contentShape(Rectangle())
                    }
                    .frame(minHeight: Spacing.s48)
                }
                Text("Everything stays on this device.")
                    .appFont(.body)
                    .foregroundStyle(DesignTokens.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let note = board.loadNote {
                Section {
                    Text(note)
                        .appFont(.body)
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Button("Retry") {
                        Task {
                            reloading = true
                            await board.reload()
                            reloading = false
                        }
                    }
                    .disabled(reloading)
                    .frame(minHeight: Spacing.s48)
                } header: {
                    Text("COULD NOT READ")
                        .appFont(.caption)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .listRowBackground(
            RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                .fill(.regularMaterial)
        )
        .background(DesignTokens.bg)
        .scrollDismissesKeyboard(.immediately)
        .sheetChrome("Settings")
        .confirmationDialog(
            "Delete every expedition on this device?",
            isPresented: $confirmReset,
            titleVisibility: .visible
        ) {
            Button("Delete all data", role: .destructive) {
                Task {
                    resetting = true
                    await board.resetAllData()
                    resetting = false
                    leave()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func leave() {
        if let coverDismiss {
            coverDismiss()
        } else {
            dismiss()
        }
    }
}
