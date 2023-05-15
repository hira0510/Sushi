//
//  SushiLinearCollectionViewCell.swift
//  Sushi
//
//  Created by Hira on 2023/5/8.
//

import UIKit

class SushiLinearCollectionViewCell: BaseCollectionViewCell {
    
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var mImageView: UIImageView!
    @IBOutlet weak var mLabel: UILabel!
    @IBOutlet weak var mSubLabel: UILabel!
    
    override var isSelected: Bool {
        didSet {
            if !isSelected {
                self.backgroundColor = .black
            }
        }
    }

    static var nib: UINib {
        return UINib(nibName: "SushiLinearCollectionViewCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func cellConfig(model: SushiModel, isSelect: Bool) {
        let isEng = SuShiSingleton.share().getIsEng()
        self.mLabel.text = isEng ? model.eng: model.title
        self.mSubLabel.text = isEng ? model.title: model.eng
        self.moneyLabel.text = isEng ? "$\(model.price)": "\(model.price)元"
        
        self.mImageView.loadImage(url: model.img, options: [.transition(.fade(0.5)), .loadDiskFileSynchronously]) 
        self.isSelected = isSelect
    }
}
