//
//  StarscreamWebSocketManager.swift
//  Sushi
//
//  Created by Hira on 2023/4/28.
//

import UIKit
import Starscream

#warning("測試Server端網址：https://www.piesocket.com/websocket-tester")

protocol StarscreamWebSocketManagerProtocol: AnyObject {
    func getMin(_ str: String)
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
    private var webSocket: WebSocket?
    private let testPort = "8888"
    private let testWebSocketIP = "wss://socketsbay.com/wss/v2/1/demo/"
    private var timer: Timer?

    func connect() {
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

    func stopConnect() {
        webSocket?.disconnect()
        timer?.invalidate()
        timer = nil
    }
    
    func writeMsg(_ str: String) {
        webSocket?.write(string: str)
        print(self.dateStr() + "\n🟢Client: " + str + "\n")
    }
    
    func writeData(_ model: [SushiModel]) {
        let table = SuShiSingleton.share().getPassword()
        writeMsg("桌號\(table) 點餐")
        for data in model {
            writeMsg(data.title)
        }
    }
    
    func getServiceText(_ str: String) { // ex: 桌號13,5分鐘
        let table = SuShiSingleton.share().getPassword()
        if str.contains("桌號\(table)") && str.contains("分鐘") {
            let parts = str.components(separatedBy: [","])
            let minPart = parts.count == 2 ? String(parts[1]): "0"
            let min = minPart.replacingOccurrences(of: "分鐘", with: "")
            delegate?.getMin(min)
        } else if str.contains("桌號\(table)") && str.contains("點餐") {
            //這邊還沒好 想要做Server對Client傳送一些資訊
            writeMsg("桌號13,5分鐘")
        }
    }
    
    private func dateStr() -> String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.string(from: now)
        return date
    }

    // 設定Ping，來驗證及確保連線是正常的，並回傳一個 Pong
    @objc private func timerPing() {
        guard let data = "Ping".data(using: .utf16) else { return }
        webSocket?.write(ping: data)
    }
}
 
extension StarscreamWebSocketManager: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(_):
            print("🟢🟢連線成功\n===========================")
        case .disconnected(let reason, _):
            print("🟢🟢結束\(reason)")
            print(self.dateStr() + "\n🟢Server: " + "結束連接" + "\n===========================")
        case .text(let string):
            print(self.dateStr() + "\n🟢Server: " + string + "\n")
            getServiceText(string)
        case .binary(let data):
            let text = String(data: data, encoding: .utf16) ?? ""
            print(self.dateStr() + "\n🟢Server: " + text + "\n")
        case .ping(let data): break
//            guard let data = data else { return }
//            let text = String(data: data, encoding: .utf16) ?? ""
//            print(self.dateStr() + "🟢ping \(text)")
        case .pong(let data): break
//            guard let data = data else { return }
//            let text = String(data: data, encoding: .utf16) ?? ""
//            print(self.dateStr() + "🟢Pong \(text)")
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            connect()
            print(self.dateStr() + "\n🟢Server: " + "結束連接" + "\n")
        case .error(let error):
            print("🟢失敗\(String(describing: error))")
        }
    }
}
