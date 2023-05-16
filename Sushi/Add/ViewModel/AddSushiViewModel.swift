//
//  AddSushiViewModel.swift
//  Sushi
//
//  Created by admin on 2023/4/21.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

protocol AddSushiVcProtocol: AnyObject {
    func requestSuc(_ menuName: String)
}

enum AddSushiVcType {
    case add
    case edit(_ index: Int = 0)
    
    var index: Int {
        switch self {
        case .add: return -1
        case .edit(let index): return index
        }
    }
    
    static func == (lhs: AddSushiVcType, rhs: AddSushiVcType) -> Bool {
        return lhs.index == rhs.index
    }
}

class AddSushiViewModel: BaseViewModel {
    
    public var editModel: (menu: String, data: SushiModel?) = (menu: "", data: nil)
    public var menuStrAry: [MenuStrModel] = []
    public var mType: AddSushiVcType = .add
    public weak var delegate: AddSushiVcProtocol?
    
    var mName: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    var mNameEng: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    var mPrice: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    var mSize: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    var mImage: BehaviorRelay<UIImage> = BehaviorRelay<UIImage>(value: UIImage(named: "noImg")!)
    var mTempEditImage: BehaviorRelay<UIImage> = BehaviorRelay<UIImage>(value: UIImage(named: "noImg")!)
    let sizeModel = ["1x1", "2x1", "2x2"]
    
    let stringPickerAdapter = RxPickerViewStringAdapter<[String]>(
        components: [],
        numberOfComponents: { _,_,_  in 1 },
        numberOfRowsInComponent: { (_, _, items, _) -> Int in
            return items.count},
        titleForRow: { (_, _, items, row, _) -> String? in
            return items[row]}
    )
    
    func toSushiModel(_ img: String) -> SushiModel {
        return SushiModel(title: mName.value, eng: mNameEng.value, img: img, price: mPrice.value, size: mSize.value)
    }
}
