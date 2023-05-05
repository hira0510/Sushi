//
//  OrderSQLModel.swift
//  Sushi
//
//  Created by Hira on 2023/5/4.
//

import UIKit

class RecordModel: NSObject {

    var id: Int64 = 0
    var numId: String = ""
    var tableNumber: String = ""
    var isComplete: Bool = false
    var timestamp: TimeInterval = 0.0
    var item: [RecordItemModel] = []

    init(_ id: Int64 = 0, _ numId: String, _ tableNumber: String = "", _ item: [RecordItemModel] = [], _ timestamp: TimeInterval = 0.0, _ isComplete: Bool = false) {
        self.id = id
        self.numId = numId
        self.tableNumber = tableNumber
        self.item = item
        self.timestamp = timestamp
        self.isComplete = isComplete
    }
}

class RecordItemModel: NSObject {

    var name: String = ""
    var price: String = ""

    init(_ name: String = "", _ price: String = "") {
        self.name = name
        self.price = price
    }
}
