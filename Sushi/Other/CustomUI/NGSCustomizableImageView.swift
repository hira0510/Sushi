//
//  NGSCustomizableImageView.swift
//
//  Created by  on 2022/9/16.
//

import UIKit

@IBDesignable
class NGSCustomizableImageView: UIImageView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - 圓角
    /// 左上角圓角
    @IBInspectable var LeftTop: Bool = false
    /// 左下角圓角
    @IBInspectable var LeftBotton: Bool = false
    /// 右上角圓角
    @IBInspectable var RightTop: Bool = false
    /// 右下角圓角
    @IBInspectable var RightBottom: Bool = false
    /// 圓角比例 0~1, 預設1代表正圓形
    @IBInspectable var RoundRatio: CGFloat = 1
    /// 圓角數值
    @IBInspectable var RoundValue: Int = 0

    // MARK: - Border邊框
    /// 邊框寬度, 要大於0才會有邊框效果
    @IBInspectable var BorderWidths: CGFloat = 0
    /// 邊框顏色(漸層起始顏色)
    @IBInspectable var BorderColors: UIColor? {
        didSet { updateBorderColors() }
    }
    /// 邊框漸層結束顏色
    @IBInspectable var BorderEndColor: UIColor? {
        didSet { updateBorderColors() }
    }
    /// 邊框漸層顏色方向 true:橫向 false:直向
    @IBInspectable var BorderHorizontalMode: Bool = false {
        didSet { updateBorderPoints() }
    }
    /// 邊框漸層顏色方向 是否要斜的
    @IBInspectable var BorderDiagonalMode: Bool = false {
        didSet { updateBorderPoints() }
    }

    // MARK: - Background背景顏色
    /// 背景漸層起始顏色
    private var BgColor: UIColor?
    /// 背景漸層結束顏色
    @IBInspectable var BgEndColor: UIColor? {
        didSet { updateColors() }
    }
    /// 背景漸層顏色方向 true:橫向 false:直向
    @IBInspectable var BgHorizontalMode: Bool = false {
        didSet { updatePoints() }
    }
    /// 背景漸層顏色方向 是否要斜的
    @IBInspectable var BgDiagonalMode: Bool = false {
        didSet { updatePoints() }
    }
    //    /// 背景漸層起始位置
    //    @IBInspectable var startLocation: Double = 0.05 {
    //        didSet { updateLocations() }
    //    }
    //    /// 背景漸層結束位置
    //    @IBInspectable var endLocation: Double = 0.95 {
    //        didSet { updateLocations() }
    //    }


    // MARK: - 陰影
    /// 陰影顏色
    @IBInspectable var ShadowColors: UIColor = .clear {
        didSet {
            self.layer.shadowColor = ShadowColors.cgColor
        }
    }
    /// 陰影透明度 0~1(通常設1)
    @IBInspectable var ShadowOpacitys: Float = 0.0 {
        didSet {
            self.layer.shadowOpacity = ShadowOpacitys
        }
    }
    /// 陰影範圍 數值越高越模糊分散(依設計稿Blur直接填)
    @IBInspectable var ShadowBlurs: Double = 0.0 {
        didSet {
            self.layer.shadowRadius = CGFloat(ShadowBlurs / 2)
        }
    }
    /// 陰影方向 下右為正,上左為負
    @IBInspectable var ShadowOffsets: CGSize = CGSize(width: 0, height: 0) {
        didSet {
            self.layer.shadowOffset = ShadowOffsets
        }
    }



    // MARK: - 私有
    /**
     第一次初始化
     */
    private var firstInit: Bool = false
    /**
     邊框形狀Layer
     */
    private var borderLayer = CAShapeLayer()
    /**
     邊框的顏色Layer
     */
    private var borderGradientLayer = CAGradientLayer()
    /**
     圓角的遮罩Layer
     */
    private var roundCornersMask = CAShapeLayer()
    /**
     背景顏色的遮罩Layer
     */
    var gradientLayer = CAGradientLayer()



    // MARK: - Func
    private func updatePoints() {
        if BgHorizontalMode {
            gradientLayer.startPoint = BgDiagonalMode ? CGPoint(x: 1, y: 0) : CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = BgDiagonalMode ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = BgDiagonalMode ? CGPoint(x: 0, y: 0) : CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint = BgDiagonalMode ? CGPoint(x: 1, y: 1) : CGPoint(x: 0.5, y: 1)
        }
    }

