//
//  MenuInfoView.swift
//  Sushi
//
//  Created by admin on 2023/4/20.
//

import UIKit

@IBDesignable
class MenuInfoView: UIView, NibOwnerLoadable {
    
    @IBInspectable var numColor: UIColor = .black
    @IBInspectable var bgColor: UIColor = .orange
    @IBInspectable var title: String = ""
    @IBInspectable var num: String = "0"
    @IBInspectable var unit: String = ""
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    
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
    
    private func commonInit() {
        titleLabel.text = title
        unitLabel.text = unit
        numLabel.text = num
        numLabel.textColor = numColor
        self.backgroundColor = bgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        commonInit()
    }
}

