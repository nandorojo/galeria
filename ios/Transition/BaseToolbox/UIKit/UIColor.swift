#if canImport(UIKit)
import UIKit

extension UIColor {
    public convenience init(hexString: String) {
        let r, g, b, a: CGFloat

        let scanner = Scanner(string: hexString)
        _ = scanner.scanCharacters(from: CharacterSet(charactersIn: "#"))
        var hexNumber: UInt64 = 0
        scanner.scanHexInt64(&hexNumber)
        if hexString.length > 7 {
            r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            a = CGFloat(hexNumber & 0x000000ff) / 255

            self.init(red: r, green: g, blue: b, alpha: a)
        } else if hexString.length >= 6 {
            r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
            g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
            b = CGFloat(hexNumber & 0x0000ff) / 255

            self.init(red: r, green: g, blue: b, alpha: 1)
        } else {
            r = CGFloat((hexNumber & 0xF00) >> 8) / 15
            g = CGFloat((hexNumber & 0x0F0) >> 4) / 15
            b = CGFloat(hexNumber & 0x00F) / 15
            self.init(red: r, green: g, blue: b, alpha: 1)
        }
    }

    public convenience init(dark: UIColor, light: UIColor, elevatedDark: UIColor? = nil, elevatedLight: UIColor? = nil) {
        self.init { trait in
#if os(tvOS)
            if trait.userInterfaceStyle == .dark {
                return dark
            } else {
                return light
            }
            #else
            if trait.userInterfaceLevel == .elevated {
                if trait.userInterfaceStyle == .dark {
                    return elevatedDark ?? dark
                } else {
                    return elevatedLight ?? light
                }
            } else {
                if trait.userInterfaceStyle == .dark {
                    return dark
                } else {
                    return light
                }
            }
            #endif
        }
    }

    public var lightMode: UIColor {
        resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
    }

    public var darkMode: UIColor {
        resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
    }

    public var isWhite: Bool {
        hexString == UIColor.white.hexString
    }

    public var inverted: UIColor {
        UIColor(dark: lightMode, light: darkMode)
    }

    public var alpha: CGFloat {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return a
    }

    public var hexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0

        return String(format: "#%06x", rgb)
    }

    public var hexStringWithAlpha: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        if a < 1.0 {
            let rgba: Int = (Int)(r * 255) << 24 | (Int)(g * 255) << 16 | (Int)(b * 255) << 8 | (Int)(a * 255) << 0
            return String(format: "#%08x", rgba)
        } else {
            let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
            return String(format: "#%06x", rgb)
        }
    }

    public func lighter(amount: CGFloat = 0.2) -> UIColor {
        return mixWithColor(UIColor.white, amount: amount)
    }

    public func darker(amount: CGFloat = 0.2) -> UIColor {
        return mixWithColor(UIColor.black, amount: amount)
    }

    public func mixWithColor(_ color: UIColor, amount: CGFloat = 0.25) -> UIColor {
        var r1: CGFloat = 0
        var g1: CGFloat = 0
        var b1: CGFloat = 0
        var alpha1: CGFloat = 0
        var r2: CGFloat = 0
        var g2: CGFloat = 0
        var b2: CGFloat = 0
        var alpha2: CGFloat = 0

        getRed(&r1, green: &g1, blue: &b1, alpha: &alpha1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &alpha2)
        return UIColor(
            red: r1 * (1.0 - amount) + r2 * amount,
            green: g1 * (1.0 - amount) + g2 * amount,
            blue: b1 * (1.0 - amount) + b2 * amount,
            alpha: alpha1)
    }

    public func dynamicMixWithColor(_ color: UIColor, amount: CGFloat = 0.25) -> UIColor {
        UIColor { trait in
            if trait.userInterfaceStyle == .dark {
                return self.darkMode.mixWithColor(color.darkMode, amount: amount)
            } else {
                return self.lightMode.mixWithColor(color.lightMode, amount: amount)
            }
        }
    }

    public var brightness: CGFloat {
        let originalCGColor = cgColor

        // Now we need to convert it to the RGB colorspace. UIColor.white / UIColor.black are greyscale and not RGB.
        // If you don't do this then you will crash when accessing components index 2 below when evaluating greyscale colors.
        let RGBCGColor = originalCGColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil)
        guard let components = RGBCGColor?.components else {
            return 0
        }
        guard components.count >= 3 else {
            return 0
        }

        return ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000
    }

    public func isLight(threshold: CGFloat = 0.7) -> Bool {
        return brightness > threshold
    }
}
#endif
