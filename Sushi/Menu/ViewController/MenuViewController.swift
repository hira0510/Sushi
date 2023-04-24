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
        request()
        views.setupCollectionView(self)
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.isLogin.accept(SuShiSingleton.share().getIsLogin())
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
        })
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    private func setupUI() {
        views.loginBtn.addTarget(self, action: #selector(clickLoginBtn), for: .touchUpInside)
        views.addNewBtn.addTarget(self, action: #selector(clickAddNewBtn), for: .touchUpInside)
    }
    
    private func request() {
        viewModel.request().subscribe(onNext: { [weak self] (result) in
            guard let `self` = self, result else { return }
            self.views.menuCollectionView.reloadData()
            self.views.sushiCollectionView.reloadData()
        }).disposed(by: bag)
    }
    
    @objc func clickLoginBtn() {
        let vc = UIStoryboard.loadLoginVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func clickAddNewBtn() {
        let model = viewModel.menuModel.value
        guard model.count > 0 else { return }
        let menu: [MenuStrModel] = MenuStrModel().getAry(model)
        let vc = UIStoryboard.loadAddVC(menu: menu)
        self.navigationController?.pushViewController(vc, animated: true)
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
        case .sushi: break
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
            return UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        }
    }
}
