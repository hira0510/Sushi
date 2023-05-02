//
//  SushiCollectionViewCell.swift
//  Sushi
//
//  Created by admin on 2023/4/20.
//

import UIKit
import Kingfisher

class SushiCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var mImageView: UIImageView!
    @IBOutlet weak var mLabel: UILabel!
    
    static var nib: UINib {
        return UINib(nibName: "SushiCollectionViewCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override var isSelected: Bool {
        didSet {
            if !isSelected {
                self.backgroundColor = .black
            }
        }
    }

    func cellConfig(model: SushiModel) {
        let isEng = SuShiSingleton.share().getIsEng()
        self.mLabel.text = isEng ? model.titleEng: model.title
        self.moneyLabel.text = isEng ? "$\(model.money)": "\(model.money)元"
        guard let url = URL(string: model.img) else { return }
        self.mImageView.kf.indicatorType = .activity
        self.mImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(0.5)), .loadDiskFileSynchronously])
    }
}
