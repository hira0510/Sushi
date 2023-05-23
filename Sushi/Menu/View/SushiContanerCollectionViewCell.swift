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
    func isCollectionViewScroll(_ embar: Bool)
}

class SushiContanerCollectionViewCell: BaseCollectionViewCell {
    enum cellType {
        case normal_1x1, linear_2x1, big_2x2
        static func getType(_ str: String) -> cellType {
            switch str {
            case "2x2": return .big_2x2
            case "2x1": return .linear_2x1
            default: return .normal_1x1
            }
        }
    }

    @IBOutlet weak var sushiCollectionView: UICollectionView!
    
    private let cellSpacing: CGFloat = 10
    private let collectionSpacing: CGFloat = 10
    
    private weak var delegate: SushiContanerCellToMenuVcProtocol?
    private var selectItem: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)
    private var sushiCollectionFrame: BehaviorRelay<CGRect> = BehaviorRelay<CGRect>(value: .zero)
    private var isNotEdit: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: true)
    private var isCanMultiple: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: true)
    private var isCanDrag: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: true)
    private var deleteIndexAry: BehaviorRelay<[IndexPath]> = BehaviorRelay<[IndexPath]>(value: [])

    private var dropToIndex: (from: Int, to: Int) = (-1, -1)
    private var sushiModel: [SushiModel] = []
    private var firstInit: Bool = true
    private var columnCount: Int {
        get {
            return GlobalUtil.isPortrait() ? 2 : 4
        }
    }
    private var rowCount: Int {
        get {
            return GlobalUtil.isPortrait() ? 4 : 2
        }
    }
    
    static var nib: UINib {
        return UINib(nibName: "SushiContanerCollectionViewCell", bundle: Bundle(for: self))
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("🫠layoutSubviews🫠")
        resetLayout()
    }

// MARK: - public
    
    public func cellConfig(model: [SushiModel], color: UIColor, delegate: SushiContanerCellToMenuVcProtocol) {
        self.backgroundColor = color
        self.sushiModel = model
        self.delegate = delegate
        self.sushiCollectionView.reloadData()
    }

    /// 套件需要重整layout
    public func setupCollecctionViewFrame(_ frame: CGRect) {
        self.sushiCollectionView.frame = CGRect(x: frame.minX + collectionSpacing, y: frame.minY + collectionSpacing, width: frame.width - (2 * collectionSpacing), height: frame.height - (2 * collectionSpacing))

        if let layout = sushiCollectionView.collectionViewLayout as? ZLCollectionViewVerticalLayout {
            layout.cellSize = NSMutableArray(array: setSushiSizeModel().map { NSValue(cgSize: $0) })
        }
    }

    public func bindData(select: BehaviorRelay<Int>, frame: BehaviorRelay<CGRect>, isNotEdit: BehaviorRelay<Bool>, deleteAry: BehaviorRelay<[IndexPath]>) {
        if firstInit {
            firstInit = false
            bindBehaviorRelay()
            select.bind(to: self.selectItem).disposed(by: bag)
            isNotEdit.bind(to: self.isNotEdit).disposed(by: bag)
            frame.bind(to: self.sushiCollectionFrame).disposed(by: bag)
            deleteAry.bind(to: self.deleteIndexAry).disposed(by: bag)
        }
    }

    /// 點擊上下頁顯示其他項目
    /// - Parameter isNext: 是否是點擊下一頁
    /// - Returns: 是否成功顯示其他項目，否則換一頁
    public func isScrollNotVisibleItems(_ isNext: Bool) -> Bool {
        guard sushiCollectionView != nil, !sushiModel.isEmpty else { return false }
        if let max = sushiCollectionView.indexPathsForVisibleItems.max(), isNext && sushiModel.count > max.item + 1 {
            self.sushiCollectionView.scrollToItem(at: IndexPath(item: max.item + 1, section: max.section), at: .top, animated: true)
            return true
        } else if let min = sushiCollectionView.indexPathsForVisibleItems.min(), !isNext && min.item != 0 {
            self.sushiCollectionView.scrollToItem(at: IndexPath(item: min.item - 1, section: min.section), at: .bottom, animated: true)
            return true
        } else {
            return false
        }
    }

