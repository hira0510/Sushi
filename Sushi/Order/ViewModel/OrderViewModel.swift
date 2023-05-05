//
//  OrderViewModel.swift
//  Sushi
//
//  Created by Hira on 2023/4/26.
//

import UIKit
import RxCocoa
import RxSwift

class OrderViewModel: BaseViewModel {
    public var bgColor: String = ""
    public var orderCount: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 1)
    public var sushiModel: BehaviorRelay<SushiModel> = BehaviorRelay<SushiModel>(value: SushiModel())
    public weak var delegate: OrderVcProtocol?
    
    public func setSushiModel(_ model: SushiModel) { sushiModel.accept(model) }
    
    public func setAttributedString(_ title: String, _ titleEng: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: "\(title)\n\(titleEng)", attributes: [
          .font: UIFont(name: "PingFangTC-Regular", size: 18.0)!,
          .foregroundColor: #colorLiteral(red: 0.1887685245, green: 0.163427008, blue: 0.1054069033, alpha: 1),
          .kern: 0.0
        ])
        attributedString.addAttribute(.font, value: UIFont(name: "PingFangTC-Regular", size: 24)!, range: NSRange(location: 0, length: title.count))
        return attributedString
    }
}
