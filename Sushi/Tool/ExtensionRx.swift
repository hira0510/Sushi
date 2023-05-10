//
//  ExtensionReactive.swift
//  Sushi
//
//  Created by Hira on 2023/4/28.
//

import UIKit
import RxSwift
import RxCocoa

// MARK: - 綁定Button
extension Reactive where Base: UIButton {

    var btnIsEnable: Binder<Int> {
        get {
            return Binder(self.base) { btn, count in
                btn.isEnabled = count > 0
            }
        }
    }

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

// MARK: - 綁定View
extension Reactive where Base: UIView {
    /// View是否隱藏
    var orderIsHidden: Binder<[SushiModel]> {
        get {
            return Binder(self.base) { view, model in
                view.isHidden = model.count <= 0
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

    var orderText: Binder<Int> {
        get {
            return Binder(self.base) { lebel, count in
                lebel.text = count.toStr
            }
        }
    }

    var countText: Binder<[SushiRecordModel]> {
        get {
            return Binder(self.base) { label, model in
                label.text = "\(model.count)"
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
    
    var reloadOrderData: Binder<[SushiModel]> {
        get {
            return Binder(self.base) { collectionView, _ in
                collectionView.reloadData()
            }
        }
    }

    var allowsMultipleSelection: Binder<Bool> {
        get {
            return Binder(self.base) { collectionView, isNotEdit in
                collectionView.dragInteractionEnabled = !isNotEdit
                collectionView.allowsMultipleSelection = !isNotEdit
            }
        }
    }

    var allowsSelection: Binder<Bool> {
        get {
            return Binder(self.base) { collectionView, isNotEdit in
                collectionView.allowsSelection = !isNotEdit
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
    
    var sushiScrollContentOffset: Binder<CGFloat> {
        get {
            return Binder(self.base) { collectionView, x in
                collectionView.contentOffset = CGPoint(x: x, y: 0)
            }
        }
    }
    
    /// Server取消選中所有被選中的cell
    var cancelAllSelect: Binder<[IndexPath]> {
        get {
            return Binder(self.base) { collectionView, indexAry in
                guard indexAry.isEmpty else { return }
                var indexPathArr = unwrap(collectionView.indexPathsForSelectedItems, [])
                for indexpah in indexPathArr {
                    let cell = collectionView.cellForItem(at: indexpah) as! BaseCollectionViewCell
                    cell.isSelectChangeBg(false)
                    collectionView.deselectItem(at: indexpah, animated: true)//取消选中的状态
                    indexPathArr = (collectionView.indexPathsForSelectedItems)!//所有被选中的cell的indexpath
                }
            }
        }
    }
}

// MARK: - 綁定UITableView
extension Reactive where Base: UITableView {
    var reloadData: Binder<ServerViewType> {
        get {
            return Binder(self.base) { tableView, _ in
                tableView.toReloadData()
            }
        }
    }
    var reloadDatas: Binder<[SushiRecordModel]> {
        get {
            return Binder(self.base) { tableView, _ in
                tableView.toReloadData()
            }
        }
    }
}

// MARK: - Array
extension BehaviorRelay where Element: RangeReplaceableCollection {
    func append(_ subElement: Element.Element) {
        var newValue = self.value
        newValue.append(subElement)
        accept(newValue)
    }
    
    func add(_ element: Element) {
        let array = self.value + element
        self.accept(array)
    }

    func remove(at index: Element.Index) {
        var newValue = self.value
        newValue.remove(at: index)
        accept(newValue)
    }

    func removeAll() {
        var newValue = self.value
        newValue.removeAll()
        accept(newValue)
    }
    
    func insert(_ newElement: Element.Element, at index: Element.Index) {
        var value = self.value
        value.insert(newElement, at: index)
        accept(value)
    }
}
