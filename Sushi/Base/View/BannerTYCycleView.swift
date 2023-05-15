//
//  BannerTYCycleView.swift
//  Sushi
//
//  Created by Hira on 2023/5/11.
//

import UIKit
import TYCyclePagerView
import RxCocoa
import RxSwift

protocol BannerTYCycleViewProtocol: AnyObject {
    func didClickCycleCell(_ url: String)
}

class BannerTYCycleView: BaseView {

    @IBOutlet weak var mView: UIView!

    private var lastContentOffsetX: CGFloat = 0
    private var pagerView: TYCyclePagerView!
    private var mBannerData: BehaviorRelay<[AdModel]> = BehaviorRelay<[AdModel]>(value: [])
    private weak var delegate: BannerTYCycleViewProtocol?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    private func commonInit() {
        loadNibContent()

        self.pagerView = TYCyclePagerView()
        self.pagerView.isInfiniteLoop = true
        self.pagerView.autoScrollInterval = 5.0
        self.pagerView.dataSource = self
        self.pagerView.delegate = self
        self.pagerView.register(TYCycleCell.nib, forCellWithReuseIdentifier: "TYCycleCell")
        self.pagerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.mView.frame.height)
        mView.addSubview(self.pagerView)

        let dataObs: Binder<[AdModel]> = Binder(self) { [weak self] _, _ in
            guard let `self` = self else { return }
            self.loadData()
        }
        mBannerData.bind(to: dataObs).disposed(by: bag)
    }

    public func setupView(adData: BehaviorRelay<[AdModel]>, delegate: BannerTYCycleViewProtocol) {
        self.delegate = delegate
        adData.bind(to: mBannerData).disposed(by: bag)
        loadData()
    }

    private func loadData() {
        self.pagerView.reloadData()
        self.pagerView.layout.layoutType = .linear
        self.pagerView.setNeedUpdateLayout()
    }
}

// MARK: - TYCyclePagerViewDelegate
extension BannerTYCycleView: TYCyclePagerViewDelegate, TYCyclePagerViewDataSource {
    func numberOfItems(in pageView: TYCyclePagerView) -> Int {
        return mBannerData.value.count
    }

    func pagerView(_ pagerView: TYCyclePagerView, cellForItemAt index: Int) -> UICollectionViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "TYCycleCell", for: index) as! TYCycleCell
        cell.configCell(mBannerData.value[index].imgUrl)
        return cell
    }

    func layout(for pageView: TYCyclePagerView) -> TYCyclePagerViewLayout {
        let layout = TYCyclePagerViewLayout()
        layout.itemSize = CGSize(width: pagerView.frame.width * 0.9, height: pagerView.frame.height * 1)
        layout.itemSpacing = 8
        layout.itemHorizontalCenter = true

        return layout
    }

    func pagerView(_ pageView: TYCyclePagerView, didSelectedItemCell cell: UICollectionViewCell, at index: Int) {
        delegate?.didClickCycleCell(mBannerData.value[index].url)
    }

    func pagerView(_ pageView: TYCyclePagerView, didScrollFrom fromIndex: Int, to toIndex: Int) {
        let scrollView = pageView
        let toIndexPath: IndexPath = IndexPath(item: pageView.indexSection.index, section: pageView.indexSection.section)
        var fromIndexPath: IndexPath = IndexPath(item: pageView.indexSection.index, section: pageView.indexSection.section)
        // 畫面向右滑動
        if scrollView.contentOffset.x <= 0 || (lastContentOffsetX > scrollView.contentOffset.x) {
            if toIndexPath.item == mBannerData.value.count - 1 {
                fromIndexPath.item = 0
                fromIndexPath.section += 1
            } else {
                fromIndexPath.item = toIndexPath.item + 1
            }
        // 畫面向左滑動
        } else if lastContentOffsetX < scrollView.contentOffset.x {
            if toIndexPath.item == 0 {
                fromIndexPath.item = mBannerData.value.count - 1
                fromIndexPath.section -= 1
            } else {
                fromIndexPath.item = fromIndexPath.item - 1
            }
        }
        
        let fromCell = pagerView.collectionView?.cellForItem(at: fromIndexPath) as? TYCycleCell
        fromCell?.whenScrollStopVideo()

        let toCell = pagerView.collectionView?.cellForItem(at: toIndexPath) as? TYCycleCell
        toCell?.whenScrollPlayVideo()
        
        lastContentOffsetX = scrollView.contentOffset.x
    }
}
