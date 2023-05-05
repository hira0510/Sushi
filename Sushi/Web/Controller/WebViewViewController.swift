//
//  WebViewViewController.swift
//  Sushi
//
//  Created by Hira on 2023/4/28.
//

import UIKit
import WebKit
import SnapKit

class WebViewViewController: BaseViewController {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var backBtn: UIButton!

    private var wkWebView: WKWebView = WKWebView()
    public var mUrl: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIWithDelegate()
    }

    // MARK: - 私有
    private func initWebView() {
        self.view.addSubview(wkWebView)
        wkWebView.navigationDelegate = self
        wkWebView.snp.makeConstraints { (make) in
            make.top.equalTo(navBar.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    private func setupUIWithDelegate() {
        backBtn.addTarget(self, action: #selector(dismissVc), for: .touchUpInside)
        navigationController?.setNavigationBarHidden(true, animated: true)
        initWebView()

        guard let url = URL(string: mUrl) else { return }
        let request = URLRequest(url: url)
        wkWebView.load(request)
    }
}

// MARK: - WKNavigationDelegate
extension WebViewViewController: WKNavigationDelegate, WKScriptMessageHandler {
  
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) { }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) { }
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) { }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) { }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) { }
}