// MARK: - private
    /// 初始CollectionView
    private func setupCollectionView() {
        sushiCollectionView.delegate = self
        sushiCollectionView.dataSource = self
        sushiCollectionView.dragDelegate = self
        sushiCollectionView.dropDelegate = self
        sushiCollectionView.reorderingCadence = .fast
        sushiCollectionView.register(SushiCollectionViewCell.nib, forCellWithReuseIdentifier: "SushiCollectionViewCell")
        sushiCollectionView.register(SushiLinearCollectionViewCell.nib, forCellWithReuseIdentifier: "SushiLinearCollectionViewCell")

        let layout = ZLCollectionViewVerticalLayout()
        layout.minimumLineSpacing = cellSpacing
        layout.minimumInteritemSpacing = cellSpacing
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.delegate = self
        layout.isNeedReCalculateAllLayout = true
        sushiCollectionView.collectionViewLayout = layout
    }

    private func bindBehaviorRelay() {
        //如果[indexPath]為空就取消全選
        self.deleteIndexAry.bind(to: sushiCollectionView.rx.cancelAllSelect).disposed(by: bag)
        //切換頁面移至Top
        self.selectItem.bind(to: sushiCollectionView.rx.sushiScrollTop).disposed(by: bag)
        //Client結帳後不可點餐
        SuShiSingleton.share().bindIsCheckout().bind(to: sushiCollectionView.rx.allowsSelection).disposed(by: bag)
        //切換語言或編輯時reload
        SuShiSingleton.share().bindIsEng().bind(to: sushiCollectionView.rx.reloadDatas).disposed(by: bag)

        //多選時不拖曳，拖曳時不多選
        Observable.combineLatest(isCanMultiple, isCanDrag).subscribe(onNext: { [weak self] multiple, drag in
            guard let `self` = self else { return }
            self.sushiCollectionView.dragInteractionEnabled = drag
            self.sushiCollectionView.allowsMultipleSelection = multiple
        }).disposed(by: self.bag)
        //Server編輯時可多選＆可拖曳
        let isNotEditObs: Binder<Bool> = Binder(sushiCollectionView) { [weak self] collectionView, isNotEdit in
            guard let `self` = self else { return }
            if isNotEdit {
                self.delegate?.updateDeleteIndexAry([])
            }
            collectionView.dragInteractionEnabled = !isNotEdit
            collectionView.allowsMultipleSelection = !isNotEdit
        }
        isNotEdit.bind(to: isNotEditObs).disposed(by: bag)
    }

    /// 拿取cell的寬高
    private func getCellSize() -> CGSize {
        //h
        let rowCount = rowCount.toCGFloat
        let cellSpaceHeight: CGFloat = cellSpacing * (rowCount - 1)
        let cellAllHeight: CGFloat = floor(sushiCollectionFrame.value.height - (2*collectionSpacing)) - cellSpaceHeight
        let cellMaxHeight: CGFloat = (cellAllHeight / rowCount).rounded(.down)
        //w
        let columnCount = columnCount.toCGFloat
        let cellSpaceWidth: CGFloat = cellSpacing * (columnCount - 1)
        let cellAllWidth: CGFloat = floor(sushiCollectionFrame.value.width - (2*collectionSpacing)) - cellSpaceWidth
        let cellMaxWidth: CGFloat = (cellAllWidth / columnCount).rounded(.down)

        return CGSize(width: cellMaxWidth, height: cellMaxHeight)
    }

    /// 拿取放大後cell的寬高
    private func getScaleCellSize(_ type: cellType) -> CGSize {
        var size = getCellSize()
        if type == .linear_2x1 || type == .big_2x2 {
            size.width = size.width * 2 + cellSpacing
        }
        if type == .big_2x2 {
            size.height = size.height * 2 + cellSpacing
        }
        return size
    }
    
    private func setSushiSizeModel() -> [CGSize] {
        let sizes = sushiModel.map { $0.size }
        let types = sizes.map { cellType.getType($0) }
        let sizeAry = types.map { getScaleCellSize($0) }
        return sizeAry
    }

    /// 重新整理layout
    private func resetLayout() {
        print("🫠resetLayout🫠")
        DispatchQueue.main.async {
            if let layout = self.sushiCollectionView.collectionViewLayout as? ZLCollectionViewVerticalLayout {
                layout.cellSize = NSMutableArray(array: self.setSushiSizeModel().map { NSValue(cgSize: $0) })
                self.sushiCollectionView.performBatchUpdates({ }, completion: nil)
            }
        }
    }
}

