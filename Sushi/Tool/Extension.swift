//
//  Extension.swift
//  Sushi
//
//  Created by admin on 2023/4/20.
//

import UIKit

extension UIStoryboard {

    static func loadLoginVC() -> LoginViewController {
        let vc = LoginViewController(nibName: "LoginViewController", bundle: nil)
        return vc
    }

    static func loadAddVC(menu: [MenuStrModel]) -> AddSushiViewController {
        let vc = AddSushiViewController(nibName: "AddSushiViewController", bundle: nil)
        vc.menuStrAry = menu
        return vc
    }
}
extension UIColor {
    convenience init(_ netHex: Int, alpha: CGFloat = 1.0) {

        let red: CGFloat = CGFloat((netHex >> 16) & 0xff) / 255.0
        let green: CGFloat = CGFloat((netHex >> 8) & 0xff) / 255.0
        let blue: CGFloat = CGFloat(netHex & 0xff) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    public convenience init?(hexString: String) {
        let r, g, b: CGFloat
        var cString: String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            self.init()
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        b = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1)
        return
    }
}

extension Int {
    var toDouble: Double {
        return Double(self)
    }
    var toStr: String {
        return String(self)
    }
}

extension Double {
    var toStr: String {
        return String(self)
    }
}

extension String {
    var toDouble: Double {
        if let double = Double(self) {
            return double
        }
        return 0
    }

    var toInt: Int {
        if let int = Int(self) {
            return int
        }
        return 0
    }
}

extension UIButton {

    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        let colorImage = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { _ in
            color.setFill()
            UIBezierPath(rect: CGRect(x: 0, y: 0, width: 1, height: 1)).fill()
        }
        setBackgroundImage(colorImage, for: state)
    }
}

extension UIView {

    //UIView 動畫速度
    static let ANIMATION_DURATION_EXIT = 0.5
    static let ANIMATION_DURATION_SLOW = 0.6
    static let ANIMATION_DURATION_FAST = 0.2

    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    @IBInspectable var shadowColor: UIColor? {
        get {
            return UIColor(cgColor: layer.shadowColor!)
        }
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }
    @IBInspectable var shadowOpacity: Float {
        get {
            return self.layer.shadowOpacity
        }
        set {
            self.layer.shadowOpacity = newValue
        }
    }

    /// The shadow offset. Defaults to (0, -3). Animatable.
    @IBInspectable var shadowOffset: CGSize {
        get {
            return self.layer.shadowOffset
        }
        set {
            self.layer.shadowOffset = newValue
        }
    }

    /// The blur radius used to create the shadow. Defaults to 3. Animatable.
    @IBInspectable var shadowRadius: Double {
        get {
            return Double(self.layer.shadowRadius)
        }
        set {
            self.layer.shadowRadius = CGFloat(newValue)
        }
    }

}
