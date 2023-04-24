//
//  GlobalUtil.swift
//  Sushi
//
//  Created by admin on 2023/4/20.
//


import Foundation
import UIKit

class GlobalUtil {

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
        let scale = width / CGFloat(667)
        let result = UIScreen.main.bounds.width * scale
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
