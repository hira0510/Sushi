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
    private var orderListViewRightConstraints: Constraint? = nil

    @IBOutlet weak var sushiCollectionView: UICollectionView! {
        didSet {
            viewModel.selectItem.bind(to: sushiCollectionView.rx.sushiScrollTop).disposed(by: bag)
            viewModel.isNotEdit.bind(to: sushiCollectionView.rx.allowsMultipleSelection).disposed(by: bag)
            
            Observable.combineLatest(viewModel.selectItem, viewModel.menuModel) { index, model -> UIColor in
                return model.count > 0 ? UIColor(hexString: model[index].color) ?? .clear: .clear
            }.map { $0 }.bind(to: sushiCollectionView.rx.backgroundColor).disposed(by: bag)
            
            Observable.combineLatest(viewModel.selectItem, viewModel.sushiCollectionFrame, SuShiSingleton.share().bindIsEng()) { index, _, _ -> Int in
                return index
            }.map { $0 }.bind(to: sushiCollectionView.rx.reloadData).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var menuCollectionView: UICollectionView! {
        didSet {
            viewModel.selectItem.bind(to: menuCollectionView.rx.menuScrollIndex).disposed(by: bag)
            
            Observable.combineLatest(viewModel.selectItem, viewModel.sushiCollectionFrame, SuShiSingleton.share().bindIsEng()) { index, _, _ -> Int in
                return index
            }.map { $0 }.bind(to: menuCollectionView.rx.reloadData).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var languageInfoBtn: UIButton! {
        didSet {
            SuShiSingleton.share().bindIsEng().bind(to: languageInfoBtn.rx.isSelected).disposed(by: bag)
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
            let isAdmin = SuShiSingleton.share().getAccountType() == .administrator
            self.menuInfoView.num = isAdmin ? "X": SuShiSingleton.share().getPassword()
        }
    }
    @IBOutlet weak var plateInfoView: MenuInfoView! {
        didSet {
            viewModel.recordModel.bind(to: plateInfoView.numLabel.rx.countText).disposed(by: bag)
        }
    }
    @IBOutlet weak var timeInfoView: MenuInfoView! {
        didSet {
            viewModel.orderTimeStr.bind(to: timeInfoView.numLabel.rx.text).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var loginLabel: UILabel! {
        didSet {
            SuShiSingleton.share().bindIsLogin().bind(to: loginLabel.rx.labelIsHidden).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var previousPageBtn: UIButton! {
        didSet {
            SuShiSingleton.share().bindIsEng().bind(to: previousPageBtn.rx.isSelected).disposed(by: bag)
            
            previousPageBtn.rx.tap.subscribe { [weak self] event in
                guard let `self` = self else { return }
                guard self.viewModel.selectItem.value > 0 else { return }
                self.viewModel.selectItem.accept(self.viewModel.selectItem.value - 1)
            }.disposed(by: bag)
        }
    }
    
    @IBOutlet weak var nextPageBtn: UIButton! {
        didSet {
            SuShiSingleton.share().bindIsEng().bind(to: nextPageBtn.rx.isSelected).disposed(by: bag)
            
            nextPageBtn.rx.tap.subscribe { [weak self] event in
                guard let `self` = self else { return }
                guard self.viewModel.selectItem.value < self.viewModel.menuModel.value.count - 1 else { return }
                self.viewModel.selectItem.accept(self.viewModel.selectItem.value + 1)
            }.disposed(by: bag)
        }
    }
    
    @IBOutlet weak var recordBtn: UIButton! {
        didSet {
            SuShiSingleton.share().bindIsEng().bind(to: recordBtn.rx.isSelected).disposed(by: bag)
        }
    }
    @IBOutlet weak var serviceBtn: UIButton! {
        didSet {
            SuShiSingleton.share().bindIsEng().bind(to: serviceBtn.rx.isSelected).disposed(by: bag)
        }
    }
    @IBOutlet weak var checkoutBtn: UIButton! {
        didSet {
            SuShiSingleton.share().bindIsEng().bind(to: checkoutBtn.rx.isSelected).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var addNewBtn: NGSCustomizableButton! {
        didSet {
            SuShiSingleton.share().bindIsLogin().bind(to: addNewBtn.rx.addBtnIsHidden).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var editBtn: UIButton! {
        didSet {
            SuShiSingleton.share().bindIsLogin().bind(to: editBtn.rx.addBtnIsHidden).disposed(by: bag)
            viewModel.isNotEdit.bind(to: editBtn.rx.btnIsSelect).disposed(by: bag)
            
            editBtn.rx.tap.asObservable().map { [weak self] _ -> Bool in
                guard let `self` = self else { return false }
                return !self.editBtn.isSelected
            }.do { [weak self] isSelect in
                guard let `self` = self else { return }
                self.viewModel.isNotEdit.accept(!isSelect)
                if !isSelect {
                    self.cancelSelect()
                }
            }.bind(to: editBtn.rx.isSelected).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var deleteItemBtn: UIButton! {
        didSet {
            viewModel.isNotEdit.bind(to: deleteItemBtn.rx.isHidden).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var orderListView: OrderListView! {
        didSet {
            bindOrderListViewConstraint()
            orderListView.snp.makeConstraints { make in
                orderListViewRightConstraints = make.right.equalToSuperview().offset(0).constraint
            }
        }
    }
    
    func setupCollectionView(_ vc: MenuViewController) {
        menuCollectionView.delegate = vc
        menuCollectionView.dataSource = vc
        menuCollectionView.register(MenuTitleCollectionViewCell.nib, forCellWithReuseIdentifier: "MenuTitleCollectionViewCell")
        sushiCollectionView.delegate = vc
        sushiCollectionView.dataSource = vc
        sushiCollectionView.register(SushiCollectionViewCell.nib, forCellWithReuseIdentifier: "SushiCollectionViewCell")
    }
    
    func cancelSelect() {
        var indexPathArr = self.sushiCollectionView.indexPathsForSelectedItems ?? []
        for indexpah in indexPathArr {
            let cell: SushiCollectionViewCell = self.sushiCollectionView.cellForItem(at: indexpah) as!SushiCollectionViewCell
            self.sushiCollectionView.deselectItem(at: indexpah, animated: true)//取消选中的状态
            cell.isSelected = false
            indexPathArr = (self.sushiCollectionView.indexPathsForSelectedItems)!//所有被选中的cell的indexpath
        }
    }
    
    func bindOrderListViewConstraint() {
        Observable.combineLatest(viewModel.orderModel, viewModel.orderIsOpen) { [weak self] model, isOpen ->  (model: [SushiModel], isOpen: Bool) in
            guard let `self` = self, model.count > 0 else { return ([], false) }
            
            if let collectionView = self.orderListView.mCollectionView {
                collectionView.isHidden = !isOpen
            }
            if let btn = self.orderListView.orderBtn {
                btn.isHidden = !isOpen
            }
            
            let oneCell = GlobalUtil.calculateWidthHorizontalScaleWithSize(width: 70)
            let allCell = oneCell.rounded(.down) * model.count.toDouble
            let allCellSpace: Double = (model.count - 1).toDouble * 5
            let edge = 10.0
            let tool = GlobalUtil.calculateWidthHorizontalScaleWithSize(width: 60) + 2.0
            let screenW = UIScreen.main.bounds.width
            let safeArea = UIApplication.safeArea
            let maxW = screenW - 70 - tool - (viewModel.orient == .portrait ? 0: safeArea.left + safeArea.right)
            
            if isOpen {
                let rightConstant = screenW - (tool + allCell + allCellSpace + edge + 70)
                let resultContant = allCell + allCellSpace + edge
                self.orderListViewRightConstraints?.update(offset: rightConstant <= 0 ? 0: rightConstant)
                self.orderListView.collectionWConstraint?.update(offset: resultContant > maxW ? maxW: resultContant)
            } else {
                self.orderListViewRightConstraints?.update(offset: screenW - tool)
                self.orderListView.collectionWConstraint?.update(offset: 0)
            }
            
            return (model, isOpen)
        }.subscribe().disposed(by: bag)
    }
    
    func deleteItemBtnAddTarget(_ baseVc: MenuViewController) {
        deleteItemBtn.rx.tap.subscribe { [weak self] event in
            guard let `self` = self else { return }
            let indexPathArr = self.sushiCollectionView.indexPathsForSelectedItems ?? []
            guard indexPathArr.count > 0 else { return }
            baseVc.addToast(txt: "刪除中...", type: .sending)
            
            Observable.from(indexPathArr).enumerated().flatMap { indexPath -> Observable<Int> in
                return baseVc.delData(indexPath.element.item)
            }.subscribe(onNext: { [weak self] index in
                guard let `self` = self, index == indexPathArr.last?.item else { return }
                baseVc.removeToast()
                baseVc.addToast(txt: "刪除成功")
                baseVc.request()
                self.cancelSelect()
                self.viewModel.isNotEdit.accept(true)
            }).disposed(by: bag)
        }.disposed(by: bag)
    }
    
    func menuInfoViewAddTarget(_ baseVc: MenuViewController) {
        menuInfoView.rx.tapGesture().when(.recognized).subscribe(onNext: { _ in 
            let vc = UIStoryboard.loadWebViewVC(url: "https://www.sushiexpress.com.tw/sushi-express/Menu?c=Gunkan")
            baseVc.present(vc, animated: true)
        }).disposed(by: bag)
    }
    
    func recordBtnAddTarget(_ baseVc: BaseViewController) {
        recordBtn.rx.tap.subscribe { [weak self] _ in
            guard let `self` = self else { return }
            let vc = UIStoryboard.loadRecordVC(model: self.viewModel.recordModel.value)
            baseVc.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: bag)
    }
    
    func addNewBtnAddTarget(_ baseVc: MenuViewController) {
        addNewBtn.rx.tap.subscribe { [weak self] _ in
            guard let `self` = self else { return }
            let model = viewModel.menuModel.value
            guard model.count > 0 else { return }
            let menu: [MenuStrModel] = MenuStrModel().getAry(model)
            let vc = UIStoryboard.loadAddVC(delegate: baseVc, menu: menu)
            baseVc.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: bag)
    }
    
    func checkoutBtnAddTarget(_ baseVc: BaseViewController) {
        checkoutBtn.rx.tap.subscribe { _ in
            baseVc.addToast(txt: "已通知服務員，請稍候".twEng())
            let table = SuShiSingleton.share().getPassword()
            StarscreamWebSocketManager.shard.writeMsg("桌號\(table) 結帳")
        }.disposed(by: bag)
    }
    
    func serviceBtnAddTarget(_ baseVc: BaseViewController) {
        serviceBtn.rx.tap.subscribe { _ in
            baseVc.addToast(txt: "已通知服務員，請稍候".twEng())
            let table = SuShiSingleton.share().getPassword()
            StarscreamWebSocketManager.shard.writeMsg("桌號\(table) 服務")
        }.disposed(by: bag)
    }
}
