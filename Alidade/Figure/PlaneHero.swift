import SpriteKit
import SwiftUI

/// PlaneHero is the one custom surface: duotone terrain, the marker, and the aim rule.
struct PlaneHero: View {
    var reading: MapReading
    var bookTitle: String
    var pulse: Int
    var onShelf: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @GestureState private var dragX: CGFloat = 0
    @State private var aim: Double = 0
    @State private var burst = SightBurstScene()

    var body: some View {
        ZStack {
            terrain
            Canvas { context, size in
                drawBoard(context: context, size: size)
            }
            .allowsHitTesting(false)
            if pulse > 0 {
                SpriteView(scene: burst, options: [.allowsTransparency])
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
        }
        .overlay { aimRule }
        .overlay(alignment: .top) {
            HStack(alignment: .center, spacing: Spacing.s8) {
                VolumeChip(title: bookTitle, action: onShelf)
                Spacer(minLength: Spacing.s8)
                PhaseBadge(presence: reading.presence)
            }
            .padding(Spacing.s12)
        }
        .overlay(alignment: .bottomLeading) {
            aimReadout
                .padding(Spacing.s12)
        }
        .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .accessibilityElement(children: .contain)
        .onChange(of: pulse) { _, new in
            guard new > 0, !reduceMotion else { return }
            burst.backgroundColor = .clear
            burst.burst()
        }
        .onChange(of: reading.driftAngle) { _, new in
            if abs(dragX) < 0.5 {
                aim = showsDrift ? new : 0
            }
        }
    }

    private var terrain: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 12.0, paused: reduceMotion)) { timeline in
            let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
            Rectangle()
                .fill(DesignTokens.bg)
                .colorEffect(
                    ShaderLibrary.planeTable(
                        .float(Float(time)),
                        .color(DesignTokens.bg),
                        .color(DesignTokens.surface),
                        .color(DesignTokens.accent)
                    )
                )
        }
        .accessibilityHidden(true)
    }

    private var aimRule: some View {
        RoundedRectangle(cornerRadius: Radius.chip, style: .continuous)
            .fill(DesignTokens.accent)
            .frame(height: Spacing.s8)
            .padding(.horizontal, Spacing.s32)
            .frame(maxWidth: .infinity)
            .frame(height: Spacing.s48)
            .contentShape(Rectangle())
            .rotationEffect(.degrees(shownAim))
            .gesture(drag)
            .accessibilityLabel("Aim")
            .accessibilityValue(Text(shownAim, format: .number.precision(.fractionLength(0...1))))
            .accessibilityHint("Drag to turn.")
    }

    private var aimReadout: some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.s8) {
            Text("AIM")
                .appFont(.caption)
                .foregroundStyle(DesignTokens.ink)
            Text(shownAim, format: .number.precision(.fractionLength(0...1)))
                .appFont(.mono)
                .foregroundStyle(DesignTokens.ink)
                .contentTransition(.numericText(value: shownAim))
                .animation(Motion.travel(reduceMotion), value: shownAim)
        }
        .padding(.horizontal, Spacing.s12)
        .frame(minHeight: Spacing.s48)
        .background {
            RoundedRectangle(cornerRadius: Radius.chip, style: .continuous)
                .fill(.regularMaterial)
        }
        .accessibilityHidden(true)
    }

    private var drag: some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($dragX) { value, state, _ in
                state = value.translation.width
            }
            .onEnded { value in
                aim += Double(value.predictedEndTranslation.width) / Spacing.s4
            }
    }

    private var shownAim: Double {
        aim + Double(dragX) / Spacing.s4
    }

    private var showsDrift: Bool {
        abs(reading.driftAngle) > 0.05
            && reading.loggedPages > 0
            && reading.stationCount > 0
            && (reading.presence == .slack || reading.presence == .charged)
    }

    private func drawBoard(context: GraphicsContext, size: CGSize) {
        let inset = Spacing.s24
        let y = size.height * 0.62
        let start = CGPoint(x: inset, y: y)
        let end = CGPoint(x: size.width - inset, y: y)
        var track = Path()
        track.move(to: start)
        track.addLine(to: end)
        context.stroke(track, with: .color(DesignTokens.muted), style: StrokeStyle(lineWidth: Spacing.s8, lineCap: .round))

        guard reading.stationCount > 0 else { return }
        let span = end.x - start.x
        let stations = reading.stationCount
        let figureIndex = min(max(reading.figureIndex, 0), stations - 1)
        let figureT = stations == 1 ? 0 : Double(figureIndex) / Double(stations - 1)
        let figureX = start.x + span * figureT
        var walked = Path()
        walked.move(to: start)
        walked.addLine(to: CGPoint(x: figureX, y: y))
        context.stroke(walked, with: .color(DesignTokens.accent), style: StrokeStyle(lineWidth: Spacing.s8, lineCap: .round))

        for index in 0..<stations {
            let t = stations == 1 ? 0 : Double(index) / Double(stations - 1)
            let point = CGPoint(x: start.x + span * t, y: y)
            let rect = CGRect(x: point.x - Spacing.s4, y: point.y - Spacing.s4, width: Spacing.s8, height: Spacing.s8)
            let dot = Path(ellipseIn: rect)
            let seen = index < reading.figureIndex
            context.fill(dot, with: .color(seen ? DesignTokens.accent : DesignTokens.ink))
        }

        if showsDrift {
            let pageT = min(max(reading.routeX, 0), 1)
            let pageX = start.x + span * pageT
            var gap = Path()
            gap.move(to: CGPoint(x: figureX, y: y))
            gap.addLine(to: CGPoint(x: pageX, y: y - Spacing.s32))
            context.stroke(gap, with: .color(DesignTokens.accent), style: StrokeStyle(lineWidth: Spacing.s4, lineCap: .round, dash: [Spacing.s4, Spacing.s4]))
        }

        let marker = CGRect(
            x: figureX - Spacing.s16,
            y: y - Spacing.s40,
            width: Spacing.s32,
            height: Spacing.s40
        )
        var pole = Path()
        pole.move(to: CGPoint(x: marker.midX, y: marker.maxY))
        pole.addLine(to: CGPoint(x: marker.minX, y: marker.minY + Spacing.s12))
        pole.addLine(to: CGPoint(x: marker.maxX, y: marker.minY + Spacing.s12))
        pole.closeSubpath()
        context.fill(pole, with: .color(DesignTokens.ink))
        let resolved = context.resolve(Image("ald_FigureMarkerClay"))
        context.draw(resolved, in: marker)
    }
}

