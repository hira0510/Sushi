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
    
    /// 拿取DeviceId
    static func getDeviceId() -> String {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "DEVICE_UUID",
            kSecReturnData as String: kCFBooleanTrue as Any,
            kSecMatchLimit as String: kSecMatchLimitOne] as [String: Any]

        var dataTypeRef: AnyObject? = nil
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status == noErr, let dataTypeRef = dataTypeRef as? Data, let uuid = String(data: dataTypeRef, encoding: .utf8) {
            return uuid
        } else {
            let DEVICE_UUID: String = unwrap(unwrap(UserDefaults.standard.deviceId, UIDevice.current.identifierForVendor?.uuidString), UUID().uuidString)
            if let data = DEVICE_UUID.data(using: .utf8) {
                let query = [
                    kSecClass as String: kSecClassGenericPassword as String,
                    kSecAttrAccount as String: "DEVICE_UUID",
                    kSecValueData as String: data] as [String: Any]

                SecItemDelete(query as CFDictionary)
                SecItemAdd(query as CFDictionary, nil)
            }
            return DEVICE_UUID
        }
    }
}
