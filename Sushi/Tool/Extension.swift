//
//  Extension.swift
//  Sushi
//
//  Created by admin on 2023/4/20.
//

import UIKit

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
}

extension String {
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

final class SynchronizedArray<Element: Equatable> {
    var array = [Element]()
    private let queue = DispatchQueue.main

    func removes(_ element: Element) {
        queue.async(flags: .barrier) {
            self.array.remove(obj: element)
            //Error: Referencing instance method 'remove(obj:)' on 'Array' requires that 'Element' conform to 'Equatable'
        }
    }
}

extension Array where Element: Equatable {

    // Remove first collection element that is equal to the given `object`:
    mutating func remove(obj: Element) {
        if let index = firstIndex(of: obj) {
            remove(at: index)
        }
    }
}
