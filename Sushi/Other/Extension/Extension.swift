//
//  Extension.swift
//  Sushi
//
//  Created by admin on 2023/4/20.
//

import UIKit

public func unwrap<T>(_ lhs: T?, _ rhs: T) -> T {
    if let unwrappedLhs = lhs {
        return unwrappedLhs
    }
    return rhs
}

// MARK: - NSObject
extension NSObject {
    class var className: String {
        return String(describing: self)
    }
    
    var className: String {
        return type(of: self).className
    }
}

// MARK: - Optional
extension Optional {
  func toStr() -> String {
      if let str = self as? String {
          return str
      }
      return ""
  }
}

// MARK: - Dictionary
extension Dictionary {
    var toWebMsg: String {
        var result = ""
        for dic in self {
            result.append("\(dic.key):\(dic.value) ")
        }
        return result
    } 
    
    var sortTimeAry: [(String, TimeInterval)] {
        guard let dic = self as? [String: TimeInterval] else { return [] }
        let sortedByKeyDictionary = dic.sorted { $0.1 > $1.1 }

        var newArray = [(String, TimeInterval)]()
        for (key, value) in sortedByKeyDictionary {
            newArray.append((key, value))
        }
        return newArray
    }

    var getSortTimeKey: [String] {
        return sortTimeAry.map { $0.0 }
    }
    
    var getSortTimeValue: [TimeInterval] {
        return sortTimeAry.map { $0.1 }
    }
}

extension Array {
    var aryToStr: String {
        if let strAry = self as? [String] {
            return strAry.joined(separator: ",")
        } else if let boolAry = self as? [Bool] {
            let boolStrAry = boolAry.compactMap { return $0.toStr }
            return boolStrAry.joined(separator: ",")
        }
        return ""
    }
}

// MARK: - Int
extension Int {
    var toDouble: Double {
        return Double(self)
    }
    var toCGFloat: CGFloat {
        return CGFloat(self)
    }
    var toTimeInterval: TimeInterval {
        return TimeInterval(self)
    }
    var toStr: String {
        return String(self)
    }
}

// MARK: - Double
extension Double {
    var toStr: String {
        return String(self)
    }
    var toInt: Int {
        return Int(self)
    }
}

// MARK: - CGFloat
extension CGFloat {
    var toInt: Int {
        return Int(self)
    }
}

// MARK: - Bool
extension Bool {
    var toStr: String {
        return String(self)
    }
    
    var toAry: [String] {
        return self.toStr.components(separatedBy: ",")
    }
}

// MARK: - String
extension String {
    
    var toTime: TimeInterval {
        if let timeInterval = TimeInterval(self) {
            return timeInterval
        }
        return 0
    }

    var toDouble: Double {
        if let double = Double(self) {
            return double
        }
        return 0
    }

    var toInt: Int {
        if let int = Int(self) {
            return int
        }
        return 0
    }
    
    var toAry: [String] {
        return self.components(separatedBy: ",")
    }
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return unwrap(htmlToAttributedString?.string, "")
    }
    
    func urlDecoded() -> String {
        return unwrap(self.removingPercentEncoding, "")
    }
    
    func toMsgDic(_ value1: Character, _ value2: Character) -> [String: String] {
        let queryArray = self.split { $0 == value1 }.map(String.init)
        var parametersDict: [String: String] = [:]
        var value = ""
        for queryParameter in queryArray {
            // split the queryParam into key / value
            var keyValueArray = queryParameter.split { $0 == value2 }.map(String.init)
            let key = keyValueArray.first
            if keyValueArray.count > 2 {
                keyValueArray.removeFirst()
                value = keyValueArray.joined(separator: String(value2))
            } else {
                value = keyValueArray.last ?? ""
            }
            parametersDict.updateValue(value, forKey: key!)
        }
        return parametersDict
    }
    
    func isImageType() -> Bool {
        // image formats which you want to check
        let imageFormats = ["jpg", "png", "gif", "jpeg"]

        if URL(string: self) != nil  {

            let extensi = (self as NSString).pathExtension

            return imageFormats.contains(extensi)
        }
        return false
    }
}
