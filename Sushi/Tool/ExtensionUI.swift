//
//  ExtensionUI.swift
//  Sushi
//
//  Created by Hira on 2023/4/28.
//

import UIKit
import RxCocoa
import RxSwift


extension UIApplication {
    static var safeArea: UIEdgeInsets {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return scene?.windows.first?.safeAreaInsets ?? .zero
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

extension UIButton {
    func setBackgroundColor(_ color: UIColor?, for state: UIControl.State) {
        let color = color ?? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        let colorImage = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { _ in
          color.setFill()
          UIBezierPath(rect: CGRect(x: 0, y: 0, width: 1, height: 1)).fill()
        }
        setBackgroundImage(colorImage, for: state)
    }
}

extension UIView {

    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
//
//    @IBInspectable var borderWidth: CGFloat {
//        get {
//            return layer.borderWidth
//        }
//        set {
//            layer.borderWidth = newValue
//        }
//    }
//
//    @IBInspectable var borderColor: UIColor? {
//        get {
//            return UIColor(cgColor: layer.borderColor!)
//        }
//        set {
//            layer.borderColor = newValue?.cgColor
//        }
//    }
//    @IBInspectable var shadowColor: UIColor? {
//        get {
//            return UIColor(cgColor: layer.shadowColor!)
//        }
//        set {
//            layer.shadowColor = newValue?.cgColor
//        }
//    }
//    @IBInspectable var shadowOpacity: Float {
//        get {
//            return self.layer.shadowOpacity
//        }
//        set {
//            self.layer.shadowOpacity = newValue
//        }
//    }
//
//    /// The shadow offset. Defaults to (0, -3). Animatable.
//    @IBInspectable var shadowOffset: CGSize {
//        get {
//            return self.layer.shadowOffset
//        }
//        set {
//            self.layer.shadowOffset = newValue
//        }
//    }
//
//    /// The blur radius used to create the shadow. Defaults to 3. Animatable.
//    @IBInspectable var shadowRadius: Double {
//        get {
//            return Double(self.layer.shadowRadius)
//        }
//        set {
//            self.layer.shadowRadius = CGFloat(newValue)
//        }
//    }
}
