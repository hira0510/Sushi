//
//  BaseViewController.swift
//  Sushi
//
//  Created by admin on 2023/4/21.
//

import UIKit
import RxSwift

class BaseViewController: UIViewController {
    
    internal lazy var bag: DisposeBag! = {
        return DisposeBag()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        addPanGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @objc func previousBack() {
        navigationController?.popViewController(animated: true)
    }
    
    /// 加入返回上一頁的手勢
    private func addPanGestureRecognizer() {
        guard let target = self.navigationController?.interactivePopGestureRecognizer?.delegate else { return }
        let pan: UIPanGestureRecognizer = UIPanGestureRecognizer.init(target: target, action: Selector(("handleNavigationTransition:")))
        self.view.addGestureRecognizer(pan)

        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        pan.delegate = self
    }
    
    func removeToast() {
        for view in self.view.subviews {
            if view.isKind(of: ToastView.self) {
                view.removeFromSuperview()
            }
        }
    }
    
    func addToast(txt: String) {
        let toastView = ToastView(frame: self.view.frame, text: txt)
        toastView.type = .sending
        self.view.addSubview(toastView)
    }
}

extension BaseViewController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        let movePoint: CGPoint = pan.translation(in: self.view)
        let absX: CGFloat = abs(movePoint.x)
        let absY: CGFloat = abs(movePoint.y)
        guard absX > absY, movePoint.x > 0, (self.navigationController?.children.count ?? 0) > 1 else { return false }
        return true
    }
}
