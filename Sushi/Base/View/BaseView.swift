//
//  BaseView.swift
//  Sushi
//
//  Created by Hira on 2023/5/5.
//

import UIKit
import RxCocoa
import RxSwift

class BaseView: UIView, NibOwnerLoadable {
    lazy var finishedToast: (() -> ()) = { }
    
    var orderSqlite: OrderSQLite {
        get {
            return OrderSQLite()
        }
    }
    
    lazy var bag: DisposeBag! = {
        return DisposeBag()
    }()
    
    /// 消失
    func remove(delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.removeFromSuperview()
            self.finishedToast()
        }
    }
}
