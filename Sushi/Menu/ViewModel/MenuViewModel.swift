//
//  MenuViewModel.swift
//  Sushi
//
//  Created by admin on 2023/4/20.
//

import UIKit
import RxCocoa
import RxSwift

class MenuViewModel: BaseViewModel {
    
    var orient: UIDeviceOrientation = .unknown
    var sushiCollectionFrame: BehaviorRelay<CGRect> = BehaviorRelay<CGRect>(value: .zero)
    var menuCollectionFrame: BehaviorRelay<CGRect> = BehaviorRelay<CGRect>(value: .zero)
    
    var isNotEdit: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: true)
    var orderIsOpen: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: true)
    
    var selectItem: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)
    var menuModel: BehaviorRelay<[MenuModel]> = BehaviorRelay<[MenuModel]>(value: [])
    var orderModel: BehaviorRelay<[SushiModel]> = BehaviorRelay<[SushiModel]>(value: [])
    var recordModel: BehaviorRelay<[SushiModel]> = BehaviorRelay<[SushiModel]>(value: [])
    
    var orderTimeStr: BehaviorRelay<String> = BehaviorRelay<String>(value: "0")

    func getHSpace(_ type: CollectionViewType) -> CGFloat {
        return type == .menu ? 5 : 10
    }

    func getWSpace(_ type: CollectionViewType) -> CGFloat {
        return type == .menu ? 5 : 10
    }

    func getColumn() -> Int {
        switch orient {
        case .landscapeLeft, .landscapeRight: return 3
        case .portrait, .portraitUpsideDown: return 2
        default:
            self.orient = GlobalUtil.isPortrait() ? .portrait: .landscapeLeft
            return getColumn()
        }
    }

    /// 拿取cell的寬高
    func getCellSize() -> CGSize {
        let wSpace = getWSpace(.sushi)
        //w
        let cellSpaceWidth = wSpace * (getColumn().toDouble - 1)
        let cellAllWidth = floor(sushiCollectionFrame.value.width - 20) - cellSpaceWidth
        let cellMaxWidth = (cellAllWidth / getColumn().toDouble).rounded(.down)
        //h
        let cellMaxHeight = cellMaxWidth / 130 * 135

        return CGSize(width: cellMaxWidth, height: cellMaxHeight)
    }
}
