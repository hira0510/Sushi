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
    case addSushi(_ menu: String, _ index: String)
    case dropEditSushi(_ menu: String)
    
    var indexStr: String {
        switch self {
        case .addSushi(_, let index): return index
        case .dropEditSushi: return "-1"
        }
    }
    var pathStr: String {
        switch self {
        case .addSushi(let menu, let index): return "Data/\(menu)/sushi/\(index)"
        case .dropEditSushi(let menu): return "Data/\(menu)/sushi"
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
    typealias CompletionDataHandler = (_ data: MenuModel?) -> ()
    typealias WriteCompletionHandler = (Bool?) -> ()
    typealias StorageCompletionHandler = (String?) -> ()
    
    /// 拿全部資料api
    func getAllMenu(completionHandler: @escaping CompletionHandler) {
        let ref = Database.database().reference()
        ref.child("Data").getData { _, snapshot in
            if let output = snapshot?.value {
                return completionHandler(MenuModelData(output))
            }
        }
        return completionHandler(nil)
    }
    
    /// 拿指定menu資料api
    func getMenu(menuName: String, completionHandler: @escaping CompletionDataHandler) {
        let ref = Database.database().reference()
        ref.child("Data/\(menuName)").getData { _, snapshot in
            if let output = snapshot?.value {
                return completionHandler(MenuModel().data(menuName, output))
            }
        }
        return completionHandler(nil)
    }
    
    /// 新增品項api
    func addDatabase(type: WhiteType, value: [String : Any], completionHandler: @escaping WriteCompletionHandler) {
        let ref = Database.database().reference()
        ref.child(type.pathStr).setValue(value) { error, databaseReference in
            if error != nil {
                return completionHandler(nil)
            }
            return completionHandler(true)
        }
        return completionHandler(nil)
    }
    
    /// 刪除品項api
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
    
    /// 新增圖片api
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
    
    /// 刪除圖片api
    func delStorageImg(_ title: String, completionHandler: @escaping WriteCompletionHandler) {
        let storage = Storage.storage()
        let storageRef = storage.reference().child("\(title).png")
        
        storageRef.delete { error in
            if error != nil { return completionHandler(nil) }
            return completionHandler(true)
        }
        return completionHandler(nil)
    }
}
