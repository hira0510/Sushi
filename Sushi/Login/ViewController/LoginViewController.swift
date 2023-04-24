//
//  LoginViewController.swift
//  Sushi
//
//  Created by admin on 2023/4/21.
//

import UIKit
import RxCocoa
import RxSwift

class LoginViewController: BaseViewController {
    
    private let viewModel = LoginViewModel()
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
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
            Observable.combineLatest(viewModel.account, viewModel.password) {
                account, password -> Bool in
                return !account.isEmpty && !password.isEmpty
            }.map { $0 }.bind(to: loginBtn.rx.isEnabled).disposed(by: bag)
            
            loginBtn.rx.tap.subscribe { [weak self] event in
                guard let `self` = self else { return }
                Observable.zip(viewModel.account, viewModel.password, viewModel.accountType).subscribe(onNext: { [weak self] (account, password, type) in
                    guard let `self` = self else { return }
                    let isValidAccount = Validation.shared.validate(values: (type: .account, inputValue: account))
                    let isValidPsw = Validation.shared.validate(values: (type: .password, inputValue: password))
                     
                    if isValidAccount.success && isValidPsw.success {
                        SuShiSingleton.share().setIsLoginModel(account, password, type)
                        self.previousBack()
                        self.errorLabel.isHidden = true
                    } else {
                        self.errorLabel.text = isValidAccount.success ? isValidPsw.msg: isValidAccount.msg
                        self.errorLabel.isHidden = false
                    }
                }).disposed(by: self.bag)
            }.disposed(by: bag)
        }
    }
    @IBOutlet weak var changeLoginBtn: UIButton! {
        didSet {
            changeLoginBtn.setTitle("員工登入", for: .normal)
            changeLoginBtn.setTitle("店鋪登入", for: .selected)

            changeLoginBtn.rx.tap.asObservable().map { [weak self] _ -> Bool in
                guard let `self` = self else { return false }
                return !self.changeLoginBtn.isSelected
            }.do { [weak self] isSelect in
                guard let `self` = self else { return }
                self.accountLabel.text = isSelect ? "員工帳號：": "店舖號碼："
                self.passwordLabel.text = isSelect ? "員工密碼：": "店舖密碼："
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
}
