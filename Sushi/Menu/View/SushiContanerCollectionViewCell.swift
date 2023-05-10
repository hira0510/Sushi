//
//  SushiContanerCollectionViewCell.swift
//  Sushi
//
//  Created by Hira on 2023/5/9.
//

import UIKit
import RxSwift
import RxCocoa

protocol SushiContanerCellToMenuVcProtocol: AnyObject {
    func pushToAddVC(index: Int, sushi: SushiModel)
    func pushToOrderVC(sushi: SushiModel)
    func updateMenuModel(removeIndex: Int, insertIndex: Int, insertModel: SushiModel)
    func updateDeleteIndexAry(_ indexPath: [IndexPath])
}

class SushiContanerCollectionViewCell: BaseCollectionViewCell {

    @IBOutlet weak var sushiCollectionView: UICollectionView!

    private var selectItem: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)
    private var sushiCollectionFrame: BehaviorRelay<CGRect> = BehaviorRelay<CGRect>(value: .zero)
    private var isNotEdit: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: true)
    private var layoutType: BehaviorRelay<ToggleLayoutView.LayoutType> = BehaviorRelay<ToggleLayoutView.LayoutType>(value: .grid)
    private var deleteIndexAry: BehaviorRelay<[IndexPath]> = BehaviorRelay<[IndexPath]>(value: [])

    private var sushiModel: [SushiModel] = []
    private weak var delegate: SushiContanerCellToMenuVcProtocol?

    static var nib: UINib {
        return UINib(nibName: "SushiContanerCollectionViewCell", bundle: Bundle(for: self))
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
        bindBehaviorRelay()
    }

    func cellConfig(model: [SushiModel], frame: CGRect, color: UIColor, delegate: SushiContanerCellToMenuVcProtocol) {
        self.backgroundColor = color
        self.sushiModel = model
        self.delegate = delegate
        self.sushiCollectionFrame.accept(frame)
    }
    
    func bindData(select: BehaviorRelay<Int>, layoutType: BehaviorRelay<ToggleLayoutView.LayoutType>, frame: BehaviorRelay<CGRect>, isNotEdit: BehaviorRelay<Bool>, deleteAry: BehaviorRelay<[IndexPath]>) {
        select.bind(to: self.selectItem).disposed(by: bag)
        layoutType.bind(to: self.layoutType).disposed(by: bag)
        isNotEdit.bind(to: self.isNotEdit).disposed(by: bag)
        frame.bind(to: self.sushiCollectionFrame).disposed(by: bag)
        deleteAry.bind(to: self.deleteIndexAry).disposed(by: bag)
    }

    /// 初始CollectionView
    private func setupCollectionView() {
        sushiCollectionView.delegate = self
        sushiCollectionView.dataSource = self
        sushiCollectionView.dragDelegate = self
        sushiCollectionView.dropDelegate = self
        sushiCollectionView.register(SushiCollectionViewCell.nib, forCellWithReuseIdentifier: "SushiCollectionViewCell")
        sushiCollectionView.register(SushiLinearCollectionViewCell.nib, forCellWithReuseIdentifier: "SushiLinearCollectionViewCell")
    }

    private func bindBehaviorRelay() {
        //如果[indexPath]為空就取消全選
        self.deleteIndexAry.bind(to: sushiCollectionView.rx.cancelAllSelect).disposed(by: bag)
        //Server編輯時可多選＆可拖曳
        self.isNotEdit.bind(to: sushiCollectionView.rx.allowsMultipleSelection).disposed(by: bag)
        //切換頁面移至Top
        self.selectItem.bind(to: sushiCollectionView.rx.sushiScrollTop).disposed(by: bag)
        //Client結帳後不可點餐
        SuShiSingleton.share().bindIsCheckout().bind(to: sushiCollectionView.rx.allowsSelection).disposed(by: bag)
        //手機更換方向時重整collectionView
        Observable.combineLatest(SuShiSingleton.share().bindIsEng(), selectItem, layoutType, isNotEdit, sushiCollectionFrame) { _, _, _, _, frame -> CGRect in
            return frame
        }.map { $0 }.bind(to: sushiCollectionView.rx.reloadData).disposed(by: bag)
    }

    private func getColumn() -> Int {
        if GlobalUtil.isPortrait() {
            return layoutType.value == .grid ? 2 : 1
        } else {
            return layoutType.value == .grid ? 4 : 2
        }
    }

    private func getRow() -> Int {
        GlobalUtil.isPortrait() ? 4 : 2
    }

    /// 拿取cell的寬高
    private func getCellSize() -> CGSize {
        let wSpace = 10.0
        //h
        let cellSpaceHeight: CGFloat = wSpace * (getRow().toCGFloat - 1)
        let cellAllHeight: CGFloat = floor(sushiCollectionFrame.value.height - 15) - cellSpaceHeight
        let cellMaxHeight: CGFloat = (cellAllHeight / getRow().toCGFloat).rounded(.down)
        //w
        let cellSpaceWidth: CGFloat = wSpace * (getColumn().toCGFloat - 1)
        let cellAllWidth: CGFloat = floor(sushiCollectionFrame.value.width - 20) - cellSpaceWidth
        let cellMaxWidth: CGFloat = (cellAllWidth / getColumn().toCGFloat).rounded(.down)

        return CGSize(width: cellMaxWidth, height: cellMaxHeight)
    }
}

