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
    func requestSuc()
}

enum AddSushiVcType {
    case add
    case edit
}

class AddSushiViewModel: BaseViewModel {
    
    public var editModel: (menu: String, data: SushiModel?) = (menu: "", data: nil)
    public var menuStrAry: [MenuStrModel] = []
    public weak var delegate: AddSushiVcProtocol?
    
    var mType: AddSushiVcType = .add
    var mName: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    var mNameEng: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    var mPrice: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    var mImage: BehaviorRelay<UIImage> = BehaviorRelay<UIImage>(value: UIImage(named: "noImg")!)
    var mTempEditImage: BehaviorRelay<UIImage> = BehaviorRelay<UIImage>(value: UIImage(named: "noImg")!)
    
    let stringPickerAdapter = RxPickerViewStringAdapter<[String]>(
        components: [],
        numberOfComponents: { _,_,_  in 1 },
        numberOfRowsInComponent: { (_, _, items, _) -> Int in
            return items.count},
        titleForRow: { (_, _, items, row, _) -> String? in
            return items[row]}
    )
}