//    private func updateLocations() {
//        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
//    }

    private func updateColors() {
        if BgColor == nil {
            BgColor = self.backgroundColor
        }
        let startColor = BgColor ?? UIColor.clear
        let endColor = BgEndColor ?? startColor
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        self.backgroundColor = .clear
    }

    private func updateBorderPoints() {
        if BorderHorizontalMode {
            borderGradientLayer.startPoint = BorderDiagonalMode ? CGPoint(x: 1, y: 0) : CGPoint(x: 0, y: 0.5)
            borderGradientLayer.endPoint = BorderDiagonalMode ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0.5)
        } else {
            borderGradientLayer.startPoint = BorderDiagonalMode ? CGPoint(x: 0, y: 0) : CGPoint(x: 0.5, y: 0)
            borderGradientLayer.endPoint = BorderDiagonalMode ? CGPoint(x: 1, y: 1) : CGPoint(x: 0.5, y: 1)
        }
    }

    private func updateBorderColors() {
        let startColor = BorderColors ?? .clear
        let end = BorderEndColor ?? startColor
        borderGradientLayer.colors = [startColor.cgColor, end.cgColor]
    }

    /// 添加圓角形狀
    private func addCornerRatioMask() {
        let roundRatios: CGFloat = RoundRatio / 2.0
        let cornerRadii = RoundValue == 0 ? self.bounds.height * roundRatios: CGFloat(RoundValue)

        var RoundingCorners: UInt = 0

        if LeftTop {
            RoundingCorners = RoundingCorners | UIRectCorner.topLeft.rawValue
        }

        if LeftBotton {
            RoundingCorners = RoundingCorners | UIRectCorner.bottomLeft.rawValue
        }

        if RightTop {
            RoundingCorners = RoundingCorners | UIRectCorner.topRight.rawValue
        }

        if RightBottom {
            RoundingCorners = RoundingCorners | UIRectCorner.bottomRight.rawValue
        }
        roundCornersMask.path = UIBezierPath(roundedRect: self.bounds,
            byRoundingCorners: UIRectCorner.init(rawValue: RoundingCorners),
            cornerRadii: CGSize(width: cornerRadii, height: cornerRadii)).cgPath
    }

    /// 添加背景色
    private func addGradientBg() {
        gradientLayer.frame = CGRect(origin: CGPoint.zero, size: self.bounds.size)
        gradientLayer.mask = roundCornersMask
        gradientLayer.zPosition = -1
        self.layer.insertSublayer(gradientLayer, at: 0)
    }

    /// 添加邊框
    private func addGradientBorder() {
        guard BorderWidths > 0 else { return }
        borderGradientLayer.frame = CGRect(origin: CGPoint.zero, size: self.bounds.size)
        borderLayer.path = roundCornersMask.path
        borderLayer.lineWidth = BorderWidths * 2
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.white.cgColor
        borderGradientLayer.mask = borderLayer
        gradientLayer.addSublayer(borderGradientLayer)
    }
    
    /// 旋轉螢幕時更新UI
    private func orientUpdateSize() {
        addCornerRatioMask()
        borderGradientLayer.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
        gradientLayer.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        orientUpdateSize()
        //第一次初始化
        if !firstInit {
            addCornerRatioMask()
            addGradientBg()
            addGradientBorder()

            firstInit = true
        }

        updatePoints()
//        updateLocations()
        updateColors()
        updateBorderPoints()
        updateBorderColors()
    }
}
