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

//class SushiModel: NSObject {
//    var title: String = ""
//    var img: String = ""
//
//    init(_ title: String = "") {
//        self.title = title
//        self.img = title
//    }
//}
//
//class MenuModel: NSObject {
//    var title: String = ""
//    var color: UIColor = .clear
//    var sushi: [SushiModel] = []
//
//    init(_ title: String = "", _ color: UIColor = .clear, _ sushiAry: [SushiModel] = []) {
//        self.title = title
//        self.color = color
//        self.sushi = sushiAry
//    }
//}


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
    var color: String = ""
    var sushi: [SushiModel] = []
    
    init(_ menu: Any? = nil, _ title: Any? = nil, _ color: Any? = nil, _ sushi: [SushiModel] = []) {
        self.menu = menu as? String ?? ""
        self.title = title as? String ?? ""
        self.color = color as? String ?? ""
        self.sushi = sushi
    }
    
    func data(_ menuIndexStr: Any, _ menu: Any) -> MenuModel {
        if let menu = menu as? [String: Any] {
            var ary: [SushiModel] = []
            if let sushi = menu["sushi"] as? [String: String] {
                for i in sushi {
                    ary.append(SushiModel(i))
                }
            }
            return MenuModel(menuIndexStr, menu["title"], menu["color"], ary)
        }
        return MenuModel()
    }
}

class SushiModel: NSObject {
    
    var title: String = ""
    var img: String = ""

    init(_ sushi: (key: String, value: String)) {
        self.title = sushi.key
        self.img = sushi.value
    }
}
