//
//  AddSushiViewModel.swift
//  Sushi
//
//  Created by admin on 2023/4/21.
//

import UIKit
import RxCocoa
import RxSwift

class AddSushiViewModel: NSObject {
    
    var mName: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    var mNameEng: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    var mPrice: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    var mImage: BehaviorRelay<UIImage> = BehaviorRelay<UIImage>(value: UIImage(named: "noImg")!)
    
    func addData(_ type: WhiteType, imgUrl: String = "") -> Observable<Bool> {
        var value: String = ""
        switch type {
        case .img: value = imgUrl
        case .money: value = mPrice.value
        case .titleEng: value = mNameEng.value
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
    
    func addStorageImg() -> Observable<String> {
        let firebaseManager = FireBaseManager()
        let json: Observable<String> = Observable.create { [weak self] (observer) -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            firebaseManager.addStorageImg(self.mName.value, self.mImage.value) { url in
                guard let urlStr = url else { return }
                observer.onNext(urlStr)
                observer.onCompleted()
            }
            return Disposables.create()
        }
        return json
    }
}
