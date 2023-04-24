//
//  AddSushiViewModel.swift
//  Sushi
//
//  Created by admin on 2023/4/21.
//

import UIKit
import RxCocoa
import RxSwift

class AddSushiViewModel: NSObject {
    var mName: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    var mImage: BehaviorRelay<UIImage> = BehaviorRelay<UIImage>(value: UIImage(named: "noImg")!)
}
