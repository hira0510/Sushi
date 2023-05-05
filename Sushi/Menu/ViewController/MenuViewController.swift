//
//  MenuViewController.swift
//  Sushi
//
//  Created by admin on 2023/4/20.
//

import UIKit
import RxCocoa
import RxSwift

class MenuViewController: BaseViewController {
    
    @IBOutlet var views: MenuViews! {
        didSet {
            views.viewModel = viewModel
            views.bag = bag
        }
    }
    
    private let viewModel = MenuViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StarscreamWebSocketManager.shard.delegate = self
        request()
        setupUI()
    }
    
    deinit {
        views.orderTimer?.invalidate()
        views.orderTimer = nil
    }
    
    /// 設定collection的frame
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
        }, completion: { [weak self] (UIViewControllerTransitionCoordinatorContext) -> Void in
            guard let `self` = self else { return }
            let orient = UIDevice.current.orientation
            self.viewModel.orient = orient
            self.viewModel.menuCollectionFrame.accept(self.views.menuCollectionView.frame)
            self.viewModel.sushiCollectionFrame.accept(self.views.sushiCollectionView.frame)
            self.views.setupAdminServerView(self)
        })
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    private func setupUI() {
        views.orderListView.initView(order: viewModel.orderModel, delegate: self)
        views.menuInfoViewAddTarget(self)
        views.setupCollectionView(self)
        views.deleteItemBtnAddTarget(self)
        views.recordBtnAddTarget(self)
        views.addNewBtnAddTarget(self)
        views.checkoutBtnAddTarget(self)
        views.serviceBtnAddTarget(self)
    }
    
    /// 請求菜單api
    public func request() {
        viewModel.request().subscribe(onNext: { [weak self] (result) in
            guard let `self` = self, result.count > 0 else { return }
            self.viewModel.menuModel.accept(result)
            self.views.menuCollectionView.reloadData()
            self.views.sushiCollectionView.reloadData()
        }).disposed(by: bag)
    }
    
    /// Server編輯刪除品項api
    public func delData(_ index: Int) -> Observable<Int> {
        let menu = viewModel.menuModel.value[viewModel.selectItem.value].menu
        let title = viewModel.menuModel.value[viewModel.selectItem.value].sushi[index].title
        
        let json: Observable<Int> = Observable.create { [weak self] (observer) -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            Observable.zip(self.viewModel.delData(.titleEng(menu, title)), self.viewModel.delData(.money(menu, title)), self.viewModel.delData(.img(menu, title)), self.viewModel.delStorageImg(title)).subscribe(onNext: { _, _, _, _ in
                observer.onNext(index)
                observer.onCompleted()
            }).disposed(by: bag)
            return Disposables.create()
        }
        return json
    }
}

