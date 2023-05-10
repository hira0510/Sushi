//
//  SushiCollectionViewCell.swift
//  Sushi
//
//  Created by admin on 2023/4/20.
//

import UIKit
import Kingfisher

class SushiCollectionViewCell: BaseCollectionViewCell {

    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var mImageView: UIImageView!
    @IBOutlet weak var mLabel: UILabel!
    
    static var nib: UINib {
        return UINib(nibName: "SushiCollectionViewCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    } 

    func cellConfig(model: SushiModel, isSelect: Bool) {
        let isEng = SuShiSingleton.share().getIsEng()
        self.mLabel.text = isEng ? model.eng: model.title
        self.moneyLabel.text = isEng ? "$\(model.price)": "\(model.price)元"
        guard let url = URL(string: model.img) else { return }
        self.mImageView.kf.indicatorType = .activity
        self.mImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(0.5)), .loadDiskFileSynchronously])
        self.isSelected = isSelect
    }
}
