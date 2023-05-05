//
//  Extension.swift
//  Sushi
//
//  Created by admin on 2023/4/20.
//

import UIKit

extension NSObject {
    class var className: String {
        return String(describing: self)
    }
    
    var className: String {
        return type(of: self).className
    }
}

extension Dictionary {
    var sortAry: [(String, TimeInterval)] {
        guard let dic = self as? [String: TimeInterval] else { return [] }
        let sortedByKeyDictionary = dic.sorted { $0.1 > $1.1 }

        var newArray = [(String, TimeInterval)]()
        for (key, value) in sortedByKeyDictionary {
            newArray.append((key, value))
        }
        return newArray
    }

    var getSortKey: [String] {
        return sortAry.map { $0.0 }
    }
    
    var getSortValue: [TimeInterval] {
        return sortAry.map { $0.1 }
    }
}

extension Int {
    var toDouble: Double {
        return Double(self)
    }
    var toStr: String {
        return String(self)
    }
}

extension Double {
    var toStr: String {
        return String(self)
    }
    var toInt: Int {
        return Int(self)
    }
}

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
}
