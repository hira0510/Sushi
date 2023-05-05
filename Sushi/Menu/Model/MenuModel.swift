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
    
    init(_ menu: String = "", _ title: String = "") {
        self.menu = menu
        self.title = title
    }
    
    func getAry(_ model: [MenuModel]) -> [MenuStrModel] {
        let title = model.map { $0.title }
        let menu = model.map { $0.menu }
        
        var resultAry: [MenuStrModel] = []
        resultAry = zip(menu, title).map() {
            return MenuStrModel($0, $1)
        }
        return resultAry
    }
}


class MenuModelData: NSObject {
     
    var data: [MenuModel] = []
    
    init(_ data: Any? = nil) {
        var dic: [String: MenuModel] = [:]
        if let data = data as? [String: Any] {
            for (key, value) in data {
                dic[key] = MenuModel().data(key, value)
            }
        }
         
        let menuSort = dic.keys.sorted(by: <)
        var dataAry: [MenuModel] = []
        for key in menuSort {
            dataAry.append(dic[key] ?? MenuModel())
        }
        self.data = dataAry
    }
}

class MenuModel: NSObject {
    
    var menu: String = ""
    var title: String = ""
    var titleEng: String = ""
    var color: String = ""
    var sushi: [SushiModel] = []
    
    init(_ menu: Any? = nil, _ title: Any? = nil, _ titleEng: Any? = nil, _ color: Any? = nil, _ sushiImg: [SushiModel] = []) {
        self.menu = menu as? String ?? ""
        self.title = title as? String ?? ""
        self.titleEng = titleEng as? String ?? ""
        self.color = color as? String ?? ""
        self.sushi = sushiImg
    }
    
    func data(_ menuIndexStr: Any, _ menu: Any) -> MenuModel {
        if let menu = menu as? [String: Any] {
            var resultAry: [SushiModel] = []
            var titleAry: [String] = []
            var titleEngAry: [String] = []
            var imgAry: [String] = []
            var moneyAry: [String] = []
            if let sushiImg = menu["sushiEng"] as? [String: String] {
                titleAry = sushiImg.keys.map { $0 }
                titleEngAry = sushiImg.values.map { $0 }
            }
            if let sushiImg = menu["sushiImg"] as? [String: String] {
                imgAry = sushiImg.values.map { $0 }
            }
            if let sushiImg = menu["sushiMoney"] as? [String: String] {
                moneyAry = sushiImg.values.map { $0 }
            }
            
            for (title, titleEng, img, money) in zip(titleAry, titleEngAry, imgAry, moneyAry) {
                resultAry.append(SushiModel(title, titleEng, img, money))
            }
            return MenuModel(menuIndexStr, menu["title"], menu["titleEng"], menu["color"], resultAry)
        }
        return MenuModel()
    }
}

class SushiModel: NSObject {
    
    var title: String = ""
    var titleEng: String = ""
    var img: String = ""
    var money: String = ""

    init(_ title: String = "", _ titleEng: String = "", _ img: String = "", _ money: String = "") {
        self.title = title
        self.titleEng = titleEng
        self.img = img
        self.money = money
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
        self.titleEng = model.titleEng
        self.img = model.img
        self.money = model.money
    }
}
