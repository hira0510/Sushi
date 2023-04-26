//
//  MenuViewModel.swift
//  Sushi
//
//  Created by admin on 2023/4/20.
//

import UIKit
import RxCocoa
import RxSwift

class MenuViewModel: NSObject {
    
    var orient: UIDeviceOrientation = .unknown
    var selectItem: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)
    var sushiCollectionFrame: BehaviorRelay<CGRect> = BehaviorRelay<CGRect>(value: .zero)
    var menuCollectionFrame: BehaviorRelay<CGRect> = BehaviorRelay<CGRect>(value: .zero)
    var menuModel: BehaviorRelay<[MenuModel]> = BehaviorRelay<[MenuModel]>(value: [])
    var isLogin: BehaviorRelay<IsLoginModel> = BehaviorRelay<IsLoginModel>(value: .init())
    var isEng: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
    var isNotEdit: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: true)
    
    func request() -> Observable<Bool> {
        let firebaseManager = FireBaseManager()
        firebaseManager.auth() 
        let json: Observable<Bool> = Observable.create { (observer) -> Disposable in
            firebaseManager.ref { [weak self] model in
                guard let `self` = self, let model = model else { return }
                self.menuModel.accept(model.data)
                
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
    
    func delStorageImg(_ index: Int) -> Observable<Bool> {
        let firebaseManager = FireBaseManager()
        let title = menuModel.value[selectItem.value].sushi[index].title
        let json: Observable<Bool> = Observable.create { [weak self] (observer) -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            firebaseManager.delStorageImg(title) { _ in
                observer.onNext(true)
                observer.onCompleted()
                print("刪除圖片\(title)")
            }
            return Disposables.create()
        }
        return json
    }

    func getHSpace(_ type: CollectionViewType) -> CGFloat {
        return type == .menu ? 5 : 10
    }

    func getWSpace(_ type: CollectionViewType) -> CGFloat {
        return type == .menu ? 5 : 10
    }

    func getColumn() -> Int {
        switch orient {
        case .landscapeLeft, .landscapeRight: return 3
        case .portrait, .portraitUpsideDown: return 2
        default:
            self.orient = GlobalUtil.isPortrait() ? .portrait: .landscapeLeft
            return getColumn()
        }
    }

    /// 拿取cell的寬高
    func getCellSize() -> CGSize {
        let wSpace = getWSpace(.sushi)
        //w
        let cellSpaceWidth = wSpace * (getColumn().toDouble - 1)
        let cellAllWidth = floor(sushiCollectionFrame.value.width - 20) - cellSpaceWidth
        let cellMaxWidth = (cellAllWidth / getColumn().toDouble).rounded(.down)
        //h
        let cellMaxHeight = cellMaxWidth / 130 * 135

        return CGSize(width: cellMaxWidth, height: cellMaxHeight)
    }
}
