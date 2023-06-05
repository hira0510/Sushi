//
//  StarscreamWebSocketManager.swift
//  Sushi
//
//  Created by Hira on 2023/4/28.
//

import UIKit
import Starscream
import MediaPlayer

#warning("測試Server端網址：https://socketsbay.com/test-websockets")

enum ServiceType {
    case service
    case checkout
}

protocol StarscreamWebSocketManagerProtocol: AnyObject {
    func getMin(_ min: Int, _ numId: String)
    func otherHint(_ str: String, _ type: ServiceType)
    func orderHint(data: AddOrderItem)
    func clientOrderHint(data: AddOrderItem)
    func clientCheckout()
    func clientRequestGetRecord()
    func clientGetRecord(_ data: [String : String])
    func alreadyArrived(_ numId: String, _ sendItem: String)
    func alreadyCheckedOut()
    func updateMenu(_ menuName: String)
    func isFirstConnectGetRecord()
}

class StarscreamWebSocketManager: NSObject {
    
    private static var instance: StarscreamWebSocketManager? = nil

    public static var shard: StarscreamWebSocketManager {
        get {
            if instance == nil {
                instance = StarscreamWebSocketManager()
            }
            return instance!
        }
    }
    
    weak var delegate: StarscreamWebSocketManagerProtocol?
    
    private var soundEffectsPlayer: AVPlayer?
    private var webSocket: WebSocket?
//    private let testPort = "8888"
    private let testWebSocketIP = "wss://socketsbay.com/wss/v2/1/demo/"
    private var timer: Timer?
    private var isFirstConnect: Bool = true
    
    // MARK: - public
    public func connect() {
        if let url = URL(string: testWebSocketIP) {
            var request = URLRequest(url: url)
            request.timeoutInterval = 5
            webSocket = WebSocket(request: request)
            webSocket?.delegate = self
            webSocket?.connect()
            
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(timerPing), userInfo: nil, repeats: true)
        } else {
            webSocket = nil
        }
    }

    public func stopConnect() {
        webSocket?.disconnect()
        timer?.invalidate()
        timer = nil
    }
    
    public func writeMsg(_ strDic: [String: String]) {
        let str = strDic.toWebMsg
        webSocket?.write(string: "APP:SUSHI " + str)
        print(GlobalUtil.dateStr() + "\n🟢Client: " + str + "\n")
    }
    
    public func getServiceText(_ str: String) {
        let dic = str.toMsgDic(" ", ":")
        guard SuShiSingleton.share().getIsLogin().isLogin else { return }
        if SuShiSingleton.share().getIsAdmin() { //Server
            if dic["msg"] == "order" { //接收Client的點餐項目
                let data = AddOrderItem(dic)
                delegate?.orderHint(data: data)
                playTheSoundEffects(forResource: "record")
            } else if dic["msg"] == "checkout" { //接收Client的結帳通知
                playTheSoundEffects(forResource: "checkout")
                delegate?.otherHint(unwrap(dic["table"], ""), .checkout)
            } else if dic["msg"] == "service" { //接收Client的服務通知
                playTheSoundEffects(forResource: "service")
                delegate?.otherHint(unwrap(dic["table"], ""), .service)
            }
        } else {
            let shopNum = SuShiSingleton.share().getAccount()
            let table = SuShiSingleton.share().getPassword()
            // 是否同店同桌號不同裝置
            let isSameTable = dic["table"] == table && dic["shopNum"] == shopNum && dic["deviceId"] != SystemInfo.getDeviceId()
            if dic["msg"] == "order" && isSameTable { //接收其他Client的點餐項目
                let data = AddOrderItem(dic)
                delegate?.clientOrderHint(data: data)
            } else if dic["msg"] == "checkout" && isSameTable { //接收其他Client的結帳通知
                delegate?.clientCheckout()
            } else if dic["msg"] == "requestGetRecord" && isSameTable { //請求其他Client拿取紀錄
                delegate?.clientRequestGetRecord()
            } else if dic["msg"] == "sendRecord" && isSameTable { //其他Client發送的紀錄
                delegate?.clientGetRecord(dic)
            } else if dic["table"] == table && dic.keys.contains("min") { //接收Server的時間
                delegate?.getMin(unwrap(dic["min"], "").toInt, unwrap(dic["numId"], ""))
            } else if dic["table"] == table && dic["msg"] == "alreadyCheckout" { //接收Server的結清通知
                delegate?.alreadyCheckedOut()
            } else if dic["table"] == table && dic["msg"] == "alreadySend" { //接收Server的送達通知
                playTheSoundEffects(forResource: "arrived")
                delegate?.alreadyArrived(unwrap(dic["numId"], ""), unwrap(dic["item"], ""))
            }
        }
        if dic.keys.contains("menu") && dic["msg"] == "reloadData" && dic["account"] != SuShiSingleton.share().getAccount() {
            delegate?.updateMenu(unwrap(dic["menu"], ""))
        } else if dic.keys.contains("menu") && dic["msg"] == "addReloadData" {
            delegate?.updateMenu(unwrap(dic["menu"], ""))
        }
    }
    
    // MARK: - private
    private func playTheSoundEffects(forResource: String) {
        if let url = Bundle.main.url(forResource: forResource, withExtension: "mp3") {
            soundEffectsPlayer = AVPlayer(url: url)
            self.soundEffectsPlayer?.play()
        }
    }
    
    // MARK: - @objc
    // 設定Ping，來驗證及確保連線是正常的，並回傳一個 Pong
    @objc private func timerPing() {
        guard let data = "Ping".data(using: .utf16) else { return }
        webSocket?.write(ping: data)
    }
}

// MARK: - WebSocketDelegate
extension StarscreamWebSocketManager: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(_):
            print("🟢🟢連線成功\n===========================")
            guard isFirstConnect else { return }
            isFirstConnect = false
            delegate?.isFirstConnectGetRecord()
        case .disconnected(let reason, _):
            print("🟢🟢結束\(reason)")
            print(GlobalUtil.dateStr() + "\n🟢Server: " + "結束連接" + "\n===========================")
        case .text(let string):
            guard string.contains("APP:SUSHI") else { return }
            print(GlobalUtil.dateStr() + "\n🟢Server: " + string + "\n")
            getServiceText(string)
        case .binary(_): break
//            let text = String(data: data, encoding: .utf16) ?? ""
//            print(GlobalUtil.dateStr() + "\n🟢Server: " + text + "\n")
        case .cancelled:
            connect()
            print(GlobalUtil.dateStr() + "\n🟢Server: " + "結束連接" + "\n")
        case .error(let error):
            print("🟢失敗\(String(describing: error))")
        case .ping, .pong, .viabilityChanged(_), .reconnectSuggested(_): break
        }
    }
}
