//
//  BaseViewModel.swift
//  Sushi
//
//  Created by Hira on 2023/4/28.
//

import UIKit
import RxCocoa
import RxSwift

class BaseViewModel: NSObject {
    
    var orderSqlite: OrderSQLite {
        get {
            return OrderSQLite()
        }
    }
    
    func request() -> Observable<[MenuModel]> {
        let firebaseManager = FireBaseManager()
        firebaseManager.auth()
        let json: Observable<[MenuModel]> = Observable.create { (observer) -> Disposable in
            firebaseManager.ref { model in
                guard let model = model else { return }
                observer.onNext(model.data)
                observer.onCompleted()
            }
            return Disposables.create()
        }
        return json
    }
    
    func addData(_ type: WhiteType, _ price: String, _ eng: String, imgUrl: String = "") -> Observable<Bool> {
        var value: String = ""
        switch type {
        case .img: value = imgUrl
        case .money: value = price
        case .titleEng: value = eng
        }
        
        let firebaseManager = FireBaseManager()
        let json: Observable<Bool> = Observable.create { (observer) -> Disposable in
            firebaseManager.addDatabase(type: type, value: value) { suc in
                guard let _ = suc else { return }
                observer.onNext(true)
                observer.onCompleted()
            }
            return Disposables.create()
        }
        return json
    }
    
    func delData(_ type: WhiteType) -> Observable<Bool> {
        
        let firebaseManager = FireBaseManager()
        let json: Observable<Bool> = Observable.create { (observer) -> Disposable in
            firebaseManager.delDatabase(type: type) { suc in
                guard let _ = suc else { return }
                observer.onNext(true)
                observer.onCompleted()
            }
            return Disposables.create()
        }
        return json
    }
    
    func addStorageImg(_ name: String, _ image: UIImage) -> Observable<String> {
        let firebaseManager = FireBaseManager()
        let json: Observable<String> = Observable.create { (observer) -> Disposable in 
            firebaseManager.addStorageImg(name, image) { url in
                guard let urlStr = url else { return }
                observer.onNext(urlStr)
                observer.onCompleted()
            }
            return Disposables.create()
        }
        return json
    }
    
    func delStorageImg(_ title: String) -> Observable<Bool> {
        let firebaseManager = FireBaseManager()
        let json: Observable<Bool> = Observable.create { (observer) -> Disposable in
            firebaseManager.delStorageImg(title) { _ in
                observer.onNext(true)
                observer.onCompleted()
                print("刪除圖片\(title)")
            }
            return Disposables.create()
        }
        return json
    }
}
