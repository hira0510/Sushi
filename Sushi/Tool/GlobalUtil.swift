//
//  GlobalUtil.swift
//  Sushi
//
//  Created by admin on 2023/4/20.
//


import Foundation
import UIKit

class GlobalUtil {
    
    /// 回傳當前時間
    ///
    /// - Returns: TimeInterval（秒數）
    static func getCurrentTime() -> TimeInterval {
        return Date().timeIntervalSince1970
    }
    
    static func dateStr() -> String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.string(from: now)
        return date
    }
    
    ///  指定時間戳的西元年月日時
    ///
    /// - Parameter timeInterval: 指定時間戳
    /// - Returns: 回傳西元年String
    static func specificTimeIntervalStr(timeInterval: TimeInterval, format: String) -> String {
        let timeInterval: TimeInterval = TimeInterval(timeInterval)
        let date: Date = Date(timeIntervalSince1970: timeInterval)

        let dateFormat: DateFormatter = DateFormatter()
        dateFormat.dateFormat = format
        dateFormat.locale = Locale(identifier: "zh_Hant_TW")
        dateFormat.timeZone = TimeZone(identifier: "Asia/Taipei")
        let dateFormatStr = String(dateFormat.string(from: date))

        return dateFormatStr
    }
    
    /// 電池那邊的StatusBar高度
    static func statusBarHeight() -> CGFloat {
        let defaultH: CGFloat = UIScreen.main.bounds.height >= 812 ? 44 : 0
        let safeAreaY: CGFloat
        if #available(iOS 11.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            guard let appDelegate = scene?.delegate as? SceneDelegate else { return defaultH }
            safeAreaY = appDelegate.window?.safeAreaLayoutGuide.layoutFrame.minY ?? 0
        } else {
            safeAreaY = defaultH
        }
        return safeAreaY == 0 ? defaultH: safeAreaY
    }

    static func isPortrait() -> Bool {
        let mainBounds = UIScreen.main.bounds
        return mainBounds.width < mainBounds.height
    }

    static func screenOrientWidth(_ orient: UIDeviceOrientation) -> CGFloat {
        switch orient {
        case .landscapeLeft, .landscapeRight:
            return UIScreen.main.bounds.height
        default: return UIScreen.main.bounds.width
        }
    }

    static func screenOrientHeight(width: CGFloat = UIScreen.main.bounds.width, height: CGFloat = UIScreen.main.bounds.height, _ orient: UIDeviceOrientation) -> CGFloat {
        switch orient {
        case .landscapeLeft, .landscapeRight:
            return width
        default: return height
        }
    }

    static func calculateOrientScaleWithSize(width: CGFloat, _ orient: UIDeviceOrientation = .portrait) -> CGFloat {
        switch orient {
        case .landscapeLeft, .landscapeRight:
            let scale = width / CGFloat(667)
            let result = UIScreen.main.bounds.width * scale
            return result
        default:
            let scale = width / CGFloat(375)
            let result = UIScreen.main.bounds.width * scale
            return result
        }
    }

    /// 計算高等比放大縮小
    ///
    /// - Parameter width: 被計算的高
    /// - Returns: 回傳CGFloat
    static func calculateHeightScaleWithSize(height: CGFloat) -> CGFloat {
        let scale = height / CGFloat(667)
        let result = UIScreen.main.bounds.height * scale
        return result
    }

    /// 計算寬等比放大縮小
    ///
    /// - Parameter width: 被計算的寬
    /// - Returns: 回傳CGFloat
    static func calculateWidthScaleWithSize(width: CGFloat) -> CGFloat {
        let scale = width / CGFloat(375)
        let result = UIScreen.main.bounds.width * scale
        return result
    }

    /// 計算高等比放大縮小
    /// 667:375
    /// - Parameters:
    ///   - width: 物件寬
    ///   - height: 物件高
    /// - Returns: 回傳CGFloat(等比放大後的高)
    static func calculateHeightScaleWithSize(width: CGFloat, height: CGFloat) -> CGFloat {
        let scale = width / CGFloat(375)
        let itemScale = height / width
        let result = UIScreen.main.bounds.width * scale * itemScale
        return result
    }

    /// 計算螢幕打橫時寬等比放大縮小
    ///
    /// - Parameter width: 被計算的寬
    /// - Returns: 回傳CGFloat
    static func calculateWidthHorizontalScaleWithSize(width: CGFloat) -> CGFloat {
        let scale = width / CGFloat(375)
        let orient: UIDeviceOrientation = UIScreen.main.bounds.height > UIScreen.main.bounds.width ? .portrait: .landscapeLeft
        let result = orient.isPortrait ? UIScreen.main.bounds.width * scale : UIScreen.main.bounds.height * scale
        return result
    }

    /// 計算高等比放大縮小
    /// 667:375
    /// - Parameters:
    ///   - width: 物件寬
    ///   - height: 物件高
    /// - Returns: 回傳CGFloat(等比放大後的寬)
    static func calculateHeightＨorizontalScaleWithSize(width: CGFloat, height: CGFloat) -> CGFloat {
        let scale = width / CGFloat(667)
        let itemScale = height / width
        let result = UIScreen.main.bounds.width * scale * itemScale
        return result
    }

    /// 計算高等比放大縮小
    ///
    /// - Parameters:
    ///   - height: 要被等比放大的高
    ///   - standardHeight: 設計稿的範例高
    /// - Returns: Returns: 回傳CGFloat（高）
    static func calculateHeightScaleWithSize(height: CGFloat, standardHeight: CGFloat) -> CGFloat {
        let scale = height / CGFloat(standardHeight)
        let result = UIScreen.main.bounds.height * scale
        return result
    }
}
