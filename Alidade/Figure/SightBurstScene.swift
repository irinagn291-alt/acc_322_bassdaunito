import SpriteKit
import UIKit

/// SightBurstScene is the single particle accent, played when a sight commits.
final class SightBurstScene: SKScene {
    private var texture: SKTexture?

    override init(size: CGSize) {
        super.init(size: size)
        scaleMode = .resizeFill
        backgroundColor = .clear
    }

    override init() {
        super.init(size: CGSize(width: 320, height: 320))
        scaleMode = .resizeFill
        backgroundColor = .clear
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        backgroundColor = .clear
        view.allowsTransparency = true
        view.isOpaque = false
        view.backgroundColor = .clear
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        // The burst is built in code. A storyboard decoder is a programmer error.
        fatalError("SightBurstScene does not decode from a coder.")
    }

    @MainActor
    func burst() {
        let node = SKEmitterNode()
        node.particleTexture = dotTexture()
        node.particleBirthRate = 120
        node.numParticlesToEmit = 28
        node.particleLifetime = 0.55
        node.particleSpeed = 90
        node.particleSpeedRange = 40
        node.particleAlpha = 0.9
        node.particleAlphaSpeed = -1.6
        node.particleScale = 0.45
        node.particleScaleRange = 0.2
        node.particleColor = UIColor(DesignTokens.accent)
        node.particleColorBlendFactor = 1
        node.emissionAngleRange = .pi * 2
        node.position = CGPoint(x: size.width * 0.5, y: size.height * 0.46)
        addChild(node)
        node.run(.sequence([
            .wait(forDuration: 0.8),
            .removeFromParent()
        ]))
    }

    @MainActor
    private func dotTexture() -> SKTexture {
        if let texture {
            return texture
        }
        let side = Spacing.s8
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: side, height: side))
        let image = renderer.image { context in
            UIColor(DesignTokens.ink).setFill()
            context.cgContext.fillEllipse(in: CGRect(x: 0, y: 0, width: side, height: side))
        }
        let made = SKTexture(image: image)
        texture = made
        return made
    }
}
