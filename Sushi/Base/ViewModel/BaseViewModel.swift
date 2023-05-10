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
    
    internal lazy var bag: DisposeBag! = {
        return DisposeBag()
    }()
    
    var orderSqlite: OrderSQLite {
        get {
            return OrderSQLite()
        }
    }
    
    func getAllMenu() -> Observable<[MenuModel]> {
        let firebaseManager = FireBaseManager()
        firebaseManager.auth()
        let json: Observable<[MenuModel]> = Observable.create { (observer) -> Disposable in
            firebaseManager.getAllMenu { model in
                guard let model = model else { return }
                observer.onNext(model.data)
                observer.onCompleted()
            }
            return Disposables.create()
        }
        return json
    }
    
    func requestMenu(_ menuName: String) -> Observable<MenuModel> {
        let firebaseManager = FireBaseManager()
        firebaseManager.auth()
        let json: Observable<MenuModel> = Observable.create { (observer) -> Disposable in
            firebaseManager.getMenu(menuName: menuName) { model in
                guard let model = model else { return }
                observer.onNext(model)
                observer.onCompleted()
            }
            return Disposables.create()
        }
        return json
    }
    
    func addData(_ type: WhiteType, _ data: [String : Any]) -> Observable<Bool> {
        
        let firebaseManager = FireBaseManager()
        let json: Observable<Bool> = Observable.create { (observer) -> Disposable in
            firebaseManager.addDatabase(type: type, value: data) { suc in
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
            }
            return Disposables.create()
        }
        return json
    }
}
