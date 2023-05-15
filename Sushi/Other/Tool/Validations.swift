//
//  Validations.swift
//  Sushi
//
//  Created by admin on 2023/4/21.
//

import Foundation

enum Alert {
    case success
    case failure
    case error
}

enum Valid {
    case success
    case failure(Alert, AlertMessages)
}

enum ValidationType {
    case account
    case password
    case num
    case price
}

///正則表達式
enum RegularExpression: String {
    //帳號英文或數字隨便組合並且4-2000個
    case account = "^[A-Za-z0-9]{4,10}"
    //密碼英文或數字隨便組合並且4-2000個
    case password = "^[A-Za-z0-9]{4,15}"
    case num = "^[0-9]{2,3}"
    case price = "^[0-9]{2,5}"
}

enum AlertMessages: String {
    case inValidAccount = "帳號輸入錯誤，請輸入4~10位數字/英文"
    case inValidPSW = "密碼輸入錯誤，請輸入4~15位的數字/英文"
    case inValidNum = "桌號輸入錯誤，請輸入2~3位的數字"
    case inValidPrice = "價格輸入錯誤，請輸入2~5位的數字"
    
    case emptyAccount = "沒有輸入帳號"
    case emptyPSW = "沒有輸入密碼"
    case emptyNum = "沒有輸入桌號"
    case emptyPrice = "沒有輸入價格"
    func localized() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

class Validation: NSObject {

    public static let shared = Validation()

    /// 驗證(帶入型態、內容)
    ///
    /// - Parameter values: ValidationType + String
    /// - Returns:
    public func validate(values: (type: ValidationType, inputValue: String)...) -> (success: Bool, msg: String) {
        for valueToBeChecked in values {
            switch valueToBeChecked.type {
            case .account:
                return isValidString((valueToBeChecked.inputValue, .account, .emptyAccount, .inValidAccount))
            case .password:
                return isValidString((valueToBeChecked.inputValue, .password, .emptyPSW, .inValidPSW))
            case .num:
                return isValidString((valueToBeChecked.inputValue, .num, .emptyNum, .inValidNum))
            case .price:
                return isValidString((valueToBeChecked.inputValue, .price, .emptyPrice, .inValidPrice))
            }
        }
        return (true, "")
    }

    /// 驗證字串(帶入驗證內容、正則表達屬性、空直屬性、錯誤屬性)
    ///
    /// - Parameter input:
    /// - Returns:
    public func isValidString(_ input: (text: String, regex: RegularExpression, emptyAlert: AlertMessages, invalidAlert: AlertMessages)) -> (success: Bool, msg: String) {
        if input.text.isEmpty {
            return (false, input.emptyAlert.localized())
        } else if isValidRegEx(input.text, input.regex) != true {
            return (false, input.invalidAlert.localized())
        }
        return (true, "")
    }

    /// 驗證正則表達式，只回傳Bool
    ///
    /// - Parameters:
    ///   - testStr:
    ///   - regex: RegularExpression
    /// - Returns:
    public func isValidRegEx(_ testStr: String, _ regex: RegularExpression) -> Bool {
        let stringTest = NSPredicate(format: "SELF MATCHES %@", regex.rawValue)
        let result = stringTest.evaluate(with: testStr)
        return result
    }
    
    /// 驗證正則表達式，是否為合法帳號
    public func isValidAccount(_ account: String) -> Bool {
        return isValidRegEx(account, .account)
    }
    
    /// 驗證正則表達式，是否為合法價格
    public func isValidPrice(_ price: String) -> Bool {
        return isValidRegEx(price, .price)
    }
}
