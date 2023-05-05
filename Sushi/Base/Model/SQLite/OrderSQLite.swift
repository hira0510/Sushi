//
//  OrderSQLite.swift
//  Sushi
//
//  Created by Hira on 2023/5/2.
//

import UIKit
import SQLite

struct OrderSQLite {

    private var db: Connection!
    private let collection = Table("Order") //表名
    private let id = Expression<Int64>("id") //主键
    private let numId = Expression<String>("numId") //同桌號送單的index
    private let tableNumber = Expression<String>("tableNumber") //桌號
    private let timeStamp = Expression<TimeInterval>("timeStamp") //預定送達時間
    private let isComplete = Expression<Bool>("isComplete") //是否已送達
    private let itemName = Expression<String>("itemName") //名稱可轉陣列Str ex:"1,2,3"
    private let itemPrice = Expression<String>("itemPrice") //價格可轉陣列Str

    init() {
        createdsqlite3()
    }

    //創建數據庫文件
    mutating func createdsqlite3(filePath: String = "/Documents") {

        let sqlFilePath = NSHomeDirectory() + filePath + "/db.sqlite3"
        do {
            db = try Connection(sqlFilePath)
            try db.run(collection.create(ifNotExists: true) { t in
                    t.column(id, primaryKey: true)
                    t.column(numId)
                    t.column(tableNumber)
                    t.column(timeStamp)
                    t.column(isComplete)
                    t.column(itemName)
                    t.column(itemPrice)
                })
        } catch {
            print("db collection error => \(error)")
        }
    }

    //讀取全部數據(點餐紀錄用)
    func readData() -> [RecordModel] {
        var collectionData: [RecordModel] = []
        for user in try! db.prepare(collection) {
            var itemData: [RecordItemModel] = []
            let itemName = user[itemName].components(separatedBy: [","])
            let itemPrice = user[itemPrice].components(separatedBy: [","])
            
            itemData = zip(itemName, itemPrice).map() {
                return RecordItemModel($0, $1)
            }

            collectionData.append(RecordModel(user[id], user[numId], user[tableNumber], itemData, user[timeStamp], user[isComplete]))
        }
        return collectionData.reversed()
    }
 
    //讀取統一後的數據(結帳用 不用id)
    func readUniteData(tableAry: [String]) -> [RecordModel] {
        var itemData: [RecordModel] = []
        for table in tableAry {
            guard (itemData.filter { $0.tableNumber == table }).count == 0 else { continue }
            let tableCollectionData: [RecordModel] = readSingleData(_tableNumber: table)
            let newItemModel = tableCollectionData.flatMap { $0.item }
            let newRecordModel = RecordModel(0, "", table, newItemModel)
            itemData.append(newRecordModel)
        }
        return itemData
    }

    //讀取單一數據
    private func readSingleData(_tableNumber: String) -> [RecordModel] {
        let collectionData: [RecordModel] = readData()
        var itemData: [RecordModel] = []
        for data in collectionData {
            if data.tableNumber == _tableNumber {
                itemData.append(data)
            }
        }
        return itemData
    }

    //插入數據
    func insertData(_tableNumber: String, _numId: String, _itemName: String, _itemPrice: String) {
        do {
            let insert = collection.insert(tableNumber <- _tableNumber, numId <- _numId, itemName <- _itemName, itemPrice <- _itemPrice, timeStamp <- 0.0, isComplete <- false)
            try db.run(insert)
        } catch {
            print("[DEBUG] insert error => \(error)")
        }
    }

    //更新價格數據
    func updatePriceData(_id: Int64, _itemPrice: String) {
        let currUser = collection.filter(id == _id)
        do {
            try db.run(currUser.update(itemPrice <- _itemPrice))
        } catch {
            print(error)
        }
    }
    
    //更新送達時間數據
    func updateTimeData(_id: Int64, _timeStamp: TimeInterval, success: @escaping () -> ()) {
        let currUser = collection.filter(id == _id)
        do {
            try db.run(currUser.update(timeStamp <- _timeStamp))
            success()
        } catch {
            print(error)
        }
    }
    
    //更新是否送達數據
    func updateIsCompleteData(_id: Int64, _isComplete: Bool, success: @escaping () -> ()) {
        let currUser = collection.filter(id == _id)
        do {
            try db.run(currUser.update(isComplete <- _isComplete, timeStamp <- GlobalUtil.getCurrentTime()))
            success()
        } catch {
            print(error)
        }
    }

    //删除同桌號的所有數據
    func delData(_tableNumber: String) {
        let currUser = collection.filter(_tableNumber == self.tableNumber)
        do {
            try db.run(currUser.delete())
        } catch {
            print(error)
        }
    }
}
