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
    
    deinit {
        NSLog("\(self.className)釋放")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addPanGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - public
    public func removeToast() {
        for view in self.view.subviews {
            if view.isKind(of: ToastView.self) {
                view.removeFromSuperview()
            }
        }
    }
    
    public func addToast(txt: String, type: ToastType = .autoRemove) {
        let toastView = ToastView(frame: self.view.frame, text: txt)
        toastView.type = type
        self.view.addSubview(toastView)
    }
    
    // MARK: - private
    /// 加入返回上一頁的手勢
    private func addPanGestureRecognizer() {
        guard let target = self.navigationController?.interactivePopGestureRecognizer?.delegate else { return }
        let pan: UIPanGestureRecognizer = UIPanGestureRecognizer.init(target: target, action: Selector(("handleNavigationTransition:")))
        self.view.addGestureRecognizer(pan)

        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        pan.delegate = self
    }
    
    // MARK: - @objc
    @objc public func previousBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc public func dismissVc() {
        self.dismiss(animated: true)
    }
}

// MARK: - 返回手勢
extension BaseViewController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        let movePoint: CGPoint = pan.translation(in: self.view)
        let absX: CGFloat = abs(movePoint.x)
        let absY: CGFloat = abs(movePoint.y)
        guard absX > absY, movePoint.x > 0, unwrap(self.navigationController?.children.count, 0) > 1 else { return false }
        return true
    }
}
