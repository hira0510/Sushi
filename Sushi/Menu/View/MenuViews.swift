//
//  MenuViews.swift
//  Sushi
//
//  Created by admin on 2023/4/20.
//

import UIKit
import RxSwift
import RxCocoa

class MenuViews: NSObject {
    public var viewModel: MenuViewModel!
    public var bag: DisposeBag!

    @IBOutlet weak var sushiCollectionView: UICollectionView! {
        didSet {
            viewModel.selectItem.bind(to: sushiCollectionView.rx.sushiScrollTop).disposed(by: bag)
            viewModel.isNotEdit.bind(to: sushiCollectionView.rx.allowsMultipleSelection).disposed(by: bag)
            
            Observable.combineLatest(viewModel.selectItem, viewModel.menuModel) { index, model -> UIColor in
                return model.count > 0 ? UIColor(hexString: model[index].color) ?? .clear: .clear
            }.map { $0 }.bind(to: sushiCollectionView.rx.backgroundColor).disposed(by: bag)
            
            Observable.combineLatest(viewModel.selectItem, viewModel.sushiCollectionFrame, viewModel.isEng) { index, _, _ -> Int in
                return index
            }.map { $0 }.bind(to: sushiCollectionView.rx.reloadData).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var menuCollectionView: UICollectionView! {
        didSet {
            viewModel.selectItem.bind(to: menuCollectionView.rx.menuScrollIndex).disposed(by: bag)
            
            Observable.combineLatest(viewModel.selectItem, viewModel.sushiCollectionFrame, viewModel.isEng) { index, _, _ -> Int in
                return index
            }.map { $0 }.bind(to: menuCollectionView.rx.reloadData).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var languageInfoBtn: UIButton! {
        didSet {
            languageInfoBtn.rx.tap.asObservable().map { [weak self] _ -> Bool in
                guard let `self` = self else { return false }
                return !self.languageInfoBtn.isSelected
            }.do { [weak self] isSelect in
                guard let `self` = self else { return }
                self.viewModel.isEng.accept(isSelect)
                self.menuInfoView.updateUI(isEng: isSelect)
                self.plateInfoView.updateUI(isEng: isSelect)
                self.timeInfoView.updateUI(isEng: isSelect)
            }.bind(to: languageInfoBtn.rx.isSelected).disposed(by: bag)
        }
    }
    @IBOutlet weak var menuInfoView: MenuInfoView!
    @IBOutlet weak var plateInfoView: MenuInfoView!
    @IBOutlet weak var timeInfoView: MenuInfoView!
    
    @IBOutlet weak var loginLabel: UILabel! {
        didSet {
            viewModel.isLogin.bind(to: loginLabel.rx.labelIsHidden).disposed(by: bag)
        }
    }
    @IBOutlet weak var loginBtn: UIButton! {
        didSet {
            viewModel.isLogin.bind(to: loginBtn.rx.btnIsHidden).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var previousPageBtn: UIButton! {
        didSet {
            viewModel.isEng.bind(to: previousPageBtn.rx.isSelected).disposed(by: bag)
            
            previousPageBtn.rx.tap.subscribe { [weak self] event in
                guard let `self` = self else { return }
                guard self.viewModel.selectItem.value > 0 else { return }
                self.viewModel.selectItem.accept(self.viewModel.selectItem.value - 1)
            }.disposed(by: bag)
        }
    }
    
    @IBOutlet weak var nextPageBtn: UIButton! {
        didSet {
            viewModel.isEng.bind(to: nextPageBtn.rx.isSelected).disposed(by: bag)
            
            nextPageBtn.rx.tap.subscribe { [weak self] event in
                guard let `self` = self else { return }
                guard self.viewModel.selectItem.value < self.viewModel.menuModel.value.count - 1 else { return }
                self.viewModel.selectItem.accept(self.viewModel.selectItem.value + 1)
            }.disposed(by: bag)
        }
    }
    
    @IBOutlet weak var recordBtn: UIButton! {
        didSet {
            viewModel.isEng.bind(to: recordBtn.rx.isSelected).disposed(by: bag)
        }
    }
    @IBOutlet weak var serviceBtn: UIButton! {
        didSet {
            viewModel.isEng.bind(to: serviceBtn.rx.isSelected).disposed(by: bag)
        }
    }
    @IBOutlet weak var checkoutBtn: UIButton! {
        didSet {
            viewModel.isEng.bind(to: checkoutBtn.rx.isSelected).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var addNewBtn: NGSCustomizableButton! {
        didSet {
            viewModel.isLogin.bind(to: addNewBtn.rx.addBtnIsHidden).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var editBtn: UIButton! {
        didSet {
            viewModel.isLogin.bind(to: editBtn.rx.addBtnIsHidden).disposed(by: bag)
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
    
    func clickDeleteItemBtn(_ vc: MenuViewController) {
        deleteItemBtn.rx.tap.subscribe { [weak self] event in
            guard let `self` = self else { return }
            let indexPathArr = self.sushiCollectionView.indexPathsForSelectedItems ?? []
            guard indexPathArr.count > 0 else { return }
            vc.addToast(txt: "刪除中...")
            
            Observable.from(indexPathArr).enumerated().flatMap { indexPath -> Observable<Int> in
                return vc.delData(indexPath.element.item)
            }.subscribe(onNext: { [weak self] index in
                guard let `self` = self, index == indexPathArr.last?.item else { return }
                vc.removeToast()
                vc.addToast(txt: "刪除成功")
                vc.request()
                self.cancelSelect()
                self.viewModel.isNotEdit.accept(true)
            }).disposed(by: bag)
        }.disposed(by: bag)
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
}
// MARK: - 綁定Button
extension Reactive where Base: UIButton {
    /// 按鈕是否隱藏
    var btnIsHidden: Binder<IsLoginModel> {
        get {
            return Binder(self.base) { btn, loginModel in
                btn.isHidden = loginModel.isLogin
            }
        }
    }
    var btnIsSelect: Binder<Bool> {
        get {
            return Binder(self.base) { btn, bool in
                btn.isSelected = !bool
            }
        }
    }
    /// 按鈕是否隱藏
    var addBtnIsHidden: Binder<IsLoginModel> {
        get {
            return Binder(self.base) { btn, loginModel in
                btn.isHidden = !(loginModel.isLogin && loginModel.type == .administrator)
            }
        }
    }
}

// MARK: - 綁定Label
extension Reactive where Base: UILabel {
    /// Label是否隱藏
    var labelIsHidden: Binder<IsLoginModel> {
        get {
            return Binder(self.base) { label, loginModel in
                var text = "Version:\(SystemInfo.getVersion())"
                if loginModel.type == .administrator {
                    text += "\nuser:\(loginModel.account)"
                }
                label.isHidden = !loginModel.isLogin
                label.text = text
            }
        }
    }
}

// MARK: - 綁定UICollectionView
extension Reactive where Base: UICollectionView {
    var reloadData: Binder<Any> {
        get {
            return Binder(self.base) { collectionView, _ in
                collectionView.reloadData()
            }
        }
    }
    
    var allowsMultipleSelection: Binder<Bool> {
        get {
            return Binder(self.base) { collectionView, isNotEdit in 
                collectionView.allowsMultipleSelection = !isNotEdit
            }
        }
    }
    
    var sushiScrollTop: Binder<Int> {
        get {
            return Binder(self.base) { collectionView, _ in
                guard collectionView.visibleCells.count > 0 else { return }
                collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredVertically, animated: false)
            }
        }
    }
    
    var menuScrollIndex: Binder<Int> {
        get {
            return Binder(self.base) { collectionView, index in
                guard collectionView.visibleCells.count > 0 else { return }
                collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
    }
}
