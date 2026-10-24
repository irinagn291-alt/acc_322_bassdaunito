import SwiftUI

/// OnboardingView explains the job, then marks the chart ready to open.
struct OnboardingView: View {
    @Environment(TableBoard.self) private var board
    @State private var page = 0
    @State private var saving = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            HStack {
                Text(page + 1, format: .number)
                    .appFont(.mono)
                    .foregroundStyle(DesignTokens.muted)
                Text("of")
                    .appFont(.caption)
                    .foregroundStyle(DesignTokens.muted)
                Text(3, format: .number)
                    .appFont(.mono)
                    .foregroundStyle(DesignTokens.muted)
                Spacer(minLength: Spacing.s8)
                Button(action: finish) {
                    Text("Skip")
                        .appFont(.headline)
                        .foregroundStyle(DesignTokens.ink)
                        .frame(minWidth: Spacing.s48, minHeight: Spacing.s48)
                        .padding(.horizontal, Spacing.s12)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressStyle())
                .disabled(saving)
            }
            ZStack {
                RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                    .fill(DesignTokens.surface)
                Image(artName)
                    .resizable()
                    .scaledToFit()
                    .padding(Spacing.s16)
                    .accessibilityLabel(artLabel)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                    .fill(.regularMaterial)
            }
            Text(headline)
                .appFont(.display)
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Text(detail)
                .appFont(.body)
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            Button(action: advance) {
                Text(page == 2 ? "Start" : "Next")
            }
            .buttonStyle(FilledCapsuleStyle(busy: saving))
            .disabled(saving)
        }
        .padding(Spacing.s16)
        .padding(.bottom, Spacing.s12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(DesignTokens.bg.ignoresSafeArea())
    }

    private var artName: String {
        switch page {
        case 0: "ald_Onboarding1"
        case 1: "ald_Onboarding2"
        default: "ald_Onboarding3"
        }
    }

    private var artLabel: String {
        switch page {
        case 0: "A book drawn as a line of stops"
        case 1: "Sighting the next stop"
        default: "Stops gathered on the map"
        }
    }

    private var headline: String {
        switch page {
        case 0: "Log pages on a map."
        case 1: "Sight the next stop."
        default: "Keep the gap honest."
        }
    }

    private var detail: String {
        switch page {
        case 0: "A book becomes a line of stops."
        case 1: "Twenty pages in the pool, then sight."
        default: "Logging ahead of the marker shows drift."
        }
    }

    private func advance() {
        if page < 2 {
            page += 1
        } else {
            finish()
        }
    }

    private func finish() {
        guard !saving else { return }
        saving = true
        Task {
            await board.completeOnboarding()
            saving = false
        }
    }
}
