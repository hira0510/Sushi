//
//  BaseViewController.swift
//  Sushi
//
//  Created by admin on 2023/4/21.
//

import UIKit
import RxSwift

class BaseViewController: UIViewController {
    /// 轉換url
    internal lazy var urlSchemeFactory: UrlSchemeFactory = UrlSchemeFactory()
    
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
    
    public func addAndRemoveToast(txt: String, type: ToastType = .autoRemove) {
        self.removeToast()
        let toastView = ToastView(frame: self.view.frame, text: txt)
        toastView.type = type
        self.view.addSubview(toastView)
    }
    
    typealias GetSchemesHandler = (UrlSchemeFactory) -> ()
    public func changeSchemes(url: String, suc: GetSchemesHandler? = nil) {
        urlSchemeFactory.getUrlSchemeInfo(urlScheme: url)

        switch urlSchemeFactory.mAction {
        case "webview":
            let webView = UIStoryboard.loadWebViewVC(url: urlSchemeFactory.mValue)
            self.present(webView, animated: true, completion: nil)
        case "browser":
            guard let url = URL(string: urlSchemeFactory.mValue) else { break }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        case "order":
            guard !SuShiSingleton.share().getIsAdmin() else { return }
            suc?(urlSchemeFactory)
        case "player":
            suc?(urlSchemeFactory)
        default: break
        }
    }
    
    /// 下方提示窗開啟相簿、相機/掃描
    func bottomAlert(delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)?, btn1Title: String, btn1func: @escaping (UIAlertAction) -> Void) {
        let alertController = UIAlertController(
            title: "",
            message: "請選擇開啟方式".twEng(),
            preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(
          title: "取消".twEng(),
          style: .cancel,
          handler: nil)
        alertController.addAction(cancelAction)
        
        let scanAction = UIAlertAction(title: btn1Title.twEng(), style: .default, handler: btn1func)
        alertController.addAction(scanAction)
        
        let albumAction = UIAlertAction(title: "相簿".twEng(), style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = delegate
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .photoLibrary
            if #available(iOS 13.0, *) {
                imagePicker.modalPresentationStyle = .automatic
            } else {
                imagePicker.modalPresentationStyle = .overFullScreen
            }
            self.present(imagePicker, animated: true)
        }
        alertController.addAction(albumAction)
  
        self.present(alertController, animated: true)
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
