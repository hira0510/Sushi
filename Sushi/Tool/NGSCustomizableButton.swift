//
//  NGSCustomizableButton.swift
//
//  Created by  on 2022/9/16.
//

import UIKit

@IBDesignable
class NGSCustomizableButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
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
    /// 一般邊框顏色
    @IBInspectable var BorderNor: UIColor? {
        didSet {
            updateBorderColors()
        }
    }
    /// 選擇邊框顏色
    @IBInspectable var BorderSel: UIColor? {
        didSet {
            updateBorderColors()
        }
    }
    /// 禁用邊框顏色
    @IBInspectable var BorderDis: UIColor? {
        didSet {
            updateBorderColors()
        }
    }
    /// 一般邊框結束顏色
    @IBInspectable var BorderNorEnd: UIColor? {
        didSet {
            updateBorderColors()
        }
    }
    /// 選擇邊框結束顏色
    @IBInspectable var BorderSelEnd: UIColor? {
        didSet {
            updateBorderColors()
        }
    }
    /// 禁用邊框結束顏色
    @IBInspectable var BorderDisEnd: UIColor? {
        didSet {
            updateBorderColors()
        }
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
    /// 一般背景顏色
    private var BgNor: UIColor?
    /// 選擇背景顏色
    @IBInspectable var BgSel: UIColor? {
        didSet {
            updateColors()
        }
    }
    /// 禁用背景顏色
    @IBInspectable var BgDis: UIColor? {
        didSet {
            updateColors()
        }
    }
    /// 一般背景結束顏色
    @IBInspectable var BgNorEnd: UIColor? {
        didSet {
            updateColors()
        }
    }
    /// 選擇背景結束顏色
    @IBInspectable var BgSelEnd: UIColor? {
        didSet {
            updateColors()
        }
    }
    /// 禁用背景結束顏色
    @IBInspectable var BgDisEnd: UIColor? {
        didSet {
            updateColors()
        }
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


    // MARK: - Tint顏色
    /// 一般icon顏色
    private var norTint: UIColor?
    /// 選擇icon顏色
    @IBInspectable var selTint: UIColor? {
        didSet {
            setupTintColor()
        }
    }
    /// 禁用icon顏色
    @IBInspectable var disTint: UIColor? {
        didSet {
            setupTintColor()
        }
    }


    // MARK: - 陰影
    /// 一般陰影顏色
    @IBInspectable var ShadowNorColors: UIColor? {
        didSet {
            setupShadowColor()
        }
    }
    /// 選擇陰影顏色
    @IBInspectable var ShadowSelColors: UIColor? {
        didSet {
            setupShadowColor()
        }
    }
    /// 禁用陰影顏色
    @IBInspectable var ShadowDisColors: UIColor? {
        didSet {
            setupShadowColor()
        }
    }
    /// 陰影透明度 0~1(通常設1)
    @IBInspectable var ShadowOpacitys: Float = 0.0 {
        didSet {
            self.layer.shadowOpacity = ShadowOpacitys
        }
    }
    /// 陰影範圍 數值越高越模糊分散(依設計稿Blur直接填)
    @IBInspectable var ShadowBlur: Double = 0.0 {
        didSet {
            self.layer.shadowRadius = CGFloat(ShadowBlur / 2)
        }
    }
    /// 陰影方向 下右為正,上左為負
    @IBInspectable var ShadowOffsets: CGSize = CGSize(width: 0, height: 0) {
        didSet {
            self.layer.shadowOffset = ShadowOffsets
        }
    }


    // MARK: - 文字陰影
    /// 文字陰影顏色
    @IBInspectable var LblSdColor: UIColor = .clear {
        didSet {
            self.titleLabel?.layer.shadowColor = LblSdColor.cgColor
        }
    }
    /// 文字陰影透明度 0~1
    @IBInspectable var LblSdOpacity: Float = 0.0 {
        didSet {
            self.titleLabel?.layer.shadowOpacity = LblSdOpacity
        }
    }
    /// 文字陰影範圍 數值越高越模糊分散
    @IBInspectable var LblSdBlur: Double = 0.0 {
        didSet {
            self.titleLabel?.layer.shadowRadius = CGFloat(LblSdBlur / 2)
        }
    }
    /// 文字陰影方向 下右為正,上左為負
    @IBInspectable var LblSdOffset: CGSize = CGSize(width: 0, height: 0) {
        didSet {
            self.titleLabel?.layer.shadowOffset = LblSdOffset
        }
    }


    // MARK: - 按鈕遮罩
    /// 是否要有按下時的遮罩
    @IBInspectable var PressMask: Bool = true

    /// 按下時的遮罩顏色
    @IBInspectable var PressMaskColor: UIColor = UIColor.black.withAlphaComponent(0.2)



    // MARK: - 私有
    /**
     第一次初始化
     */
    private var firstInit: Bool = false
    /**
     按下去的遮罩Layer
     */
    private var pressMaskLayer = CALayer()
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
    private var gradientLayer = CAGradientLayer()



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
        if BgNor == nil {
            BgNor = self.backgroundColor
        }

        var startColor: UIColor?
        var endColor: UIColor?
        if self.state == .normal || self.state == State(rawValue: 1) {
            startColor = BgNor
            endColor = BgNorEnd
        } else if self.state == .selected || self.state == State(rawValue: 5) {
            startColor = BgSel
            endColor = BgSelEnd
        } else if self.state == .disabled {
            startColor = BgDis
            endColor = BgDisEnd
        }
        let startStatusColor = startColor ?? BgNor ?? UIColor.clear
        let endStatusColor = endColor ?? BgNorEnd ?? startStatusColor

        gradientLayer.colors = [startStatusColor.cgColor, endStatusColor.cgColor]
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
        var startColor: UIColor?
        var endColor: UIColor?
        if self.state == .normal || self.state == State(rawValue: 1) {
            startColor = BorderNor
            endColor = BorderNorEnd
        } else if self.state == .selected || self.state == State(rawValue: 5) {
            startColor = BorderSel
            endColor = BorderSelEnd
        } else if self.state == .disabled {
            startColor = BorderDis
            endColor = BorderDisEnd
        }

        let startStatusColor = startColor ?? BorderNor ?? .clear
        let endStatusColor = endColor ?? BorderNorEnd ?? startStatusColor
        borderGradientLayer.colors = [startStatusColor.cgColor, endStatusColor.cgColor]
    }
    
    /// 設置icon顏色
    func setupTintColor() {
        if norTint == nil {
            norTint = self.tintColor
        }
        var color: UIColor?
        if self.state == .normal || self.state == State(rawValue: 1) {
            color = norTint
        } else if self.state == .selected || self.state == State(rawValue: 5) {
            color = selTint
        } else if self.state == .disabled {
            color = disTint
        }
        let statusColor = color ?? norTint ?? .clear
        self.tintColor = statusColor
    }

    /// 設置陰影顏色
    func setupShadowColor() {
        var color: UIColor?
        if self.state == .normal || self.state == State(rawValue: 1) {
            color = ShadowNorColors
        } else if self.state == .selected || self.state == State(rawValue: 5) {
            color = ShadowSelColors
        } else if self.state == .disabled {
            color = ShadowDisColors
        }
        let statusColor = color ?? ShadowNorColors ?? .clear
        self.layer.shadowColor = statusColor.cgColor
    }

    /// 添加陰影
    private func addShadowLayer() {
        self.layer.shadowPath = roundCornersMask.path
    }

    /// 添加圓角形狀
    private func addCornerRatioMask() {
        let roundRatios: CGFloat = RoundRatio / 2.0
        let cornerRadii = RoundValue == 0 ? self.bounds.height * roundRatios : CGFloat(RoundValue)

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
        gradientLayer.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
        gradientLayer.mask = roundCornersMask
        gradientLayer.zPosition = -1
        self.layer.insertSublayer(gradientLayer, at: 0)
    }

    /// 添加邊框
    private func addGradientBorder() {
        guard BorderWidths > 0 else { return }
        updateBorder()
        gradientLayer.addSublayer(borderGradientLayer)
    }
    
    /// 更新邊框範圍
    private func updateBorder() {
        borderGradientLayer.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
        borderLayer.path = roundCornersMask.path
        borderLayer.lineWidth = BorderWidths * 2
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.white.cgColor
        borderGradientLayer.mask = borderLayer
    }

    /// 添加按下時的遮罩
    private func addPressMask() {
        guard PressMask else { return }
        pressMaskLayer.backgroundColor = PressMaskColor.cgColor
        pressMaskLayer.isHidden = true
        updatePreMask()
        self.layer.addSublayer(pressMaskLayer)
    }
    
    /// 更新遮罩範圍
    func updatePreMask() {
        guard PressMask else { return }
        pressMaskLayer.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
        let layer = CAShapeLayer()
        layer.path = roundCornersMask.path
        pressMaskLayer.mask = layer
    }

    /// 添加按下時的遮罩方法
    private func addMaskTarget() {
        guard PressMask else { return }
        //按下放開
        self.addTarget(self, action: #selector(unpressed), for: .touchUpInside)
        //按下
        self.addTarget(self, action: #selector(press), for: .touchDown)
        //按住後手指離開
        self.addTarget(self, action: #selector(unpressed), for: .touchDragExit)
    }
    
    /// 旋轉螢幕時更新UI
    func orientUpdateSize() {
        addCornerRatioMask()
        addShadowLayer()
        updateBorder()
        updatePreMask()
        gradientLayer.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if let _ = object as? NGSCustomizableButton {
            guard let old = change?[.oldKey] as? Int, old == 1 else { return }
            if keyPath == "highlighted" {
                setupTintColor()
                updateColors()
                updateBorderColors()
                setupShadowColor()
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        orientUpdateSize()

        //第一次初始化
        if !firstInit {
            self.addObserver(self, forKeyPath: "highlighted", options: [.new, .old], context: nil)
            self.setImage(self.image(for: .normal), for: State(rawValue: 1))
            self.setImage(self.image(for: .selected), for: State(rawValue: 5))
            self.setTitle(self.title(for: .normal), for: State(rawValue: 1))
            self.setTitle(self.title(for: .selected), for: State(rawValue: 5))
            self.setTitleColor(self.titleColor(for: .normal), for: State(rawValue: 1))
            self.setTitleColor(self.titleColor(for: .selected), for: State(rawValue: 5))
//            addCornerRatioMask()
            addGradientBg()
            addShadowLayer()
            addGradientBorder()
            addPressMask()
            addMaskTarget()
            firstInit = true
        }
        
        self.setTitle(self.title(for: .normal), for: State(rawValue: 1))
        self.setTitle(self.title(for: .selected), for: State(rawValue: 5))
        self.setTitleColor(self.titleColor(for: .normal), for: State(rawValue: 1))
        self.setTitleColor(self.titleColor(for: .selected), for: State(rawValue: 5))
        updatePoints()
//        updateLocations()
        updateColors()
        updateBorderPoints()
        updateBorderColors()
        setupShadowColor()
        setupTintColor()
    }

    @objc private func press() {
        guard PressMask else { return }
        pressMaskLayer.isHidden = false
        self.isHighlighted = false
    }

    @objc private func unpressed() {
        guard PressMask else { return }
        pressMaskLayer.isHidden = true
        self.isHighlighted = false
    }
}
