//
//  FireBaseManager.swift
//  Sushi
//
//  Created by admin on 2023/4/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import RxSwift
import RxCocoa

enum WhiteType {
    case img(_ menu: String, _ title: String)
    case titleEng(_ menu: String, _ title: String)
    case money(_ menu: String, _ title: String)
    
    var pathStr: String {
        switch self {
        case .img(let menu, let title): return "Data/\(menu)/sushiImg/\(title)"
        case .titleEng(let menu, let title): return "Data/\(menu)/sushiEng/\(title)"
        case .money(let menu, let title): return "Data/\(menu)/sushiMoney/\(title)"
        }
    }
}

enum MsgRequestStatus {
    case success(_ msg: String = "")
    case error(_ msg: String = "")
}

class FireBaseManager: NSObject {

    private static var instance: FireBaseManager? = nil

    public static var shard: FireBaseManager {
        get {
            if instance == nil {
                instance = FireBaseManager()
            }
            return instance!
        }
    }

    internal lazy var bag: DisposeBag! = {
        return DisposeBag()
    }()

    func auth() {
        Auth.auth().signInAnonymously { (user, error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    typealias CompletionHandler = (_ model: MenuModelData?) -> ()
    typealias WriteCompletionHandler = (Bool?) -> ()
    typealias StorageCompletionHandler = (String?) -> ()
    
    func ref(completionHandler: @escaping CompletionHandler) {
        let ref = Database.database().reference(withPath: "Data")
        ref.observe(.value) { snapshot in
            if let output = snapshot.value {
                return completionHandler(MenuModelData(output))
            }
        }
        return completionHandler(nil)
    }
    
    func addDatabase(type: WhiteType, value: String, completionHandler: @escaping WriteCompletionHandler) {
        let ref = Database.database().reference()
        ref.child(type.pathStr).setValue(value) { error, databaseReference in
            if error != nil {
                return completionHandler(nil)
            }
            return completionHandler(true)
        }
        return completionHandler(nil)
    }
    
    func delDatabase(type: WhiteType, completionHandler: @escaping WriteCompletionHandler) {
        let ref = Database.database().reference()
        ref.child(type.pathStr).setValue(nil) { error, databaseReference in
            if error != nil {
                return completionHandler(nil)
            }
            return completionHandler(true)
        }
        return completionHandler(nil)
    }
    
    func addStorageImg(_ title: String, _ img: UIImage, completionHandler: @escaping StorageCompletionHandler) {
        let storage = Storage.storage()
        let storageRef = storage.reference().child("\(title).png")
        guard let uploadData = img.pngData() else { return completionHandler(nil) }
        
        // 這行就是 FirebaseStorage 關鍵的存取方法。
        storageRef.putData(uploadData, metadata: nil, completion: { (_, error) in
            if error != nil { return completionHandler(nil) }
            storageRef.downloadURL(completion: { (url, err) in
                if error != nil { return }
                guard let url = url else { return completionHandler(nil) }
                return completionHandler(url.absoluteString)
            })
        })
        return completionHandler(nil)
    }
    
    func delStorageImg(_ title: String, completionHandler: @escaping WriteCompletionHandler) {
        let storage = Storage.storage()
        let storageRef = storage.reference().child("\(title).png")
        
        storageRef.delete { error in
            if error != nil { return completionHandler(nil) }
            return completionHandler(true)
        }
        return completionHandler(nil)
    }

//    func storageImgRx(_ title: String, _ img: UIImage) -> Observable<String> {
//        let storage = Storage.storage()
//        let storageRef = storage.reference().child("\(title).png")
//
//        guard let uploadData = img.pngData() else { return Observable.just("") }
//
//        let request: Observable<String> = Observable.create { (observer) -> Disposable in
//            // 這行就是 FirebaseStorage 關鍵的存取方法。
//            storageRef.putData(uploadData, metadata: nil, completion: { (_, error) in
//                if error != nil { return }
//                storageRef.downloadURL(completion: { (url, err) in
//                    if error != nil { return }
//                    guard let url = url else { return }
//                    observer.onNext(url.absoluteString)
//                    observer.onCompleted()
//                })
//            })
//            return Disposables.create()
//        }
//        return request
//    }
    
//    func addData(_ type: WhiteType, _ value: String) -> Observable<MsgRequestStatus> {
//        let ref = Database.database().reference()
//        let request: Observable<MsgRequestStatus> = Observable.create { (observer) -> Disposable in
//            ref.child(type.pathStr).setValue(value) { error, databaseReference in
//                if error != nil {
//                    observer.onNext(.error())
//                    return
//                }
//                observer.onNext(.success())
//                observer.onCompleted()
//            }
//            return Disposables.create()
//        }
//        return request
//    }
}
