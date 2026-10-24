import SwiftUI

/// SheetChrome gives every sheet its own stack and a Close control.
struct SheetChrome: ViewModifier {
    var title: String

    @Environment(\.dismiss) private var dismiss
    @Environment(\.coverDismiss) private var coverDismiss

    func body(content: Content) -> some View {
        NavigationStack {
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            if let coverDismiss {
                                coverDismiss()
                            } else {
                                dismiss()
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(DesignTokens.ink)
                                .frame(width: Spacing.s48, height: Spacing.s48)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PressStyle())
                        .accessibilityLabel("Close")
                    }
                }
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbarBackground(.regularMaterial, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(DesignTokens.bg)
    }
}

extension View {
    func sheetChrome(_ title: String) -> some View {
        modifier(SheetChrome(title: title))
    }
}

private struct CoverDismissKey: EnvironmentKey {
    static let defaultValue: (@MainActor () -> Void)? = nil
}

extension EnvironmentValues {
    /// Set when a cover is the window root, so Close leaves that cover.
    var coverDismiss: (@MainActor () -> Void)? {
        get { self[CoverDismissKey.self] }
        set { self[CoverDismissKey.self] = newValue }
    }
}
