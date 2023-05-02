//
//  TwToEng.swift
//  Sushi
//
//  Created by Hira on 2023/4/28.
//

import UIKit

public class TwToEng {
    public static let eng = [/*"Staff Login", "Shop Login", "Staff ACC", "Shop Num", "Staff PSW", "Shop PSW", "Login",*/ "Please Wait", "Add To Cart", "Arrived", " minutes", "Menu", "中文", "Number", "Reserve\ndelivery time", "Discs", "min", "Send", "Send Complete", /*"Delete...", "Delete Complete", "Add...", "Add Complete",*/ "Open", ""]
    public static let tw = [/*"員工登入", "店鋪登入", "員工帳號", "店舖號碼", "員工密碼", "店舖密碼", "登入", */"已通知服務員，請稍候", "加入購物車", "已送達", " 分鐘", "菜單", "Language", "盤數", "預定\n送達時間", "盤", "分", "送出", "已送出", /*"刪除中...", "刪除成功", "新增中...", "新增成功",*/ "開啟", ""]
    public static func simplify(_ ch: String) -> String {
        if let i = eng.firstIndex(of: ch) {
            return tw[i]
        } else {
            return ch
        }
    }
    public static func traditionalize(_ ch: String) -> String {
        if let i = tw.firstIndex(of: ch) {
            return eng[i]
        } else {
            return ch
        }
    }
}

public extension String {
    /// 英文轉繁體
    private var toTw: String {
        return TwToEng.simplify(self)
    }
    ///繁體轉英文
    private var toEng: String {
        return TwToEng.traditionalize(self)
    }
    
    func twEng() -> String {
        return SuShiSingleton.share().getIsEng() ? toEng: toTw
    }
}
