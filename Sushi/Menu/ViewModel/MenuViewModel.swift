//
//  MenuViewModel.swift
//  Sushi
//
//  Created by admin on 2023/4/20.
//

import UIKit
import RxCocoa
import RxSwift

protocol MenuVcProtocol: AnyObject {
    func setupRecordVcData(_ data: [SushiRecordModel])
}

class MenuViewModel: BaseViewModel {
    
    var orient: UIDeviceOrientation = .unknown
    var sushiCollectionFrame: BehaviorRelay<CGRect> = BehaviorRelay<CGRect>(value: .zero)
    var menuCollectionFrame: BehaviorRelay<CGRect> = BehaviorRelay<CGRect>(value: .zero)
    
    /// 是否沒有正在編輯
    var isNotEdit: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: true)
    /// 懸浮點餐view是否展開
    var orderIsOpen: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: true)
    /// 選擇的menu Index
    var selectItem: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)
    /// api的menu資料
    var menuModel: BehaviorRelay<[MenuModel]> = BehaviorRelay<[MenuModel]>(value: [])
    /// 點餐紀錄暫時資料
    var orderModel: BehaviorRelay<[SushiModel]> = BehaviorRelay<[SushiModel]>(value: [])
    /// 點餐紀錄資料
    var recordModel: BehaviorRelay<[SushiRecordModel]> = BehaviorRelay<[SushiRecordModel]>(value: [])
    /// Client計算送出餐點次數
    var sendOrderCount: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)
    
    /// 餐點的送達時間＿0:餐點的index, 1:等待時間
    var orderTimeDic: BehaviorRelay<Dictionary<String, TimeInterval>> = BehaviorRelay<Dictionary<String, TimeInterval>>(value: [:])
    /// 餐點的最慢等待時間
    var orderTimeStr: BehaviorRelay<String> = BehaviorRelay<String>(value: "0")
    weak var delegate: MenuVcProtocol?
    
    /// 更新送達時間&更新點餐紀錄vc的資料
    func setupRecordModel(_ timeStamp: TimeInterval, _ numId: String) {
        var newValue = recordModel.value
        newValue = newValue.map { model in
            if model.numId == numId {
                model.arrivedTime = timeStamp
            }
            return model
        }
        recordModel.accept(newValue)
        delegate?.setupRecordVcData(recordModel.value)
    }

    func getHSpace(_ type: CollectionViewType) -> CGFloat {
        return type == .menu ? 5 : 10
    }

    func getWSpace(_ type: CollectionViewType) -> CGFloat {
        return type == .menu ? 5 : 10
    }

    func getColumn() -> Int {
        switch orient {
        case .landscapeLeft, .landscapeRight: return 4
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
