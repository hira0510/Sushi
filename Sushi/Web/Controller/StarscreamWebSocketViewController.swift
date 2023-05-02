////
////  StarscreamWebSocketViewController.swift
////  socketTest
////
////  Created by  on 2022/7/13.
/////Starscream
//
//import UIKit
//import Starscream
//
//class StarscreamWebSocketViewController: ViewController {
//
//    var webSocket: WebSocket?
//    let testPort = "8888"
//    let testWebSocketIP = "wss://socketsbay.com/wss/v2/1/demo/"
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//
//    private func connect() {
//        if let url = URL(string: testWebSocketIP) {
//            var request = URLRequest(url: url)
//            request.timeoutInterval = 5
//            webSocket = WebSocket(request: request)
//            webSocket?.delegate = self
//            webSocket?.connect()
//        } else {
//            webSocket = nil
//        }
//
//
//        view.endEditing(true)
//    }
//
//    private func stopConnect() {
//        webSocket?.disconnect()
//    }
//
//    func dateStr() -> String {
//        let now = Date()
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        let date = dateFormatter.string(from: now)
//        return date
//    }
//
//    // 設定Ping，來驗證及確保連線是正常的，並回傳一個 Pong
//    @objc private func didClickPingBtn() {
//        guard let data = "Ping".data(using: .utf16) else { return }
//        webSocket?.write(ping: data)
//    }
//}
//
//extension StarscreamWebSocketViewController: WebSocketDelegate {
//    func didReceive(event: WebSocketEvent, client: WebSocket) {
//        switch event {
//        case .connected(_):
//            print("🟢🟢連線成功\n===========================")
//        case .disconnected(let reason, _):
//            print("🟢🟢結束\(reason)")
//            print(self.dateStr() + "\n🟢Server: " + "結束連接" + "\n===========================")
//        case .text(let string):
//            print(self.dateStr() + "\n🟢Server: " + string + "\n")
//        case .binary(let data):
//            let text = String(data: data, encoding: .utf16) ?? ""
//            print(self.dateStr() + "\n🟢Server: " + text + "\n")
//        case .ping(let data):
//            guard let data = data else { return }
//            let text = String(data: data, encoding: .utf16) ?? ""
//            print(self.dateStr() + "🟢ping \(text)")
//        case .pong(let data):
//            guard let data = data else { return }
//            let text = String(data: data, encoding: .utf16) ?? ""
//            print(self.dateStr() + "🟢Pong \(text)")
//        case .viabilityChanged(_):
//            break
//        case .reconnectSuggested(_):
//            break
//        case .cancelled:
//            print(self.dateStr() + "\n🟢Server: " + "結束連接" + "\n")
//        case .error(let error):
//            print("🟢失敗\(String(describing: error))")
//        }
//    }
//}
