//
//  MenuServiceView.swift
//  Sushi
//
//  Created by Hira on 2023/5/2.
//

import UIKit

class MenuServiceView: BaseView {
     
    @IBInspectable var bgColor: UIColor = .orange
    @IBInspectable var title: String = ""
    
    @IBOutlet weak var hintView: NGSCustomizableView!
    @IBOutlet weak var mButton: NGSCustomizableButton!
    
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibContent()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNibContent()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        commonInit()
    }
    
    private func commonInit() {
        mButton.setTitle(title, for: .normal)
        mButton.setTitle(title.toEng, for: .selected)
        mButton.BgNor = bgColor
    }
    
    public func updateUI(isHidden: Bool) {
        hintView.isHidden = !(SuShiSingleton.share().getIsAdmin() && !isHidden)
    }
}