extension MenuViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let type: CollectionViewType = collectionView == views.menuCollectionView ? .menu: .sushi
        if type == .menu, self.viewModel.menuCollectionFrame.value == .zero {
            self.viewModel.menuCollectionFrame.accept(collectionView.frame)
        }
        if type == .sushi, self.viewModel.sushiCollectionFrame.value == .zero {
            self.viewModel.sushiCollectionFrame.accept(collectionView.frame)
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type: CollectionViewType = collectionView == views.menuCollectionView ? .menu: .sushi
        let model = viewModel.menuModel.value
        guard model.count > 0 else { return 0 }
        let index = viewModel.selectItem.value
        return type == .menu ? model.count: model[index].sushi.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type: CollectionViewType = collectionView == views.menuCollectionView ? .menu: .sushi
        let model = viewModel.menuModel.value
        let index = viewModel.selectItem.value
        switch type {
        case .menu:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuTitleCollectionViewCell", for: indexPath) as! MenuTitleCollectionViewCell
            let model = viewModel.menuModel.value
            guard model.count > indexPath.item else { return cell }
            cell.cellConfig(model[indexPath.item], index == indexPath.item)
            return cell
        case .sushi:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SushiCollectionViewCell", for: indexPath) as! SushiCollectionViewCell
            guard model.count > index else { return cell }
            cell.cellConfig(model: model[index].sushi[indexPath.item])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let type: CollectionViewType = collectionView == views.menuCollectionView ? .menu: .sushi
        switch type {
        case .menu:
            viewModel.selectItem.accept(indexPath.item)
        case .sushi:
            if viewModel.isNotEdit.value {
                let section = viewModel.selectItem.value
                let model = viewModel.menuModel.value[section]
                let sushi = model.sushi[indexPath.item]
                if SuShiSingleton.share().getIsAdmin() {
                    let vc = UIStoryboard.loadAddVC(delegate: self, edit: (model.menu, sushi))
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc = UIStoryboard.loadOrderVC(model: model.sushi[indexPath.item], color: model.color, delegate: self)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                let cell = collectionView.cellForItem(at: indexPath) as! SushiCollectionViewCell
                cell.backgroundColor = .gray
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let type: CollectionViewType = collectionView == views.menuCollectionView ? .menu: .sushi
        switch type {
        case .menu:
            return CGSize(width: GlobalUtil.calculateWidthScaleWithSize(width: 70), height: viewModel.menuCollectionFrame.value.height)
        case .sushi:
            return viewModel.getCellSize()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let type: CollectionViewType = collectionView == views.menuCollectionView ? .menu: .sushi
        return viewModel.getWSpace(type)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let type: CollectionViewType = collectionView == views.menuCollectionView ? .menu: .sushi
        return viewModel.getWSpace(type)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == views.menuCollectionView {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            return UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 10)
        }
    }
}

extension MenuViewController: AddSushiVcProtocol {
    /// Server新增品項後重新打api
    func requestSuc() {
        request()
    }
}

extension MenuViewController: OrderVcProtocol {
    /// Client從點餐頁面新增點餐項目
    func sendOrder(model: [SushiModel]) {
        viewModel.orderModel.add(model)
    }
}

extension MenuViewController: OrderListCellProtocol {
    
    /// Client刪除單一點餐項目
    func clickRemoveItem(_ model: SushiModel?) {
        var tempModel = viewModel.orderModel.value
        guard let model = model, let index = tempModel.firstIndex(of: model) else { return }
        tempModel.remove(at: index)
        viewModel.orderModel.accept(tempModel)
    }
    
    /// Client點擊縮放懸浮點餐View
    func clickOpenBtn(_ isToOpen: Bool) {
        viewModel.orderIsOpen.accept(isToOpen)
    }
    
    /// Client點擊送出點餐項目
    func clickOrderBtn() {
        let numId = viewModel.sendOrderCount.value
        viewModel.recordModel.add(viewModel.orderModel.value.map { SushiRecordModel(numId.toStr, -1, $0) })
        StarscreamWebSocketManager.shard.writeData(viewModel.orderModel.value, numId)
        
        addToast(txt: "已送出".twEng())
        viewModel.sendOrderCount.accept(viewModel.sendOrderCount.value + 1)
        viewModel.orderModel.accept([])
    }
}

extension MenuViewController: StarscreamWebSocketManagerProtocol {
    
    
   /// Server新增服務紀錄、結帳紀錄
    func otherHint(_ str: String, _ type: ServiceType) {
        switch type {
        case .checkout:
            UserDefaults.standard.checkoutHintIsHidden = false
            UserDefaults.standard.checkoutTableAry[str] = GlobalUtil.getCurrentTime()
        case .service:
            UserDefaults.standard.serviceHintIsHidden = false
            UserDefaults.standard.serviceTableAry[str] = GlobalUtil.getCurrentTime()
        }
    }
    
   /// Server新增點餐紀錄
    func orderHint(data: AddOrderItem) {
        let sqlite = OrderSQLite()
        UserDefaults.standard.recordHintIsHidden = false
        sqlite.insertData(_tableNumber: data.table, _numId: data.numId, _itemName: data.item, _itemPrice: data.itemPrice)
         
        //如果當前在點餐紀錄通知頁面就不用顯示紅點
        guard views.adminServerView.mType.value == .record() && self.view.subviews.contains(views.adminServerView) else { return }
        UserDefaults.standard.recordHintIsHidden = true
        let recordModel = viewModel.orderSqlite.readData()
        views.adminServerView.mType.accept(.record(recordModel))
    }
     
    /// Client結帳後的處理
    func alreadyCheckedOut() {
        viewModel.orderModel.accept([])
        viewModel.recordModel.accept([])
        viewModel.orderTimeStr.accept("0")
        viewModel.orderTimeDic.accept([:])
        SuShiSingleton.share().setIsCheckout(false)
    }
    /// Client拿到Server傳送過來的等待時間
    func getMin(_ min: Int, _ numId: String) {
         let timeStamp: TimeInterval = (min * 60).toDouble + GlobalUtil.getCurrentTime()
         viewModel.setupRecordModel(timeStamp, numId)
         viewModel.orderTimeDic.accept(viewModel.orderTimeDic.value.merging([numId: timeStamp]){ (_, new) in new })
         views.addOrderTimer()
     }
    
    /// Client拿到Server傳送過來的"送達"的處理
    func alreadyArrived(_ numId: String) {
        viewModel.setupRecordModel(GlobalUtil.getCurrentTime(), numId)
        viewModel.orderTimeDic.accept(viewModel.orderTimeDic.value.merging([numId: 0]){ (_, new) in new })
        views.addOrderTimer()
    }
}