// MARK: - CollectionView
extension SushiContanerCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sushiModel.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let isSelect = !isNotEdit.value && deleteIndexAry.value.contains(indexPath)
        let isHaveData = sushiModel.count > indexPath.item
        let type = isHaveData ? cellType.getType(sushiModel[indexPath.item].size) : .normal_1x1
        switch type {
        case .normal_1x1, .big_2x2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SushiCollectionViewCell", for: indexPath) as! SushiCollectionViewCell
            guard sushiModel.count > indexPath.item else { return cell }
            cell.cellConfig(model: sushiModel[indexPath.item], isSelect: isSelect)
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SushiLinearCollectionViewCell", for: indexPath) as! SushiLinearCollectionViewCell
            guard sushiModel.count > indexPath.item else { return cell }
            cell.cellConfig(model: sushiModel[indexPath.item], isSelect: isSelect)
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
            isCanDrag.accept(unwrap(collectionView.indexPathsForSelectedItems?.count, 0) <= 0)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        isCanDrag.accept(unwrap(collectionView.indexPathsForSelectedItems?.count, 0) <= 0)
        delegate?.updateDeleteIndexAry(unwrap(collectionView.indexPathsForSelectedItems, []))
    }
}

// MARK: - CollectionView-Drop/Drag
extension SushiContanerCollectionViewCell: UICollectionViewDragDelegate, UICollectionViewDropDelegate {

    /// 開始拖曳
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider(object: "\(indexPath)" as NSString))
        dragItem.localObject = sushiModel[indexPath.item]
        dropToIndex = (indexPath.item, indexPath.item)
        return [dragItem]
    }

    /// 拖曳搬移
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        if originalIndexPath != proposedIndexPath {
            var sushiSizeModel = setSushiSizeModel()
            let removedSize = sushiSizeModel.remove(at: dropToIndex.from)
            sushiSizeModel.insert(removedSize, at: proposedIndexPath.item)
            // 這邊只重新設定size而已，因為func會自動跑prepare()
            if let layout = collectionView.collectionViewLayout as? ZLCollectionViewVerticalLayout {
                layout.cellSize = NSMutableArray(array: sushiSizeModel.map { NSValue(cgSize: $0) })
            }
            dropToIndex = (dropToIndex.from, proposedIndexPath.item)
            print("🫠targetIndexPathForMoveFromItemAt🫠")
        }
        return proposedIndexPath
    }

    /// 拖曳超過邊界
    func collectionView(_ collectionView: UICollectionView, dropSessionDidExit session: UIDropSession) {
        guard dropToIndex.to >= 0 && dropToIndex.from != dropToIndex.to else { return }
        resetLayout()
    }

    /// 拖曳結束
    func collectionView(_ collectionView: UICollectionView, dropSessionDidEnd session: UIDropSession) {
        isCanMultiple.accept(true)
        delegate?.isCollectionViewScroll(false)
        print("🫠End🫠")

    }

    /// 拖着移动时(频繁调用)
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        /*拖動後無法多選item，父collection也不能滑動(防止多選一起拖曳&拖曳到別的collectionview)；
         本來想把這段放在itemsForBeginning，但發現原地放下item的話 並不會觸發dropSessionDidEnd，所以寫在拖動的這一瞬間*/
        if isCanMultiple.value {
            isCanMultiple.accept(false)
            delegate?.isCollectionViewScroll(true)
        }

        guard session.items.count == 1 else {
            return .init(operation: .cancel)
        }

        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }

    /// 放下cell时（手指离开屏幕）
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        print("🫠performDropWith🫠")
        if let _ = coordinator.destinationIndexPath, coordinator.proposal.operation == .move {
            print("🫠performDropWith in????🫠")
            let items = coordinator.items
            if items.count == 1, let item = items.first, //拖拽单个
                let fromIndexPath = item.sourceIndexPath,
                let toIndexPath = coordinator.destinationIndexPath,
                let data = item.dragItem.localObject as? SushiModel,
                sushiModel[toIndexPath.item] != data {

                self.delegate?.updateMenuModel(removeIndex: fromIndexPath.item, insertIndex: toIndexPath.item, insertModel: data)
                //将多个操作合并为一个动画
                collectionView.performBatchUpdates ({
                    sushiModel.remove(at: fromIndexPath.item)
                    sushiModel.insert(data, at: toIndexPath.item)
                    collectionView.deleteItems(at: [fromIndexPath])
                    collectionView.insertItems(at: [toIndexPath])
                })
                //固定操作,让拖拽变得自然
                coordinator.drop(item.dragItem, toItemAt: toIndexPath)
                print("🫠performDropWith INININININNIn🫠")
            }
        }
    }
}

// MARK: - FlowLayout
extension SushiContanerCollectionViewCell: ZLCollectionViewBaseFlowLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, typeOfLayout section: Int) -> ZLLayoutType {
        return FillLayout
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, columnCountOfSection section: Int) -> Int {
        return columnCount
    }
}
