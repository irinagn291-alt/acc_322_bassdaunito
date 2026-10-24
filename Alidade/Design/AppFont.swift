import SwiftUI

/// AppFont is the only type ramp. Six steps, scaled with Dynamic Type.
struct AppFont: ViewModifier {
    var step: TypeScale.Step

    @ScaledMetric(relativeTo: .largeTitle) private var displaySize = TypeScale.display
    @ScaledMetric(relativeTo: .title2) private var titleSize = TypeScale.title
    @ScaledMetric(relativeTo: .headline) private var headlineSize = TypeScale.headline
    @ScaledMetric(relativeTo: .body) private var bodySize = TypeScale.body
    @ScaledMetric(relativeTo: .footnote) private var captionSize = TypeScale.caption
    @ScaledMetric(relativeTo: .body) private var monoSize = TypeScale.mono

    func body(content: Content) -> some View {
        switch step {
        case .display, .title:
            content.font(font).tracking(TypeScale.tight)
        case .caption:
            content.font(font).tracking(TypeScale.spaced)
        case .headline, .body, .mono:
            content.font(font)
        }
    }

    private var font: Font {
        switch step {
        case .display:
            Font.custom(TypeScale.bold, size: displaySize)
        case .title:
            Font.custom(TypeScale.bold, size: titleSize)
        case .headline:
            Font.custom(TypeScale.bold, size: headlineSize)
        case .body:
            Font.custom(TypeScale.roman, size: bodySize)
        case .caption:
            Font.custom(TypeScale.roman, size: captionSize)
        case .mono:
            Font.custom(TypeScale.roman, size: monoSize).monospacedDigit()
        }
    }
}

extension View {
    func appFont(_ step: TypeScale.Step) -> some View {
        modifier(AppFont(step: step))
    }
}

/// CardPlate is the material surface for a grouped block.
struct CardPlate: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(Spacing.s12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                    .fill(.regularMaterial)
            }
    }
}

extension View {
    func cardPlate() -> some View {
        modifier(CardPlate())
    }
}
