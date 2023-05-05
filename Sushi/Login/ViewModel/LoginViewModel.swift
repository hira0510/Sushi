//
//  LoginViewModel.swift
//  Sushi
//
//  Created by admin on 2023/4/21.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewModel: BaseViewModel {
    var account: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    var password: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    var accountType: BehaviorRelay<AccountType> = BehaviorRelay<AccountType>(value: .normal)
}
