//
//  SuShiSingleton.swift
//  Sushi
//
//  Created by admin on 2023/4/21.
//

import UIKit

class SuShiSingleton {
    private static var mInstance: SuShiSingleton?
    static func share() -> SuShiSingleton {
        if mInstance == nil {
            mInstance = SuShiSingleton()
        }
        return mInstance!
    }
    
    private var isLoginModel: IsLoginModel = .init()
    
    func setIsLoginModel(_ account: String, _ psw: String, _ type: AccountType) {
        self.isLoginModel = IsLoginModel(account, psw, type)
    }
    func getAccount() -> String { return isLoginModel.account }
    func getPassword() -> String { return isLoginModel.password }
    func getAccountType() -> AccountType { return isLoginModel.type }
    func getIsLogin() -> IsLoginModel {
        return isLoginModel
    }
}
