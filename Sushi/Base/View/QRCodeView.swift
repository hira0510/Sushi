//
//  QRCodeView.swift
//  Sushi
//
//  Created by Hira on 2023/5/31.
//

import UIKit
import RxCocoa

class QRCodeView: BaseView {

    @IBOutlet weak var removeBtn: UIButton! {
        didSet {
            removeBtn.rx.tap.subscribe { [weak self] event in
                guard let `self` = self else { return }
                self.removeFromSuperview()
            }.disposed(by: bag)
        }
    }
    @IBOutlet weak var qrcodeImageView: UIImageView! {
        didSet {
            let singleton = SuShiSingleton.share()
            let shopNum = singleton.getAccount()
            let table = singleton.getPassword()
            let string = "Sushi://login?shopNum=\(shopNum)&table=\(table)"
            self.qrcodeImageView.generateQRCode(from: string)
        }
    }

    /// 轉重新整理Layout
    override func layoutSubviews() {
        self.frame = UIScreen.main.bounds
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    private func commonInit() {
        loadNibContent()
    }
}
