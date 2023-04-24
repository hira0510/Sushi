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
    
    var selectItem: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)
    var sushiCollectionFrame: BehaviorRelay<CGRect> = BehaviorRelay<CGRect>(value: .zero)
    var menuCollectionFrame: BehaviorRelay<CGRect> = BehaviorRelay<CGRect>(value: .zero)
    var menuModel: BehaviorRelay<[MenuModel]> = BehaviorRelay<[MenuModel]>(value: [])
    var orient: UIDeviceOrientation = .portrait
    var isLogin: BehaviorRelay<IsLoginModel> = BehaviorRelay<IsLoginModel>(value: .init())
    
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
            self.orient =  GlobalUtil.isPortrait() ? .portrait: .landscapeLeft
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
