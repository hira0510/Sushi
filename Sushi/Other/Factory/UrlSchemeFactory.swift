//
//  UrlSchemeFactory.swift
//  Sushi
//
//  Created by Hira on 2023/5/11.
//

import Foundation

class UrlSchemeFactory {

    var mAction: String = ""
    var mValue: String = ""
    var mParam: [String: String]?

    func getUrlSchemeInfo(urlScheme: String) {
        guard urlScheme != "" else { return }
        
        if let urlQuery = URL(string: urlScheme)?.query {
            let encodeStr = urlQuery.htmlToString.urlDecoded()
            mParam = encodeStr.toMsgDic("&", "=")
        } else {
            mParam = nil
        }
        if urlScheme.starts(with: "https://") || urlScheme.starts(with: "http://") {
            mAction = "browser"
            mValue = urlScheme
        } else if urlScheme.starts(with: "webview://") {
            mAction = "webview"
            mValue = urlScheme.components(separatedBy: "webview://?url=")[1]
        } else if urlScheme.starts(with: "sushi://"), let param = mParam {
            if let act = param["act"] {
                mAction = act
            }
            
            if let value = param["value"] {
                mValue = value.urlDecoded()
            }
        }
    }
}
