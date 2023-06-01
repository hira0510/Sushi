//
//  StarscreamWebSocketManager.swift
//  Sushi
//
//  Created by Hira on 2023/4/28.
//

import UIKit

extension UserDefaults {
    /// deviceId
    var deviceId: String? {
        get { self.string(forKey: #function) }
        set { self.setValue(newValue, forKey: #function) }
    }
    /// 服務桌號以及通知時間
    var serviceTableAry: [String: TimeInterval] {
        get { self.dictionary(forKey: #function) as? [String: TimeInterval] ?? [:] }
        set { self.setValue(newValue, forKey: #function) }
    }
    /// 結帳桌號以及通知時間
    var checkoutTableAry: [String: TimeInterval] {
        get { self.dictionary(forKey: #function) as? [String: TimeInterval] ?? [:] }
        set { self.setValue(newValue, forKey: #function) }
    }
    /// 服務是否沒有新資料
    var serviceHintIsHidden: Bool {
        get { self.bool(forKey: #function) }
        set { self.setValue(newValue, forKey: #function) }
    }
    /// 點餐紀錄是否沒有新資料
    var recordHintIsHidden: Bool {
        get { self.bool(forKey: #function) }
        set { self.setValue(newValue, forKey: #function) }
    }
    /// 結帳是否沒有新資料
    var checkoutHintIsHidden: Bool {
        get { self.bool(forKey: #function) }
        set { self.setValue(newValue, forKey: #function) }
    }
}
