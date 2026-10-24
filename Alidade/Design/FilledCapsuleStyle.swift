import SwiftUI

/// FilledCapsuleStyle is the primary control. Accent when it is the live verb.
struct FilledCapsuleStyle: ButtonStyle {
    enum Role {
        case primary
        case quiet
    }

    var role: Role = .primary
    var busy: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        FilledCapsuleLabel(configuration: configuration, role: role, busy: busy)
    }
}

/// PressStyle is the pressed scale for icon and row controls.
struct PressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        PressLabel(configuration: configuration)
    }
}

private struct FilledCapsuleLabel: View {
    let configuration: ButtonStyleConfiguration
    var role: FilledCapsuleStyle.Role
    var busy: Bool

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            configuration.label
                .appFont(.headline)
                .opacity(busy ? 0 : 1)
            if busy {
                ProgressView()
                    .tint(DesignTokens.ink)
            }
        }
        .foregroundStyle(isEnabled ? DesignTokens.ink : DesignTokens.muted)
        .frame(maxWidth: .infinity)
        .frame(minHeight: Spacing.s48)
        .background {
            Capsule().fill(fill)
        }
        .contentShape(Capsule())
        .scaleEffect(scale)
        .opacity(pressedFade)
        .animation(reduceMotion ? Motion.fade : Motion.ease, value: configuration.isPressed)
    }

    private var fill: Color {
        if isEnabled && role == .primary {
            return DesignTokens.accent
        }
        return DesignTokens.surface
    }

    private var scale: CGFloat {
        if reduceMotion || !configuration.isPressed || !isEnabled {
            return 1
        }
        return Motion.press
    }

    private var pressedFade: CGFloat {
        if reduceMotion && configuration.isPressed && isEnabled {
            return Motion.fadeOpacity
        }
        return 1
    }
}

private struct PressLabel: View {
    let configuration: ButtonStyleConfiguration

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        configuration.label
            .scaleEffect(scale)
            .opacity(pressedFade)
            .animation(reduceMotion ? Motion.fade : Motion.ease, value: configuration.isPressed)
    }

    private var scale: CGFloat {
        if reduceMotion || !configuration.isPressed || !isEnabled {
            return 1
        }
        return Motion.press
    }

    private var pressedFade: CGFloat {
        if reduceMotion && configuration.isPressed && isEnabled {
            return Motion.fadeOpacity
        }
        return 1
    }
}
