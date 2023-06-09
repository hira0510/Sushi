//
//  OrderListCollectionViewCell.swift
//  Sushi
//
//  Created by Hira on 2023/4/26.
//

import UIKit 
import RxSwift
import RxCocoa

protocol OrderListCellProtocol: AnyObject {
    func clickRemoveItem(_ model: SushiModel?)
    func clickOpenBtn(_ isToOpen: Bool)
    func clickOrderBtn()
}

class OrderListCollectionViewCell: BaseCollectionViewCell {
    
    @IBOutlet weak var removeBtn: NGSCustomizableButton! {
        didSet {
            removeBtn.rx.tap.subscribe { [weak self] _ in
                guard let `self` = self else { return }
                self.delegate?.clickRemoveItem(self.mModel)
            }.disposed(by: bag)
        }
    }
    @IBOutlet weak var mImageView: NGSCustomizableImageView!
    
    private weak var delegate: OrderListCellProtocol?
    private var mModel: SushiModel?
    
    static var nib: UINib {
        return UINib(nibName: "OrderListCollectionViewCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func cellConfig(model: SushiModel, delegate: OrderListCellProtocol?) {
        self.mModel = model
        self.delegate = delegate
        self.mImageView.loadImage(url: model.img, options: [.transition(.fade(0.5)), .loadDiskFileSynchronously])
    }
}
