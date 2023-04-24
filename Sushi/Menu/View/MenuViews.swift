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
            Observable.combineLatest(viewModel.selectItem, viewModel.menuModel) { index, model -> UIColor in
                return model.count > 0 ? UIColor(hexString: model[index].color) ?? .clear: .clear
            }.map { $0 }.bind(to: sushiCollectionView.rx.backgroundColor).disposed(by: bag)
            
            Observable.combineLatest(viewModel.selectItem, viewModel.sushiCollectionFrame) { index, _ -> Int in
                return index
            }.map { $0 }.bind(to: sushiCollectionView.rx.reloadData).disposed(by: bag)
        }
    }
    @IBOutlet weak var menuCollectionView: UICollectionView! {
        didSet {
            Observable.combineLatest(viewModel.selectItem, viewModel.sushiCollectionFrame) { index, _ -> Int in
                return index
            }.map { $0 }.bind(to: menuCollectionView.rx.reloadData).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var addNewBtn: NGSCustomizableButton! {
        didSet {
            viewModel.isLogin.bind(to: addNewBtn.rx.addBtnIsHidden).disposed(by: bag)
        }
    }
    @IBOutlet weak var languageInfoBtn: UIButton!
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
    
    @IBOutlet weak var previousPageBtn: UIButton!
    @IBOutlet weak var nextPageBtn: UIButton!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var serviceBtn: UIButton!
    @IBOutlet weak var checkoutBtn: UIButton!
    
    func setupCollectionView(_ vc: MenuViewController) {
        menuCollectionView.delegate = vc
        menuCollectionView.dataSource = vc
        menuCollectionView.register(MenuTitleCollectionViewCell.nib, forCellWithReuseIdentifier: "MenuTitleCollectionViewCell")
        sushiCollectionView.delegate = vc
        sushiCollectionView.dataSource = vc
        sushiCollectionView.register(SushiCollectionViewCell.nib, forCellWithReuseIdentifier: "SushiCollectionViewCell")
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
}