// MARK: - CollectionView
extension SushiContanerCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sushiModel.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let isSelect = !isNotEdit.value && deleteIndexAry.value.contains(indexPath)
        switch layoutType.value {
        case .grid:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SushiCollectionViewCell", for: indexPath) as! SushiCollectionViewCell
            guard sushiModel.count > indexPath.item else { return cell }
            cell.cellConfig(model: sushiModel[indexPath.item], isSelect: isSelect)
            cell.isSelectChangeBg(isSelect)
            return cell
        case .linear:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SushiLinearCollectionViewCell", for: indexPath) as! SushiLinearCollectionViewCell
            guard sushiModel.count > indexPath.item else { return cell }
            cell.cellConfig(model: sushiModel[indexPath.item], isSelect: isSelect)
            cell.isSelectChangeBg(isSelect)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isNotEdit.value {
            let sushi = sushiModel[indexPath.item]
            if SuShiSingleton.share().getIsAdmin() {
                delegate?.pushToAddVC(index: indexPath.item, sushi: sushi)
            } else {
                delegate?.pushToOrderVC(sushi: sushi)
            }
        } else {
            let cell = collectionView.cellForItem(at: indexPath) as! BaseCollectionViewCell
            cell.isSelectChangeBg(true)
            delegate?.updateDeleteIndexAry(unwrap(collectionView.indexPathsForSelectedItems, []))
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return getCellSize()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 8, bottom: 20, right: 8)
    }

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        //可用indexpath判断某section或某item是否可拖动,若不可拖动则返回空数组
        let dragItem = UIDragItem(itemProvider: NSItemProvider(object: "\(indexPath)" as NSString))
        dragItem.localObject = sushiModel[indexPath.item]
        return [dragItem]
    }

    //拖着移动时-可选实现，但一般都实现，频繁调用，代码尽可能快速简单执行
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        //若需实现section间不可拖拽的功能:可定全局变量dragingIndexPath(拖拽起始位置)，在itemsForBeginning中赋值为indexPath，然后对比他的section是否等于destinationIndexPath(拖拽结束位置)的section，若不等于则返回forbidden，

        //可用session.localDragSession来判断是否在同一app中操作
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }

    // 添加拖动的任务
    // 下面的代码，一次拖动一个
    // 可以通过这个方法，开始拖动后，继续添加拖动的任务
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        let data = sushiModel[indexPath.item]
        let itemProvider = NSItemProvider(object: "\(indexPath)" as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = data
        return [dragItem]
    }

    // 放下cell时（手指离开屏幕）
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        if let _ = coordinator.destinationIndexPath, case UIDropOperation.move = coordinator.proposal.operation {
            let items = coordinator.items
            if items.count == 1, let item = items.first, //拖拽单个
                let sourceIndexPath = item.sourceIndexPath,
                let destinationIndexPath = coordinator.destinationIndexPath {

                //将多个操作合并为一个动画
                let data = item.dragItem.localObject as! SushiModel
                delegate?.updateMenuModel(removeIndex: sourceIndexPath.item, insertIndex: destinationIndexPath.item, insertModel: data)
                collectionView.performBatchUpdates ({
                    sushiModel.remove(at: sourceIndexPath.item)
                    sushiModel.insert(data, at: destinationIndexPath.item)
                    collectionView.deleteItems(at: [sourceIndexPath])
                    collectionView.insertItems(at: [destinationIndexPath])
                })
                //固定操作,让拖拽变得自然
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            }
        }
    }
}
