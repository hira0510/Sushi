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
     
    var sushiCollectionFrame: BehaviorRelay<CGRect> = BehaviorRelay<CGRect>(value: .zero)
    var menuCollectionFrame: BehaviorRelay<CGRect> = BehaviorRelay<CGRect>(value: .zero)
    
    /// 是否沒有正在編輯
    var isNotEdit: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: true)
    /// 懸浮點餐view是否展開
    var orderIsOpen: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: true)
    /// 選擇的menu Index
    var selectMenuItem: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)
    /// 選擇的Sushi Index 特殊處理從1開始
    var selectSushiItem: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)
    /// api的menu資料
    var menuModel: BehaviorRelay<[MenuModel]> = BehaviorRelay<[MenuModel]>(value: [])
    /// api的AD資料
    var adModel: BehaviorRelay<[AdModel]> = BehaviorRelay<[AdModel]>(value: [])
    /// 點餐紀錄暫時資料
    var orderModel: BehaviorRelay<[SushiModel]> = BehaviorRelay<[SushiModel]>(value: [])
    /// 點餐紀錄資料
    var recordModel: BehaviorRelay<[SushiRecordModel]> = BehaviorRelay<[SushiRecordModel]>(value: [])
    /// 刪除sushiModel的indexPath
    var deleteIndexAry: BehaviorRelay<[IndexPath]> = BehaviorRelay<[IndexPath]>(value: [])
    /// Client計算送出餐點次數
    var sendOrderCount: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)
    
    /// 餐點的送達時間＿0:餐點的index, 1:等待時間
    var orderTimeDic: BehaviorRelay<Dictionary<String, TimeInterval>> = BehaviorRelay<Dictionary<String, TimeInterval>>(value: [:])
    /// 餐點的最慢等待時間
    var orderTimeStr: BehaviorRelay<String> = BehaviorRelay<String>(value: "0")
    
    weak var delegate: MenuVcProtocol?
    
    var getMenu: MenuModel {
        return menuModel.value.count > selectMenuItem.value ? menuModel.value[selectMenuItem.value]: MenuModel()
    }
    
    /// 跳轉選擇的menu
    func selectItem(sushi: Int? = nil, menu: Int? = nil) {
        if let sushi = sushi {
            selectSushiItem.accept(sushi)
            deleteIndexAry.accept([])
        }
        if let menu = menu {
            selectMenuItem.accept(menu)
        }
    }
    
    /// 拿到特殊處理的menu資料
    func getSushiData() -> [MenuModel] {
        var newArray: [MenuModel] = menuModel.value

        guard let last = newArray.last, let first = newArray.first else { return newArray }
        newArray.insert(last, at: 0)
        newArray.append(first)
        return newArray
    }
    
    /// 替換掉一整頁menu
    func updateMenuModel(_ data: MenuModel) {
        var oldModel = menuModel.value
        let findIndex = (oldModel.map{ $0.menu }).firstIndex(of: data.menu) ?? 0
        guard oldModel.count > findIndex else { return }
        oldModel[findIndex] = data
        menuModel.accept(oldModel)
    }
    
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
            price.append(data.price)
            if i < model.count - 1 {
                item.append(",")
                price.append(",")
            }
        }
        return ["桌號": table, "點餐": item, "價格": price, "單號": numId.toStr]
    }
    
    /// Server編輯刪除品項api
    public func delData(_ index: Int) -> Observable<Int> {
        let menu = getMenu.menu
        let title = getMenu.sushi[index].title
        
        let json: Observable<Int> = Observable.create { [weak self] (observer) -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            Observable.zip(self.delData(.addSushi(menu, index.toStr)), self.delStorageImg(title)).subscribe(onNext: { _, _ in
                observer.onNext(index)
                observer.onCompleted()
            }).disposed(by: bag)
            return Disposables.create()
        }
        return json
    }

    func getHSpace(_ type: CollectionViewType) -> CGFloat {
        return type == .menu ? 5 : 0
    }

    func getWSpace(_ type: CollectionViewType) -> CGFloat {
        return type == .menu ? 5 : 0
    }
}
