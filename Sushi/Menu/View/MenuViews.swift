//
//  MenuViews.swift
//  Sushi
//
//  Created by admin on 2023/4/20.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import RxGesture

class MenuViews: NSObject {
    public var viewModel: MenuViewModel!
    public var bag: DisposeBag!
    
    /// Server的收發通知頁面
    public var adminServerView: ServerView = ServerView()
    /// Client懸浮點餐View對右的tConstraints
    private var orderListViewRightConstraints: Constraint? = nil
    /// 送達時間到數Timer
    public var orderTimer: Timer?

    @IBOutlet weak var adBannerView: BannerTYCycleView!
    @IBOutlet weak var sushiCollectionView: UICollectionView! {
        didSet {
            //手機更換方向時重整collectionView
            Observable.combineLatest(viewModel.menuModel, viewModel.sushiCollectionFrame) { _, frame -> CGRect in
                return frame
            }.map { $0 }.bind(to: sushiCollectionView.rx.reloadData).disposed(by: bag)
            
            //選擇頁面時頁面滑至同index
            Observable.combineLatest(viewModel.selectSushiItem, viewModel.sushiCollectionFrame) { [weak self] index, frame -> CGFloat in
                guard let `self` = self else { return 0 }
                if self.viewModel.getSushiData().count > 0 {
                    self.sushiCollectionView.backgroundColor = UIColor(self.viewModel.getSushiData()[index].color)
                }
                return index.toCGFloat * frame.width
            }.map { $0 }.bind(to: sushiCollectionView.rx.sushiScrollContentOffset).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var menuCollectionView: UICollectionView! {
        didSet {
            //點擊menu選擇頁面&手機更換方向時頁面滑至同index
            Observable.combineLatest(viewModel.selectMenuItem, viewModel.menuCollectionFrame) { index, _ -> Int in
                return index
            }.map { $0 }.bind(to: menuCollectionView.rx.menuScrollIndex).disposed(by: bag) 
            //拿到資料&拿到點擊menu選擇頁面＆手機更換方向＆中英轉換時重整collectionView
            Observable.combineLatest(viewModel.menuModel, viewModel.selectMenuItem, viewModel.menuCollectionFrame, SuShiSingleton.share().bindIsEng()) { _, index, _, _ -> Int in
                return index
            }.map { $0 }.bind(to: menuCollectionView.rx.reloadData).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var languageInfoBtn: UIButton! {
        didSet {
            //中英轉換
            SuShiSingleton.share().bindIsEng().bind(to: languageInfoBtn.rx.isSelected).disposed(by: bag)
            //點擊中英轉換，重整UI
            languageInfoBtn.rx.tap.asObservable().map { [weak self] _ -> Bool in
                guard let `self` = self else { return false }
                return !self.languageInfoBtn.isSelected
            }.do { [weak self] isSelect in
                guard let `self` = self else { return }
                SuShiSingleton.share().setIsEng(isSelect)
                self.menuInfoView.updateUI()
                self.plateInfoView.updateUI()
                self.timeInfoView.updateUI()
            }.bind(to: languageInfoBtn.rx.isSelected).disposed(by: bag)
        }
    }
    @IBOutlet weak var menuInfoView: MenuInfoView! {
        didSet {
            //桌號
            let isAdmin = SuShiSingleton.share().getIsAdmin()
            self.menuInfoView.num = isAdmin ? "X": SuShiSingleton.share().getPassword()
        }
    }
    @IBOutlet weak var plateInfoView: MenuInfoView! {
        didSet {
            //盤數
            viewModel.recordModel.bind(to: plateInfoView.numLabel.rx.countText).disposed(by: bag)
        }
    }
    @IBOutlet weak var timeInfoView: MenuInfoView! {
        didSet {
            //送達時間
            viewModel.orderTimeStr.bind(to: timeInfoView.numLabel.rx.text).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var loginLabel: UILabel! {
        didSet {
            //登入資訊
            SuShiSingleton.share().bindIsLogin().bind(to: loginLabel.rx.labelIsHidden).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var previousPageBtn: UIButton! {
        didSet {
            //文字中英轉換
            SuShiSingleton.share().bindIsEng().bind(to: previousPageBtn.rx.isSelected).disposed(by: bag)
            //點擊上一頁跳到還沒看過的cell, 如果已經到頂了就往上一頁
            previousPageBtn.rx.tap.subscribe { [weak self] event in
                guard let `self` = self else { return }
                guard let contanerCell = self.sushiCollectionView.cellForItem(at: IndexPath(item: self.viewModel.selectSushiItem.value, section: 0)) as? SushiContanerCollectionViewCell else { return }
                
                guard !contanerCell.isScrollNotVisibleItems(false) else { return }
                if self.viewModel.selectMenuItem.value == 0 { //如果是第一頁就做特殊處理到最後一頁
                    self.viewModel.selectMenuItem.accept(self.viewModel.menuModel.value.count - 1)
                    self.viewModel.selectSushiItem.accept(self.viewModel.getSushiData().count - 2)
                } else {
                    self.viewModel.selectMenuItem.accept(self.viewModel.selectMenuItem.value - 1)
                    self.viewModel.selectSushiItem.accept(self.viewModel.selectSushiItem.value - 1)
                }
            }.disposed(by: bag)
        }
    }
    
    @IBOutlet weak var nextPageBtn: UIButton! {
        didSet {
            //文字中英轉換
            SuShiSingleton.share().bindIsEng().bind(to: nextPageBtn.rx.isSelected).disposed(by: bag)
            //點擊下一頁跳到還沒看過的cell, 如果已經到底了就往下一頁
            nextPageBtn.rx.tap.subscribe { [weak self] event in
                guard let `self` = self else { return }
                guard let contanerCell = self.sushiCollectionView.cellForItem(at: IndexPath(item: self.viewModel.selectSushiItem.value, section: 0)) as? SushiContanerCollectionViewCell else { return }
                
                guard !contanerCell.isScrollNotVisibleItems(true) else { return }
                let isLastPage = self.viewModel.selectSushiItem.value + 1 == self.viewModel.getSushiData().count - 1
                if isLastPage { //如果是最後一頁就做特殊處理到第一頁
                    self.viewModel.selectMenuItem.accept(0)
                    self.viewModel.selectSushiItem.accept(1)
                } else {
                    self.viewModel.selectMenuItem.accept(self.viewModel.selectMenuItem.value + 1)
                    self.viewModel.selectSushiItem.accept(self.viewModel.selectSushiItem.value + 1)
                }
            }.disposed(by: bag)
        }
    }
    
    @IBOutlet weak var recordView: MenuServiceView! {
        didSet {
            //文字中英轉換
            SuShiSingleton.share().bindIsEng().bind(to: recordView.mButton.rx.isSelected).disposed(by: bag)
            //監聽有新資料會出現紅點
            UserDefaults.standard.rx.observe(Bool.self, "recordHintIsHidden").subscribe(onNext: { [weak self] isHidden in
                guard let `self` = self else { return }
                self.recordView.updateUI(isHidden: unwrap(isHidden, true))
            }).disposed(by: bag)
        }
    }
    @IBOutlet weak var serviceView: MenuServiceView! {
        didSet {
            //文字中英轉換
            SuShiSingleton.share().bindIsEng().bind(to: serviceView.mButton.rx.isSelected).disposed(by: bag)
            //監聽有新資料會出現紅點
            UserDefaults.standard.rx.observe(Bool.self, "serviceHintIsHidden").subscribe(onNext: { [weak self] isHidden in
                guard let `self` = self else { return }
                self.serviceView.updateUI(isHidden: unwrap(isHidden, true))
            }).disposed(by: bag)
        }
    }
    @IBOutlet weak var checkoutView: MenuServiceView! {
        didSet {
            //文字中英轉換
            SuShiSingleton.share().bindIsEng().bind(to: checkoutView.mButton.rx.isSelected).disposed(by: bag)
            //監聽有新資料會出現紅點
            UserDefaults.standard.rx.observe(Bool.self, "checkoutHintIsHidden").subscribe(onNext: { [weak self] isHidden in
                guard let `self` = self else { return }
                self.checkoutView.updateUI(isHidden: unwrap(isHidden, true))
            }).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var addNewBtn: NGSCustomizableButton! {
        didSet {
            //Server端出現新增按鈕
            SuShiSingleton.share().bindIsLogin().bind(to: addNewBtn.rx.addBtnIsHidden).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var editBtn: UIButton! {
        didSet {
            //Server端出現編輯按鈕
            SuShiSingleton.share().bindIsLogin().bind(to: editBtn.rx.addBtnIsHidden).disposed(by: bag)
            //按鈕狀態
            viewModel.isNotEdit.bind(to: editBtn.rx.btnIsSelect).disposed(by: bag)
            
            //點擊編輯按鈕
            editBtn.rx.tap.asObservable().map { [weak self] _ -> Bool in
                guard let `self` = self else { return false }
                return !self.editBtn.isSelected
            }.do { [weak self] isSelect in
                guard let `self` = self else { return }
                self.viewModel.isNotEdit.accept(!isSelect)
            }.bind(to: editBtn.rx.isSelected).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var deleteItemBtn: UIButton! {
        didSet {
            //Server編輯狀態刪除按鈕出現
            viewModel.isNotEdit.bind(to: deleteItemBtn.rx.isHidden).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var orderListView: OrderListView! {
        didSet {
            // 綁定懸浮點餐View的Constraint
            bindOrderListViewConstraint()
            //初始Constraints
            orderListView.snp.makeConstraints { make in
                orderListViewRightConstraints = make.right.equalToSuperview().offset(0).constraint
            }
        }
    }
    
    /// 初始CollectionView
    func setupCollectionView(_ vc: MenuViewController) {
        menuCollectionView.delegate = vc
        menuCollectionView.dataSource = vc
        menuCollectionView.register(MenuTitleCollectionViewCell.nib, forCellWithReuseIdentifier: "MenuTitleCollectionViewCell")
        sushiCollectionView.delegate = vc
        sushiCollectionView.dataSource = vc
        sushiCollectionView.decelerationRate = .init(rawValue: 0.1)
        sushiCollectionView.register(SushiContanerCollectionViewCell.nib, forCellWithReuseIdentifier: "SushiContanerCollectionViewCell")
    }
    
    /// Client端送達時間計時分鐘
    func addOrderTimer() {
        self.orderTimer?.invalidate()
        self.orderTimer = nil
        timerReciprocal()
        orderTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(timerReciprocal), userInfo: nil, repeats: true)
    }
    
    /// 送達時間更新
    @objc func timerReciprocal() {
        //找出最久的時間顯示在螢幕
        let maxTimeStamp = unwrap(self.viewModel.orderTimeDic.value.getSortTimeValue.first, 0)
        guard maxTimeStamp > GlobalUtil.getCurrentTime() else {
            self.viewModel.orderTimeStr.accept("0")
            self.orderTimer?.invalidate()
            self.orderTimer = nil
            return
        }
        let waitMin = ((maxTimeStamp - GlobalUtil.getCurrentTime()) / 60) + 1
        self.viewModel.orderTimeStr.accept(waitMin.toInt.toStr)
    }
    
    /// Client變更懸浮點餐View的Constraint
    func bindOrderListViewConstraint() {
        Observable.combineLatest(viewModel.orderModel, viewModel.orderIsOpen) { [weak self] model, isOpen ->  (model: [SushiModel], isOpen: Bool) in
            guard let `self` = self, model.count > 0 else { return ([], false) }
            
            if let collectionView = self.orderListView.mCollectionView {
                collectionView.isHidden = !isOpen
            }
            if let btn = self.orderListView.orderBtn {
                btn.isHidden = !isOpen
            }
            
            let oneCell: CGFloat = GlobalUtil.calculateWidthHorizontalScaleWithSize(width: 70)
            let allCell: CGFloat = oneCell.rounded(.down) * model.count.toCGFloat
            let allCellSpace: CGFloat = (model.count - 1).toCGFloat * 5
            let edge: CGFloat = 10.0
            let tool: CGFloat = GlobalUtil.calculateWidthHorizontalScaleWithSize(width: 60) + 2
            let screenW: CGFloat = UIScreen.main.bounds.width
            let safeArea = UIApplication.safeArea
            let maxW: CGFloat = screenW - 70 - tool - (GlobalUtil.isPortrait() ? 0: safeArea.left + safeArea.right)
            
            if isOpen {
                let rightConstant: CGFloat = screenW - (tool + allCell + allCellSpace + edge + 70)
                let resultContant: CGFloat = allCell + allCellSpace + edge
                self.orderListViewRightConstraints?.update(offset: rightConstant <= 0 ? 0: rightConstant)
                self.orderListView.setCollectionWConstraint(resultContant > maxW ? maxW: resultContant)
            } else {
                self.orderListViewRightConstraints?.update(offset: screenW - tool)
                self.orderListView.setCollectionWConstraint(0)
            }
            
            return (model, isOpen)
        }.subscribe().disposed(by: bag)
    }
    
    /// Server點擊刪除按鈕_刪除多個品項
    func deleteItemBtnAddTarget(_ baseVc: MenuViewController) {
        deleteItemBtn.rx.tap.subscribe { [weak self] event in
            guard let `self` = self else { return }
            let indexPathArr = viewModel.deleteIndexAry.value.sorted(by: >)
            guard indexPathArr.count > 0 else { return }
            let oldModel = self.viewModel.menuModel.value
            baseVc.addToast(txt: "刪除中...", type: .sending)
            
            Observable.from(indexPathArr).enumerated().flatMap { [weak self] indexPath -> Observable<Int> in
                guard let `self` = self else { return Observable.just(-1) }
                oldModel[self.viewModel.selectMenuItem.value].sushi.remove(at: indexPath.element.item)
                return Observable.just(indexPath.element.item)
            }.subscribe(onNext: { [weak self] index in
                guard let `self` = self, index == indexPathArr.last?.item else { return }
                self.viewModel.menuModel.accept(oldModel)
                baseVc.updateEditModel()
            }).disposed(by: bag)
        }.disposed(by: bag)
    }
    
    /// 點擊菜單_開啟官網Menu
    func menuInfoViewAddTarget(_ baseVc: MenuViewController) {
        menuInfoView.rx.tapGesture().when(.recognized).subscribe(onNext: { _ in
            let vc = UIStoryboard.loadWebViewVC(url: "https://www.sushiexpress.com.tw/sushi-express/Menu?c=Gunkan")
            baseVc.present(vc, animated: true)
        }).disposed(by: bag)
    }
    
    /// Server點擊新增按鈕_跳至新增頁面
    func addNewBtnAddTarget(_ baseVc: MenuViewController) {
        addNewBtn.rx.tap.subscribe { [weak self] _ in
            guard let `self` = self else { return }
            let model = viewModel.menuModel.value
            guard model.count > 0 else { return }
            let menu: [MenuStrModel] = MenuStrModel().getAry(model)
            let vc = UIStoryboard.loadAddVC(type: .add, delegate: baseVc, menu: menu)
            baseVc.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: bag)
    }
    
    /// 點擊點餐紀錄按鈕_Server開啟點餐通知View_Client開啟紀錄Vc
    func recordBtnAddTarget(_ baseVc: BaseViewController) {
        recordView.mButton.rx.tap.subscribe { [weak self] _ in
            guard let `self` = self else { return }
            if SuShiSingleton.share().getIsAdmin() {
                self.setupAdminServerView(baseVc, self.recordView)
            } else {
                let vc = UIStoryboard.loadRecordVC(model: self.viewModel.recordModel.value)
                self.viewModel.delegate = vc
                baseVc.navigationController?.pushViewController(vc, animated: true)
            }
        }.disposed(by: bag)
    }
    
    /// 點擊結帳按鈕_Server開啟結帳通知View_Client傳送通知給Server
    func checkoutBtnAddTarget(_ baseVc: BaseViewController) {
        checkoutView.mButton.rx.tap.subscribe { [weak self] _ in
            guard let `self` = self else { return }
            if SuShiSingleton.share().getIsAdmin() {
                self.setupAdminServerView(baseVc, self.checkoutView)
            } else if viewModel.recordModel.value.count > 0 {
                baseVc.addToast(txt: "已通知服務員，請稍候".twEng())
                let table = SuShiSingleton.share().getPassword()
                StarscreamWebSocketManager.shard.writeMsg(["桌號": table, "msg": "結帳"])
                SuShiSingleton.share().setIsCheckout(true)
            }
        }.disposed(by: bag)
    }
    
    /// 點擊結帳按鈕_Server開啟服務通知View_Client傳送通知給Server
    func serviceBtnAddTarget(_ baseVc: BaseViewController) {
        serviceView.mButton.rx.tap.subscribe { [weak self] _ in
            guard let `self` = self else { return }
            if SuShiSingleton.share().getIsAdmin() {
                self.setupAdminServerView(baseVc, self.serviceView)
            } else {
                baseVc.addToast(txt: "已通知服務員，請稍候".twEng())
                let table = SuShiSingleton.share().getPassword()
                StarscreamWebSocketManager.shard.writeMsg(["桌號": table, "msg": "服務"])
            }
        }.disposed(by: bag)
    }
    
    /// 重新設置通知View的Constraints跟資料
    func setupAdminServerView(_ baseVc: BaseViewController, _ view: UIView? = nil) {
        guard SuShiSingleton.share().getIsAdmin() else { return }
        
        //如果只是為了橫式轉方向就不往下執行
        guard let views = view else {
            var views: UIView
            switch adminServerView.getType() {
            case .service: views = serviceView
            case .record(_): views = recordView
            case .checkout: views = checkoutView
            }
            
            let left = baseVc.view.convert(CGPoint.zero, from: views).x + views.bounds.midX - 20
            adminServerView.setupConstraints(left)
            return
        }
        
        if !baseVc.view.subviews.contains(adminServerView) {
            baseVc.view.addSubview(adminServerView)
            adminServerView.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.bottom.equalTo(recordView.snp.top).offset(-3)
            }
        }
        
        if views == recordView {
            let recordModel = viewModel.orderSqlite.readData()
            adminServerView.setupType(.record(recordModel))
            UserDefaults.standard.recordHintIsHidden = true
        } else if views == checkoutView {
            let tableAry = UserDefaults.standard.checkoutTableAry.getSortTimeKey
            let timeAry = UserDefaults.standard.checkoutTableAry.getSortTimeValue
            let recordModel = viewModel.orderSqlite.readUniteData(tableAry: tableAry)
            adminServerView.setupType(.checkout(recordModel, timeAry))
            UserDefaults.standard.checkoutHintIsHidden = true
        } else if views == serviceView {
            let sortAry = UserDefaults.standard.serviceTableAry.sortTimeAry
            adminServerView.setupType(.service(sortAry))
            UserDefaults.standard.serviceHintIsHidden = true
        }
        
        let left = baseVc.view.convert(CGPoint.zero, from: views).x + views.bounds.midX - 20
        adminServerView.setupConstraints(left)
    }
}
