//
//  OrderViewController.swift
//  Sushi
//
//  Created by Hira on 2023/4/26.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

protocol OrderVcProtocol: AnyObject {
    func sendOrder(model: [SushiModel])
}

class OrderViewController: BaseViewController {
    
    public let viewModel = OrderViewModel()
    public weak var delegate: OrderVcProtocol?
    
    @IBOutlet weak var mImageView: UIImageView!
    @IBOutlet weak var mTitleLabel: UILabel!
    @IBOutlet weak var previousBtn: UIButton! {
        didSet {
            previousBtn.rx.tap.subscribe { [weak self] event in
                guard let `self` = self else { return }
                self.previousBack()
            }.disposed(by: bag)
        }
    }
    @IBOutlet weak var countLabel: UILabel! {
        didSet {
            viewModel.orderCount.bind(to: countLabel.rx.orderText).disposed(by: bag)
        }
    }
    @IBOutlet weak var addBtn: UIButton! {
        didSet {
            addBtn.rx.tap.subscribe { [weak self] event in
                guard let `self` = self else { return }
                let count = self.viewModel.orderCount.value
                self.viewModel.orderCount.accept(count + 1)
            }.disposed(by: bag)
        }
    }
    @IBOutlet weak var subBtn: UIButton! {
        didSet {
            viewModel.orderCount.bind(to: subBtn.rx.btnIsEnable).disposed(by: bag)
            subBtn.rx.tap.subscribe { [weak self] event in
                guard let `self` = self else { return }
                let count = self.viewModel.orderCount.value
                self.viewModel.orderCount.accept(count - 1)
            }.disposed(by: bag)
        }
    }
    @IBOutlet weak var addOrderBtn: NGSCustomizableButton! {
        didSet {
            let textObs: Binder<Bool> = Binder(self) { vc, isEng in vc.addOrderBtn.setTitle("加入購物車".twEng(), for: .normal) }
            SuShiSingleton.share().bindIsEng().bind(to: textObs).disposed(by: bag)
            viewModel.orderCount.bind(to: addOrderBtn.rx.btnIsEnable).disposed(by: bag)
            addOrderBtn.rx.tap.subscribe { [weak self] event in
                guard let `self` = self else { return }
                let orderModel = Array(repeating: self.viewModel.sushiModel.value, count: self.viewModel.orderCount.value)
                self.delegate?.sendOrder(model: orderModel)
                self.previousBack()
            }.disposed(by: bag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(hexString: viewModel.bgColor)
        bind()
    }
    
    private func bind() {
        let modelObserver: Binder<SushiModel> = Binder(self) { [weak self] vc, model in
            guard let `self` = self else { return }
            if SuShiSingleton.share().getIsEng() {
                vc.mTitleLabel.text = model.titleEng
            } else {
                vc.mTitleLabel.attributedText = self.setAttributedString(model.title, model.titleEng)
            }
            if let url = URL(string: model.img) {
                vc.mImageView.kf.setImage(with: url, options: [.transition(.fade(0.5)), .loadDiskFileSynchronously])
            }
            
        }
        
        viewModel.sushiModel.bind(to: modelObserver).disposed(by: bag)
    }
    
    private func setAttributedString(_ title: String, _ titleEng: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: "\(title)\n\(titleEng)", attributes: [
          .font: UIFont(name: "PingFangTC-Regular", size: 18.0)!,
          .foregroundColor: #colorLiteral(red: 0.1887685245, green: 0.163427008, blue: 0.1054069033, alpha: 1),
          .kern: 0.0
        ])
        attributedString.addAttribute(.font, value: UIFont(name: "PingFangTC-Regular", size: 24)!, range: NSRange(location: 0, length: title.count))
        return attributedString
    }

}
