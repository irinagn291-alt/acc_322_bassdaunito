import SwiftUI

/// SPEC section 7. The only place these hex values live — reach colours
/// and the font family through here. Keep this file and its values.
enum DesignTokens {
    /// #2C1B2C
    static let bg = Color(red: 0.172549, green: 0.105882, blue: 0.172549)
    static let bgHex = "#2C1B2C"
    /// #3D2934
    static let surface = Color(red: 0.239216, green: 0.160784, blue: 0.203922)
    static let surfaceHex = "#3D2934"
    /// #F4F1F4
    static let ink = Color(red: 0.956863, green: 0.945098, blue: 0.956863)
    static let inkHex = "#F4F1F4"
    /// #DA6CA7
    static let accent = Color(red: 0.854902, green: 0.423529, blue: 0.654902)
    static let accentHex = "#DA6CA7"
    /// #BFB0BF
    static let muted = Color(red: 0.749020, green: 0.690196, blue: 0.749020)
    static let mutedHex = "#BFB0BF"
    static let fontFamily = "Iowan Old Style"
}

/// Spacing is the only point scale. Views use these cases and nothing else.
enum Spacing {
    static let s4: CGFloat = 4
    static let s8: CGFloat = 8
    static let s12: CGFloat = 12
    static let s16: CGFloat = 16
    static let s20: CGFloat = 20
    static let s24: CGFloat = 24
    static let s32: CGFloat = 32
    static let s40: CGFloat = 40
    static let s48: CGFloat = 48
}

/// Section 7.4. Cards and sheets use `card`. Chips and badges use `chip`.
enum Radius {
    static let card: CGFloat = 14
    static let chip: CGFloat = 6
}

/// One spring for a successful sight. Everything else eases out. Reduce Motion fades.
enum Motion {
    static let commit = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let ease = Animation.easeOut(duration: 0.22)
    static let fade = Animation.easeOut(duration: 0.2)
    static let press: CGFloat = 0.96
    static let swell: CGFloat = 1.03
    static let fadeOpacity: CGFloat = 0.72

    static func travel(_ reduceMotion: Bool) -> Animation {
        reduceMotion ? fade : commit
    }
}

/// Six type steps. Bold and roman PostScript names stay here.
enum TypeScale {
    static let display: CGFloat = 34
    static let title: CGFloat = 24
    static let headline: CGFloat = 20
    static let body: CGFloat = 17
    static let caption: CGFloat = 15
    static let mono: CGFloat = 15
    static let tight: CGFloat = -0.6
    static let spaced: CGFloat = 1.6
    static let roman = "IowanOldStyle-Roman"
    static let bold = "IowanOldStyle-Bold"

    enum Step {
        case display, title, headline, body, caption, mono
    }
}
