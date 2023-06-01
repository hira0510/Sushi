//
//  LoginViewController.swift
//  Sushi
//
//  Created by admin on 2023/4/21.
//

import UIKit
import RxCocoa
import RxSwift
import AVFoundation

class LoginViewController: BaseViewController {
    
    private let viewModel = LoginViewModel()
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var qrcodeBtn: UIButton! {
        didSet {
            qrcodeBtn.rx.tap.subscribe { [weak self] event in
                guard let `self` = self else { return }
                self.view.endEditing(true)
                self.bottomAlert(delegate: self, btn1Title: "掃描".twEng(), btn1func: { [weak self] _ in
                    guard let `self` = self else { return }
                    let scannerVc = ScannerViewController()
                    scannerVc.delegate = self
                    self.present(scannerVc, animated: true)
                })
            }.disposed(by: bag)
        }
    }
    @IBOutlet weak var accountTextField: UITextField! {
        didSet {
            accountTextField.rx.text.orEmpty.bind(to: viewModel.account).disposed(by: bag)
            accountTextField.rx.controlEvent(.editingDidEndOnExit).subscribe(onNext: {
                [weak self] (_) in
                guard let `self` = self else { return }
                self.passwordTextField.becomeFirstResponder()
            }).disposed(by: bag)
        }
    }
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.rx.text.orEmpty.bind(to: viewModel.password).disposed(by: bag)
        }
    }
    @IBOutlet weak var loginBtn: UIButton! {
        didSet {
            //綁定帳密都有輸入才可點擊
            Observable.combineLatest(viewModel.account, viewModel.password) {
                account, password -> Bool in
                return !account.isEmpty && !password.isEmpty
            }.map { $0 }.bind(to: loginBtn.rx.isEnabled).disposed(by: bag)
            
            //點擊後核對帳密，成功後轉到主要頁面
            loginBtn.rx.tap.subscribe { [weak self] event in
                guard let `self` = self else { return }
                self.didClickLoginBtn()
            }.disposed(by: bag)
        }
    }
    @IBOutlet weak var changeLoginBtn: UIButton! {
        didSet {
            //點擊更換管理者登入/一般登入
            changeLoginBtn.rx.tap.asObservable().map { [weak self] _ -> Bool in
                guard let `self` = self else { return false }
                return !self.changeLoginBtn.isSelected
            }.do { [weak self] isSelect in
                guard let `self` = self else { return }
                self.passwordTextField.keyboardType = isSelect ? .asciiCapable: .numberPad
                self.passwordTextField.reloadInputViews()
                self.accountLabel.text = isSelect ? "員工帳號": "店舖號碼"
                self.passwordLabel.text = isSelect ? "員工密碼": "店舖桌號"
                self.viewModel.accountType.accept(isSelect ? .administrator: .normal)
            }.bind(to: changeLoginBtn.rx.isSelected).disposed(by: bag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func didClickLoginBtn() {
        Observable.zip(self.viewModel.account, self.viewModel.password, self.viewModel.accountType).subscribe(onNext: { [weak self] (account, password, type) in
            guard let `self` = self else { return }
            let isValidAccount = Validation.shared.validate(values: (type: .account, inputValue: account))
            let isValidPsw = Validation.shared.validate(values: (type: type == .normal ? .num: .password, inputValue: password))
             
            if isValidAccount.success && isValidPsw.success {
                SuShiSingleton.share().setIsLoginModel(account, password, type)
                let vc = UIStoryboard.loadBaseNavVC()
                SceneDelegate().changeRootVc(vc: vc)
                self.errorLabel.isHidden = true
            } else {
                self.errorLabel.text = isValidAccount.success ? isValidPsw.msg: isValidAccount.msg
                self.errorLabel.isHidden = false
            }
        }).disposed(by: self.bag)
    }
}

extension LoginViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //取得相片後讀取QRCode
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]),
        let ciImage = CIImage(image: pickedImage),
        let features = detector.features(in: ciImage) as? [CIQRCodeFeature] else { return }
        
        let qrCodeLink = features.reduce("") { $0 + ($1.messageString ?? "") }
        getQrCodeStringToDic(qrCodeLink)
        picker.dismiss(animated: true, completion: nil)
    }
    
}
extension LoginViewController: ScannerVcProtocol {
    /// 拿到QRCode之後的處理
    func getQrCodeStringToDic(_ str: String) {
        let strToDic = str.toMsgDic(",", ":")
        self.viewModel.account.accept(unwrap(strToDic["shopNum"], ""))
        self.viewModel.password.accept(unwrap(strToDic["table"], ""))
        viewModel.accountType.accept(.normal)
        didClickLoginBtn()
    }
}
