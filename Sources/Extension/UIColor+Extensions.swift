import UIKit

extension UIColor {
    public convenience init(red: Int = 0xFF, green: Int = 0xFF, blue: Int = 0xFF, a: Int = 0xFF) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }

    public convenience init(hex: String?) {
        guard let hex
        else {
            self.init(white: 0.0, alpha: 0.0)
            return
        }

        let r, g, b, a: CGFloat
        var hexString = hex

        if hexString.hasPrefix("#") {
            hexString = hexString.replacingOccurrences(of: "#", with: "")
        }

        let scanner = Scanner(string: hexString)
        var hexNumber: UInt64 = 0

        switch hexString.count {
        // rgb with alpha 1.0
        case 6:
            guard scanner.scanHexInt64(&hexNumber)
            else {
                self.init(white: 0.0, alpha: 0.0)
                return
            }

            r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255
            g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255
            b = CGFloat(hexNumber & 0x0000FF) / 255
            a = 1.0
            self.init(red: r, green: g, blue: b, alpha: a)

        // rgba
        case 8:
            guard scanner.scanHexInt64(&hexNumber)
            else {
                self.init(white: 0.0, alpha: 0.0)
                return
            }

            r = CGFloat((hexNumber & 0xFF000000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00FF0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000FF00) >> 8) / 255
            a = CGFloat(hexNumber & 0x000000FF) / 255
            self.init(red: r, green: g, blue: b, alpha: a)

        default:
            self.init(white: 0.0, alpha: 0.0)
            return
        }
    }
}
