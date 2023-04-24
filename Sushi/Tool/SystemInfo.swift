//
//  SystemInfo.swift
//  Sushi
//
//  Created by admin on 2023/4/21.
//

import Foundation

class SystemInfo {

    /// 拿取版本號
    static func getVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
}
