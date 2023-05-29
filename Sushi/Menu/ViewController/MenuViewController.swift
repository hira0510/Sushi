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
            views.bag = viewModel.bag
        }
    }
    
    private let viewModel = MenuViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        StarscreamWebSocketManager.shard.delegate = self
        getAllMenu()
        setupUI()
    }
    
    /// 重新整理Layout
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.views.menuCollectionView.collectionViewLayout.invalidateLayout()
        self.views.sushiCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    deinit {
        views.orderTimer?.invalidate()
        views.orderTimer = nil
    }
    
    // MARK: - private
    private func setupUI() {
        views.orderListView.initView(order: viewModel.orderModel, delegate: self)
        views.adBannerView.setupView(adData: viewModel.adModel, delegate: self)
        views.menuInfoViewAddTarget(self)
        views.setupCollectionView(self)
        views.deleteItemBtnAddTarget(self)
        views.recordBtnAddTarget(self)
        views.addNewBtnAddTarget(self)
        views.checkoutBtnAddTarget(self)
        views.serviceBtnAddTarget(self)
    }
    
    // MARK: - public
    /// 請求菜單api
    public func getAllMenu() {
        viewModel.getAllMenu().subscribe(onNext: { [weak self] (result) in
            guard let `self` = self else { return }
            if result.ad.count > 0 {
                self.viewModel.adModel.accept(result.ad)
            }
            if result.data.count > 0 {
                self.viewModel.menuModel.accept(result.data)
                self.viewModel.selectItem(sushi: 1)
            }
        }, onError: { [weak self] _ in
            guard let `self` = self else { return }
            self.getAllMenu()
        }).disposed(by: bag)
    }
    /// 請求部分菜單
    public func requestMenu(_ menuName: String) {
        viewModel.requestMenu(menuName).subscribe(onNext: { [weak self] (result) in
            guard let `self` = self else { return }
            self.viewModel.updateMenuModel(result)
        }, onError: { [weak self] _ in
            guard let `self` = self else { return }
            self.requestMenu(menuName)
        }).disposed(by: bag)
    }
    
    /// 拖曳後更新api
    func updateDropModel() {
        let menu = viewModel.getMenu
        viewModel.addData(.dropEditSushi(menu.menu), menu.getSushiData()).subscribe(onNext: { (result) in
            StarscreamWebSocketManager.shard.writeMsg(["account": SuShiSingleton.share().getAccount(), "menu": menu.menu, "msg": "reloadData"])
        }).disposed(by: bag)
    }
    
    /// 編輯多選後更新api
    func updateEditModel() {
        let menu = viewModel.getMenu
        viewModel.addData(.dropEditSushi(menu.menu), menu.getSushiData()).subscribe(onNext: { [weak self] result in
            guard let `self` = self else { return }
            self.addAndRemoveToast(txt: "刪除成功")
            self.requestSuc(self.viewModel.getMenu.menu)
            self.viewModel.deleteIndexAry.accept([])
            self.viewModel.isNotEdit.accept(true)
        }, onError: { [weak self] _ in
            guard let `self` = self else { return }
            self.addAndRemoveToast(txt: "刪除失敗")
        }).disposed(by: bag)
    }
}

