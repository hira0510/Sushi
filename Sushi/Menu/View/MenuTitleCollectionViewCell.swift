//
//  MenuTitleCollectionViewCell.swift
//  Sushi
//
//  Created by admin on 2023/4/20.
//

import UIKit

class MenuTitleCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var bgView: RoundCornersView!
    @IBOutlet weak var mLabel: UILabel!
    static var nib: UINib {
        return UINib(nibName: "MenuTitleCollectionViewCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib() 
    }
     
    /// - Parameters:
    ///   - select: 是否選擇該menu
    func cellConfig(_ model: MenuModel, _ select: Bool) {
        mLabel.text = SuShiSingleton.share().getIsEng() ? model.titleEng: model.title
        bgView.backgroundColor = select ? UIColor(model.color): .white
    }
}
