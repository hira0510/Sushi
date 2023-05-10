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

// MARK: - String
extension String {
    var toWebSocketMsgDic: [String: String] {
        let queryArray = self.split { $0 == " " }.map(String.init)
        var parametersDict: [String: String] = [:]
        for queryParameter in queryArray {
            // split the queryParam into key / value
            let keyValueArray = queryParameter.split { $0 == ":" }.map(String.init)
            let key = keyValueArray.first
            let value = keyValueArray.last
            parametersDict.updateValue(value!, forKey: key!)
        }
        return parametersDict
    }
    
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
}