/// VolumeChip opens the shelf. It is a button because it looks tappable.
struct VolumeChip: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .appFont(.headline)
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(1)
                .truncationMode(.tail)
                .padding(.horizontal, Spacing.s12)
                .frame(minHeight: Spacing.s48)
                .frame(maxWidth: Spacing.s48 * 4)
                .background {
                    RoundedRectangle(cornerRadius: Radius.chip, style: .continuous)
                        .fill(.regularMaterial)
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(PressStyle())
        .accessibilityLabel("Shelf")
        .accessibilityValue(title)
    }
}

/// PhaseBadge names the fold in words. Colour is not the only signal.
struct PhaseBadge: View {
    var presence: TablePresence

    var body: some View {
        HStack(spacing: Spacing.s8) {
            Circle()
                .fill(presence == .charged ? DesignTokens.accent : DesignTokens.muted)
                .frame(width: Spacing.s8, height: Spacing.s8)
                .accessibilityHidden(true)
            Text(label)
                .appFont(.caption)
                .foregroundStyle(DesignTokens.ink)
        }
        .padding(.horizontal, Spacing.s12)
        .frame(minHeight: Spacing.s48)
        .background {
            RoundedRectangle(cornerRadius: Radius.chip, style: .continuous)
                .fill(.regularMaterial)
        }
        .accessibilityElement(children: .combine)
    }

    private var label: String {
        switch presence {
        case .blank:
            "EMPTY"
        case .slack:
            "SHORT"
        case .charged:
            "READY"
        case .arrived:
            "DONE"
        }
    }
}
