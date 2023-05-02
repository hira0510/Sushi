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
    var bgColor: String = ""
    var orderCount: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 1)
    var sushiModel: BehaviorRelay<SushiModel> = BehaviorRelay<SushiModel>(value: SushiModel())
    func setSushiModel(_ model: SushiModel) { sushiModel.accept(model) }
}
