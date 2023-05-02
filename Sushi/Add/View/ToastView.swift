//
//  ToastView.swift
//

import UIKit

enum ToastType {
    case autoRemove
    case sending
}

class ToastView: UIView {

    lazy var finishedToast: (() -> ()) = { }

    internal let label = UILabel()
    internal var text: String = ""
    
    lazy var mImageView: UIImageView = {
        let img = UIImageView()
        img.clipsToBounds = false
        img.layer.cornerRadius = 10
        switch type {
        default:
            img.backgroundColor = UIColor(0x000000, alpha: 0.9)
            let width: CGFloat = self.frame.width - 220
            let x: CGFloat = width / 2
            let height: CGFloat = self.frame.height - 80
            let y: CGFloat = height / 2
            img.frame = CGRect(x: x, y: y, width: 220, height: 80)
            return img
        }
    }()
    
    private var initType: ToastType?
    internal var type: ToastType? {
        didSet {
            self.addSubview(mImageView)
            label.frame = mImageView.frame
            switch type {
            case .sending:
                setupLabel(delay: 0, font: UIFont(name: "PingFangTC-Regular", size: 16.0)!, foregroundColor: UIColor.white)
            default:
                setupLabel(delay: 2, font: UIFont(name: "PingFangTC-Regular", size: 16.0)!, foregroundColor: UIColor.white)
            }
            self.addSubview(label)
        }
    }
    
    // init 設定type好像會有問題，延遲到這邊才設定
    override func layoutSubviews(){
        super.layoutSubviews()
        if let initType = initType {
            type = initType
        }
    }

    init(frame: CGRect, text: String) {
        super.init(frame: frame)
        self.text = text
    }
    
    convenience init(frame :CGRect?, text: String, type: ToastType?) {
        self.init(frame: frame ?? CGRect.zero, text: text)
        initType = type
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /// 消失
    private func remove(delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.removeFromSuperview()
            self.finishedToast()
        }
    }
    private func isiPhoneXDevice() -> Bool {
        return UIScreen.main.bounds.height >= 812
    }
    
    /// 通用設定Label屬性
    private func setupLabel(delay: TimeInterval, font: UIFont, foregroundColor: UIColor) {
        if delay != 0 {
            remove(delay: delay)
        }
        label.numberOfLines = 2
        label.attributedText = NSAttributedString(string: text, attributes: [
                .font: font,
                .foregroundColor: foregroundColor
        ])
        label.textAlignment = .center
    }
}
