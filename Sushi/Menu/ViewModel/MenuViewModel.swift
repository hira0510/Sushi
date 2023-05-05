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
    
    /// Client刪除單一點餐項目
    func clickRemoveItem(_ model: SushiModel?) {
        var tempModel = orderModel.value
        guard let model = model, let index = tempModel.firstIndex(of: model) else { return }
        tempModel.remove(at: index)
        orderModel.accept(tempModel)
    }
    
    /// Client結帳後的處理
    func resetData() {
        orderModel.accept([])
        recordModel.accept([])
        orderTimeStr.accept("0")
        orderTimeDic.accept([:])
        SuShiSingleton.share().setIsCheckout(false)
    }
    
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
    
    /// 整理送出餐點資訊
    func sendOrderWriteData(_ numId: Int) -> [String: String] {
        let model = orderModel.value
        let table = SuShiSingleton.share().getPassword()
        var item: String = ""
        var price: String = ""
        for (i, data) in model.enumerated() {
            item.append(data.title)
            price.append(data.money)
            if i < model.count - 1 {
                item.append(",")
                price.append(",")
            }
        }
        return ["桌號": table, "點餐": item, "價格": price, "單號": numId.toStr]
    }
    
    /// Server編輯刪除品項api
    public func delData(_ index: Int) -> Observable<Int> {
        let menu = menuModel.value[selectItem.value].menu
        let title = menuModel.value[selectItem.value].sushi[index].title
        
        let json: Observable<Int> = Observable.create { [weak self] (observer) -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            Observable.zip(self.delData(.titleEng(menu, title)), self.delData(.money(menu, title)), self.delData(.img(menu, title)), self.delStorageImg(title)).subscribe(onNext: { _, _, _, _ in
                observer.onNext(index)
                observer.onCompleted()
            }).disposed(by: bag)
            return Disposables.create()
        }
        return json
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