// MARK: - CollectionView
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
        return type == .menu ? model.count: viewModel.getSushiData().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type: CollectionViewType = collectionView == views.menuCollectionView ? .menu: .sushi
        switch type {
        case .menu:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuTitleCollectionViewCell", for: indexPath) as! MenuTitleCollectionViewCell
            let model = viewModel.menuModel.value
            let section = viewModel.selectMenuItem.value
            guard model.count > indexPath.item else { return cell }
            cell.cellConfig(model[indexPath.item], section == indexPath.item)
            return cell
        case .sushi:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SushiContanerCollectionViewCell", for: indexPath) as! SushiContanerCollectionViewCell
            let model = viewModel.getSushiData()
            guard model.count > indexPath.item else { return cell } 
            cell.cellConfig(model: model[indexPath.item].sushi, color: UIColor(model[indexPath.item].color), delegate: self)
            cell.bindData(select: viewModel.selectSushiItem, frame: viewModel.sushiCollectionFrame, isNotEdit: viewModel.isNotEdit, deleteAry: viewModel.deleteIndexAry)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? SushiContanerCollectionViewCell {
            cell.setupCollecctionViewFrame(viewModel.sushiCollectionFrame.value)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let type: CollectionViewType = collectionView == views.menuCollectionView ? .menu: .sushi
        switch type {
        case .menu:
            self.viewModel.selectItem(sushi: indexPath.item + 1, menu: indexPath.item)
        case .sushi: break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let type: CollectionViewType = collectionView == views.menuCollectionView ? .menu: .sushi
        switch type {
        case .menu:
            if viewModel.menuCollectionFrame.value != collectionView.frame {
                viewModel.menuCollectionFrame.accept(collectionView.frame)
            }
            return CGSize(width: GlobalUtil.calculateWidthScaleWithSize(width: 70), height: viewModel.menuCollectionFrame.value.height)
        case .sushi:
            if viewModel.sushiCollectionFrame.value != collectionView.frame {
                viewModel.sushiCollectionFrame.accept(collectionView.frame)
                views.setupAdminServerView(self)
            }
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
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
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    /// 偏移cell
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard scrollView == views.sushiCollectionView else { return }
        let collectionWidth = viewModel.sushiCollectionFrame.value.width
        let pageWidthFloat: CGFloat = CGFloat(collectionWidth)
        // 偏移量
        let offSetX: CGFloat = targetContentOffset.pointee.x
        // 按照偏移量計算是第幾個cell
        let pageCell = Int((offSetX + (collectionWidth / 2)) / collectionWidth)
        let pageCellFloat: CGFloat = CGFloat(pageCell)
        // 根據顯示第幾個cell來偏移
        let index = viewModel.getSushiData().count - (viewModel.getSushiData().count - pageCell)
        if offSetX > (index.toCGFloat * collectionWidth + collectionWidth / 2) {
            targetContentOffset.pointee.x = (pageCellFloat + 1) * pageWidthFloat
        } else {
            targetContentOffset.pointee.x = pageCellFloat * pageWidthFloat
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == views.sushiCollectionView else { return }
        let page = (scrollView.contentOffset.x / scrollView.bounds.size.width).rounded()
        if page == 0 {
            // 当UIScrollView滑动到第一位停止时，将UIScrollView的偏移位置改变
            self.viewModel.selectItem(sushi: viewModel.getSushiData().count - 2)
        } else if page.toInt == (viewModel.getSushiData().count - 1) {
            // 当UIScrollView滑动到最后一位停止时，将UIScrollView的偏移位置改变
            self.viewModel.selectItem(sushi: 1)
        } else {
            self.viewModel.selectItem(sushi: page.toInt)
        } 
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == views.sushiCollectionView else { return }
        var visibleRect = CGRect()
        visibleRect.origin = scrollView.contentOffset
        visibleRect.size = scrollView.bounds.size
        // 拿取每次scroll後scrollView總偏移X的中間值
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        // 用偏移的point來計算當前cell是哪個indexPath
        let page = (visiblePoint.x / viewModel.sushiCollectionFrame.value.width).toInt
        let modelCount = viewModel.menuModel.value.count
        var selectIndex = 0
 
        if page == 0 {
            selectIndex = modelCount - 1
        } else if page == viewModel.getSushiData().count - 1 {
            selectIndex = 0
        } else {
            selectIndex = page - 1
        }
        
        if viewModel.selectMenuItem.value != selectIndex && modelCount > selectIndex {
            self.viewModel.selectItem(menu: selectIndex)
        }
    }
}

// MARK: - 點擊輪播廣告
extension MenuViewController: BannerTYCycleViewProtocol {
    func didClickCycleCell(_ url: String) {
        self.changeSchemes(url: url) { urlSchemeFactory in
            switch urlSchemeFactory.mAction {
            case "order":
                let sushiDic = urlSchemeFactory.mValue.toMsgDic(",", ":")
                let sushiData = SushiModel().toSushi(dic: sushiDic)
                let vc = UIStoryboard.loadOrderVC(model: sushiData, color: "FFEEFF", delegate: self)
                self.navigationController?.pushViewController(vc, animated: true)
            case "player":
                let vc = UIStoryboard.loadPlayerVC(url: urlSchemeFactory.mValue)
                self.navigationController?.pushViewController(vc, animated: true)
            default: break
            }
        }
    }
}

// MARK: - 新增品項Vc
extension MenuViewController: AddSushiVcProtocol {
    /// Server新增品項後重新打api
    func requestSuc(_ menuName: String) {
        requestMenu(menuName)
        StarscreamWebSocketManager.shard.writeMsg(["menu": menuName, "msg": "addReloadData"])
    }
}

// MARK: - 點餐Vc
extension MenuViewController: OrderVcProtocol {
    /// Client從點餐頁面新增點餐項目
    func sendOrder(model: [SushiModel]) {
        viewModel.orderModel.add(model)
    }
}

// MARK: - 懸浮點餐View
extension MenuViewController: OrderListCellProtocol {
    
    /// Client刪除單一點餐項目
    func clickRemoveItem(_ model: SushiModel?) {
        viewModel.clickRemoveItem(model)
    }
    
    /// Client點擊縮放懸浮點餐View
    func clickOpenBtn(_ isToOpen: Bool) {
        viewModel.orderIsOpen.accept(isToOpen)
    }
    
    /// Client點擊送出點餐項目
    func clickOrderBtn() {
        let numId = viewModel.sendOrderCount.value
        viewModel.recordModel.add(viewModel.orderModel.value.map { SushiRecordModel(numId.toStr, -1, $0) })
        StarscreamWebSocketManager.shard.writeMsg(viewModel.sendOrderWriteData(numId))
        
        addToast(txt: "已送出".twEng())
        viewModel.sendOrderCount.accept(viewModel.sendOrderCount.value + 1)
        viewModel.orderModel.accept([])
    }
}

// MARK: - WebSocket訊息處理
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
        guard views.adminServerView.getType() == .record() && self.view.subviews.contains(views.adminServerView) else { return }
        UserDefaults.standard.recordHintIsHidden = true
        let recordModel = viewModel.orderSqlite.readData()
        views.adminServerView.setupType(.record(recordModel))
    }
     
    /// Client結帳後的處理
    func alreadyCheckedOut() {
        viewModel.resetData()
    }
    
    /// Client拿到Server傳送過來的等待時間
    func getMin(_ min: Int, _ numId: String) {
         let timeStamp: TimeInterval = (min * 60).toTimeInterval + GlobalUtil.getCurrentTime()
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
    
    /// Client拿到Server傳送過來的Menu重新拿資料
    func updateMenu(_ menuName: String) {
        requestMenu(menuName)
    }
}

// MARK: - sushiCell
extension MenuViewController: SushiContanerCellToMenuVcProtocol {
    /// 到AddVC
    func pushToAddVC(index: Int, sushi: SushiModel) {
        let model = viewModel.getMenu
        let vc = UIStoryboard.loadAddVC(type: .edit(index), delegate: self, edit: (model.menu, sushi))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    /// 到OrderVC
    func pushToOrderVC(sushi: SushiModel) {
        let model = viewModel.getMenu
        let vc = UIStoryboard.loadOrderVC(model: sushi, color: model.color, delegate: self)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    /// 編輯排序更新menuModel
    func updateMenuModel(removeIndex: Int, insertIndex: Int, insertModel: SushiModel) {
        let oldModel = viewModel.menuModel.value
        oldModel[viewModel.selectMenuItem.value].sushi.remove(at: removeIndex)
        oldModel[viewModel.selectMenuItem.value].sushi.insert(insertModel, at: insertIndex)
        viewModel.menuModel.accept(oldModel)
        self.updateDropModel()
    }
    /// 更新要刪除的IndexPath
    func updateDeleteIndexAry(_ indexPath: [IndexPath]) {
        viewModel.deleteIndexAry.accept(indexPath)
    }
    /// 拖曳時不開啟Scroll
    func isCollectionViewScroll(_ embar: Bool) {
        views.sushiCollectionView.isScrollEnabled = !embar
    }
}
