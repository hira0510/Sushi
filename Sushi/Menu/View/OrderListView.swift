//
//  OrderListView.swift
//  Sushi
//
//  Created by Hira on 2023/4/26.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

class OrderListView: UIView, NibOwnerLoadable {
     
    @IBOutlet weak var mStackView: UIStackView!
    @IBOutlet weak var openBtn: NGSCustomizableButton! {
        didSet {
            openBtn.rx.tap.asObservable().map { [weak self] _ -> Bool in
                guard let `self` = self else { return false }
                return !self.openBtn.isSelected
            }.do { [weak self] isSelect in
                guard let `self` = self else { return }
                self.delegate?.clickOpenBtn(isSelect)
                self.openBtn.RoundRatio = isSelect ? 0.1: 0.5 
                self.bgViewConstraint?.update(offset: isSelect ? 30: 2)
            }.bind(to: openBtn.rx.isSelected).disposed(by: bag)
        }
    }
    @IBOutlet weak var orderBtn: NGSCustomizableButton! {
        didSet {
            SuShiSingleton.share().bindIsEng().bind(to: orderBtn.rx.isSelected).disposed(by: bag)
            orderBtn.rx.tap.subscribe { [weak self] _ in
                guard let `self` = self else { return }
                self.delegate?.clickOrderBtn()
            }.disposed(by: bag)
        }
    }
    @IBOutlet weak var mCollectionView: UICollectionView! {
        didSet {
            mCollectionView.snp.makeConstraints { make in
                collectionWConstraint = make.width.equalTo(243).constraint
            }
            mModel.bind(to: mCollectionView.rx.reloadOrderData).disposed(by: bag)
        }
    }
    @IBOutlet weak var bgView: NGSCustomizableView!
    
    public var mModel: BehaviorRelay<[SushiModel]> = BehaviorRelay<[SushiModel]>(value: [])
    public var collectionWConstraint: Constraint? = nil
    private var bgViewConstraint: Constraint? = nil
    public weak var delegate: OrderListCellProtocol?
    
    private lazy var bag: DisposeBag! = {
        return DisposeBag()
    }()
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        loadNibContent()
        mCollectionView.register(OrderListCollectionViewCell.nib, forCellWithReuseIdentifier: "OrderListCollectionViewCell")
        mCollectionView.delegate = self
        mCollectionView.dataSource = self
        mCollectionView.reloadData()
    }
    
    func initView(order: BehaviorRelay<[SushiModel]>, delegate: OrderListCellProtocol? = nil) {
        if let delegate = delegate {
            self.delegate = delegate
        }
        order.bind(to: mModel).disposed(by: bag)
        order.bind(to: self.rx.orderIsHidden).disposed(by: bag)
        bgView.snp.makeConstraints { make in
            bgViewConstraint = make.right.equalTo(mStackView.snp.right).offset(30).constraint
        }
    }
}

extension OrderListView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mModel.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderListCollectionViewCell", for: indexPath) as! OrderListCollectionViewCell
        cell.cellConfig(model: mModel.value[indexPath.item], delegate: delegate)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.frame.height
        return CGSize(width: w, height: w)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
}

