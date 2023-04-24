//
//  SushiCollectionViewCell.swift
//  Sushi
//
//  Created by admin on 2023/4/20.
//

import UIKit
import Kingfisher

class SushiCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mImageView: UIImageView!
    @IBOutlet weak var mLabel: UILabel!
    
    static var nib: UINib {
        return UINib(nibName: "SushiCollectionViewCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func cellConfig(model: SushiModel) {
        self.mLabel.text = model.title
        guard let url = URL(string: model.img) else { return }
        self.mImageView.kf.setImage(with: url)
    }
}
