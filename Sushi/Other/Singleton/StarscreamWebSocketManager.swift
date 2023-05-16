//
//  StarscreamWebSocketManager.swift
//  Sushi
//
//  Created by Hira on 2023/4/28.
//

import UIKit
import Starscream
import MediaPlayer

#warning("測試Server端網址：https://www.piesocket.com/websocket-tester")

enum ServiceType {
    case service
    case checkout
}

protocol StarscreamWebSocketManagerProtocol: AnyObject {
    func getMin(_ min: Int, _ numId: String)
    func otherHint(_ str: String, _ type: ServiceType)
    func orderHint(data: AddOrderItem)
    func alreadyArrived(_ numId: String)
    func alreadyCheckedOut()
    func updateMenu(_ menuName: String)
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
        if SuShiSingleton.share().getIsAdmin() { //Server
            if dic.keys.contains("桌號") && dic.keys.contains("點餐") { //接收Client的點餐項目
                let data = AddOrderItem(dic)
                delegate?.orderHint(data: data)
                playTheSoundEffects(forResource: "record")
            } else if dic["msg"] == "結帳" { //接收Client的結帳通知
                playTheSoundEffects(forResource: "checkout")
                delegate?.otherHint(unwrap(dic["桌號"], ""), .checkout)
            } else if dic["msg"] == "服務" { //接收Client的服務通知
                playTheSoundEffects(forResource: "service")
                delegate?.otherHint(unwrap(dic["桌號"], ""), .service)
            }
        } else {
            let table = SuShiSingleton.share().getPassword()
            if dic["桌號"] == table && dic.keys.contains("分鐘") { //接收Server的時間
                delegate?.getMin(unwrap(dic["分鐘"], "").toInt, unwrap(dic["numId"], ""))
            } else if dic["桌號"] == table && dic["msg"] == "已結清" { //接收Server的結清通知
                delegate?.alreadyCheckedOut()
            } else if dic["桌號"] == table && dic["msg"] == "已送達" { //接收Server的送達通知
                playTheSoundEffects(forResource: "arrived")
                delegate?.alreadyArrived(unwrap(dic["numId"], ""))
            }
        }
        if dic.keys.contains("menu") && dic["msg"] == "reloadData" {
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
        case .disconnected(let reason, _):
            print("🟢🟢結束\(reason)")
            print(GlobalUtil.dateStr() + "\n🟢Server: " + "結束連接" + "\n===========================")
        case .text(let string):
            guard string.contains("APP:SUSHI") else { return }
            print(GlobalUtil.dateStr() + "\n🟢Server: " + string + "\n")
            getServiceText(string)
        case .binary(let data):
            let text = String(data: data, encoding: .utf16) ?? ""
            print(GlobalUtil.dateStr() + "\n🟢Server: " + text + "\n")
        case .cancelled:
            connect()
            print(GlobalUtil.dateStr() + "\n🟢Server: " + "結束連接" + "\n")
        case .error(let error):
            print("🟢失敗\(String(describing: error))")
        case .ping, .pong, .viabilityChanged(_), .reconnectSuggested(_): break
        }
    }
}
