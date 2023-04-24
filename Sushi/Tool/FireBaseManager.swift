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

    func auth() {
        Auth.auth().signInAnonymously { (user, error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    typealias CompletionHandler = (_ model: MenuModelData?) -> ()
    func ref(completionHandler: @escaping CompletionHandler) {
        let ref = Database.database().reference(withPath: "Data")
        ref.observe(.value) { snapshot in
            if let output = snapshot.value {
                return completionHandler(MenuModelData(output))
            }
        }
        return completionHandler(nil)
    }

    typealias WriteCompletionHandler = (Bool) -> ()
    func writeSushi(_ menu: String, _ str: String, _ img: UIImage, completionHandler: @escaping WriteCompletionHandler) {
        let storage = Storage.storage()
        let storageRef = storage.reference().child("\(str).png")
        let ref = Database.database().reference()
//        print(str)

        if let uploadData = img.pngData() {
            // 這行就是 FirebaseStorage 關鍵的存取方法。
            storageRef.putData(uploadData, metadata: nil, completion: { (url, error) in
                if error != nil {
                    completionHandler(false)
                    return
                }
                
                storageRef.downloadURL(completion: { (url, err) in
                    if err != nil {
                        completionHandler(false)
                        return
                    }
                    guard let url = url else { return }
                    ref.child("Data/\(menu)/sushi/\(str)").setValue(url.absoluteString)
                    completionHandler(true)
                })
            })
        }
    }
}
