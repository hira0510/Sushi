//
//  LoginModel.swift
//  Sushi
//
//  Created by admin on 2023/4/21.
//

import UIKit

enum AccountType {
    case normal
    case administrator 
}

class IsLoginModel: NSObject {
    var isLogin: Bool = false
    var type: AccountType = .normal
    var account: String = ""
    var password: String = ""
    
    init(_ account: String = "", _ password: String = "", _ type: AccountType = .normal) {
        self.account = account
        self.password = password
        self.type = type
        self.isLogin = !account.isEmpty && !password.isEmpty
    }
}
