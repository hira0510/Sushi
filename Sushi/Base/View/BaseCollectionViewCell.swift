//
//  BaseCollectionViewCell.swift
//  Sushi
//
//  Created by Hira on 2023/5/9.
//

import UIKit
import RxSwift
import RxCocoa

class BaseCollectionViewCell: UICollectionViewCell {
    
    internal lazy var bag: DisposeBag! = {
        return DisposeBag()
    }()
    
    override var isSelected: Bool{
        didSet {
        }
    }
    
    func isSelectChangeBg(_ isSelect: Bool) {
        isSelected = isSelect
        self.backgroundColor = isSelect ? .gray: .black
    }
}
