//
//  ExtensionUIStoryboard.swift
//  Sushi
//
//  Created by Hira on 2023/4/28.
//

import UIKit

extension UIStoryboard {

    static func loadBaseNavVC() -> BaseNavViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BaseNavViewController") as! BaseNavViewController
        return vc
    }

    static func loadLoginVC() -> LoginViewController {
        let vc = LoginViewController(nibName: "LoginViewController", bundle: nil)
        return vc
    }

    static func loadAddVC(delegate: AddSushiVcProtocol, menu: [MenuStrModel] = [], edit: (menu: String, data: SushiModel?) = (menu: "", data: nil)) -> AddSushiViewController {
        let vc = AddSushiViewController(nibName: "AddSushiViewController", bundle: nil)
        vc.menuStrAry = menu
        vc.editModel = edit
        vc.delegate = delegate
        return vc
    }

    static func loadOrderVC(model: SushiModel, color: String, protocal: OrderVcProtocol) -> OrderViewController {
        let vc = OrderViewController(nibName: "OrderViewController", bundle: nil)
        vc.viewModel.setSushiModel(model)
        vc.viewModel.bgColor = color
        vc.delegate = protocal
        return vc
    }

    static func loadRecordVC(model: [SushiModel]) -> RecordViewController {
        let vc = RecordViewController(nibName: "RecordViewController", bundle: nil)
        vc.mModel = model.reversed()
        return vc
    }
    
    static func loadWebViewVC(url: String) -> WebViewViewController {
        let vc = WebViewViewController(nibName: "WebViewViewController", bundle: nil)
        vc.mUrl = url
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}
