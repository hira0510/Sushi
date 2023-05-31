//
//  MenuModel.swift
//  Sushi
//
//  Created by admin on 2023/4/20.
//

import UIKit

enum CollectionViewType {
    case menu
    case sushi
}

class MenuStrModel: NSObject {
    
    var menu: String = ""
    var title: String = ""
    var sushiCount: Int = 0
    
    init(_ menu: String = "", _ title: String = "", _ count: Int = 0) {
        self.menu = menu
        self.title = title
        self.sushiCount = count
    }
    
    func getAry(_ model: [MenuModel]) -> [MenuStrModel] {
        let titles = model.map { $0.title }
        let menus = model.map { $0.menu }
        let sushiCount = model.map { $0.sushi.count }
        
        var resultAry: [MenuStrModel] = [] 
        
        for (menu, title, count) in zip(menus, titles, sushiCount) {
            resultAry.append(MenuStrModel(menu, title, count))
        }
        return resultAry
    }
}


class MenuModelData: NSObject {
     
    var data: [MenuModel] = []
    var ad: [AdModel] = []
    
    init(_ model: Any? = nil) {
        var dic: [String: MenuModel] = [:]
        guard let model = model as? [String: Any] else { return }
        if let data = model["Data"] as? [String: Any] {
            for (key, value) in data {
                dic[key] = MenuModel().data(key, value)
            }
            
            let menuSort = dic.keys.sorted(by: <)
            var dataAry: [MenuModel] = []
            for key in menuSort {
                dataAry.append(unwrap(dic[key], MenuModel()))
            }
            self.data = dataAry
        }
        if let data = model["AD"] as? [Any] {
            self.ad = AdModel().data(data)
        }
    }
}

class MenuModel: NSObject {
    
    var menu: String = ""
    var title: String = ""
    var titleEng: String = ""
    var color: String = ""
    var sushi: [SushiModel] = []
    
    init(_ menu: Any? = nil, _ title: Any? = nil, _ titleEng: Any? = nil, _ color: Any? = nil, _ sushi: [SushiModel] = []) {
        self.menu = menu.toStr()
        self.title = title.toStr()
        self.titleEng = titleEng.toStr()
        self.color = color.toStr()
        self.sushi = sushi
    }
    
    func data(_ menuIndexStr: Any, _ menu: Any) -> MenuModel {
        if let menu = menu as? [String: Any], let sushi = menu["sushi"] as? [Any] {
            if let data = try? JSONSerialization.data(withJSONObject: sushi, options: []), let resultAry = try? JSONDecoder().decode([SushiModel].self, from: data) {
                return MenuModel(menuIndexStr, menu["title"], menu["titleEng"], menu["color"], resultAry)
            }
        }
        return MenuModel()
    }
    
    func getSushiData() -> [String: Any] {
        var result: [String: Any] = [:]
        var snapshotValue: [String: Any] = [:]
        for (i, data) in self.sushi.enumerated() {
            snapshotValue["title"] = data.title
            snapshotValue["img"] = data.img
            snapshotValue["eng"] = data.eng
            snapshotValue["price"] = data.price
            snapshotValue["size"] = data.size
            result[i.toStr] = snapshotValue
        }
        return result
    }
}

class SushiModel: NSObject, Codable {
     
    var title: String = ""
    var eng: String = ""
    var img: String = ""
    var price: String = ""
    var size: String = ""

    init(title: String = "", eng: String = "", img: String = "", price: String = "", size: String = "") {
        self.title = title
        self.eng = eng
        self.img = img
        self.price = price
        self.size = size
    }
    
    func toAnyObject() -> [String: Any] {
        var snapshotValue: [String: Any] = [:]
        snapshotValue["title"] = self.title
        snapshotValue["img"] = self.img
        snapshotValue["eng"] = self.eng
        snapshotValue["price"] = self.price
        snapshotValue["size"] = self.size
        return snapshotValue
    }
    
    func toSushi(dic: [String: String]) -> SushiModel {
        let model = SushiModel()
        model.title = dic["title"] ?? ""
        model.img = dic["img"] ?? ""
        model.eng = dic["eng"] ?? ""
        model.price = dic["price"] ?? ""
        model.size = dic["size"] ?? ""
        return model
    }
}

class AdModel: NSObject, Codable {
    var title: String = ""
    var imgUrl: String = ""
    var url: String = ""
    
    init(title: String = "", imgUrl: String = "", url: String = "") {
        self.title = title
        self.imgUrl = imgUrl
        self.url = url
    }
    
    func data(_ ad: [Any]) -> [AdModel] {
        if let data = try? JSONSerialization.data(withJSONObject: ad, options: []), let resultAry = try? JSONDecoder().decode([AdModel].self, from: data) {
            return resultAry
        }
        return []
    }
}

class SushiRecordModel: NSObject {
    
    var numId: String = ""
    var arrivedTime: TimeInterval = 0
    var title: String = ""
    var titleEng: String = ""
    var img: String = ""
    var money: String = ""

    init(_ numId: String = "", _ arrivedTime: TimeInterval = 0, _ model: SushiModel) {
        self.numId = numId
        self.arrivedTime = arrivedTime
        self.title = model.title
        self.titleEng = model.eng
        self.img = model.img
        self.money = model.price
    }
}

class AddOrderItem {
    var table: String = ""
    var item: String = ""
    var itemPrice: String = ""
    var numId: String = ""
    var isComplete: String = ""
    
    init(_ dic: [String : String]) {
        self.table = unwrap(dic["桌號"], "")
        self.item = unwrap(dic["點餐"], "")
        self.itemPrice = unwrap(dic["價格"], "")
        self.numId = unwrap(dic["單號"], "")
        let countAry = item.toAry
        let isCompleteAry = Array(repeating: "false", count: countAry.count)
        self.isComplete = isCompleteAry.aryToStr
    }
}
