//
//  SuShiSingleton.swift
//  Sushi
//
//  Created by admin on 2023/4/21.
//

import UIKit
import RxCocoa
import RxSwift

class SuShiSingleton {
    private static var mInstance: SuShiSingleton?
    static func share() -> SuShiSingleton {
        if mInstance == nil {
            mInstance = SuShiSingleton()
        }
        return mInstance!
    }
    
    private var isLoginModel: BehaviorRelay<IsLoginModel> = BehaviorRelay<IsLoginModel>(value: .init())
    private var isEng: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
    
    func setIsLoginModel(_ account: String, _ psw: String, _ type: AccountType) {
        self.isLoginModel.accept(IsLoginModel(account, psw, type))
    }
    func getAccount() -> String { return isLoginModel.value.account }
    func getPassword() -> String { return isLoginModel.value.password }
    func getAccountType() -> AccountType { return isLoginModel.value.type }
    func getIsLogin() -> IsLoginModel { return isLoginModel.value }
    func bindIsLogin() -> BehaviorRelay<IsLoginModel> { return isLoginModel }
    
    
    func setIsEng(_ bool: Bool) { isEng.accept(bool) }
    func getIsEng() -> Bool { return isEng.value }
    func bindIsEng() -> BehaviorRelay<Bool> { return isEng }
}
