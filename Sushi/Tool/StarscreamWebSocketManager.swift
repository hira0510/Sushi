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

class AddOrderItem {
    var table: String = ""
    var item: String = ""
    var itemPrice: String = ""
    var numId: String = ""
    
    init(_ table: String, _ item: String, _ itemPrice: String, _ numId: String) {
        self.table = table
        self.item = item
        self.itemPrice = itemPrice
        self.numId = numId
    }
}

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
        print(GlobalUtil.dateStr() + "\n🟢Client: " + str + "\n")
    }
    
    func writeData(_ model: [SushiModel], _ numId: Int) {
        let table = SuShiSingleton.share().getPassword()
        var item: String = ""
        var price: String = ""
        for (i, data) in model.enumerated() {
            item.append("\(data.title)")
            price.append("\(data.money)")
            if i < model.count - 1 {
                item.append(",")
                price.append(",")
            }
        }
        writeMsg("桌號:\(table):點餐:\(item):價格:\(price):單號:\(numId)")
    }
    
    func getData(_ str: String) -> AddOrderItem {
        let table = str.replacingOccurrences(of: "桌號:", with: "").components(separatedBy: [":", ","]).first ?? ""
        let item = str.replacingOccurrences(of: "桌號:\(table):點餐:", with: "").components(separatedBy: [":"]).first ?? ""
        let price = str.replacingOccurrences(of: "桌號:\(table):點餐:\(item):價格:", with: "").components(separatedBy: [":"]).first ?? ""
        let numId = str.replacingOccurrences(of: "桌號:\(table):點餐:\(item):價格:\(price):單號:", with: "").components(separatedBy: [":"]).first ?? ""
        return AddOrderItem(table, item, price, numId)
    }
    
    func getServiceText(_ str: String) {
        let table = SuShiSingleton.share().getPassword()
        if str.contains("桌號:\(table)") && str.contains("分鐘") { //Client接收Server的時間
            let table = str.replacingOccurrences(of: "桌號:", with: "").components(separatedBy: [":", ","]).first ?? ""
            let min = str.replacingOccurrences(of: "桌號:\(table):分鐘:", with: "").components(separatedBy: [":", ","]).first ?? ""
            let numId = str.replacingOccurrences(of: "桌號:\(table):分鐘:\(min):numId:", with: "").components(separatedBy: [":", ","]).first ?? ""
            delegate?.getMin(min.toInt, numId)
        } else if str.contains("桌號") && str.contains("點餐") { //Server接收Client的點餐項目
            delegate?.orderHint(data: getData(str))
            playTheSoundEffects(forResource: "record")
        } else if str.contains("結帳桌號") { //Server接收Client的結帳通知
            let table = str.replacingOccurrences(of: "結帳桌號", with: "")
            playTheSoundEffects(forResource: "checkout")
            delegate?.otherHint(table, .checkout)
        } else if str.contains("服務桌號") { //Server接收Client的服務通知
            let table = str.replacingOccurrences(of: "服務桌號", with: "")
            playTheSoundEffects(forResource: "service")
            delegate?.otherHint(table, .service)
        } else if str.contains("桌號\(table)") && str.contains("已結清") { //Client接收Server的結清通知
            delegate?.alreadyCheckedOut()
        } else if str.contains("桌號\(table)") && str.contains("已送達") { //Client接收Server的送達通知
            let numId = str.replacingOccurrences(of: "桌號\(table)已送達,numId:", with: "")
            playTheSoundEffects(forResource: "arrived")
            delegate?.alreadyArrived(numId)
        }
    }

    // 設定Ping，來驗證及確保連線是正常的，並回傳一個 Pong
    @objc private func timerPing() {
        guard let data = "Ping".data(using: .utf16) else { return }
        webSocket?.write(ping: data)
    }
    
    private func playTheSoundEffects(forResource: String) {
        if let url = Bundle.main.url(forResource: forResource, withExtension: "mp3") {
            soundEffectsPlayer = AVPlayer(url: url)
            self.soundEffectsPlayer?.play()
        }
    }
}
 
extension StarscreamWebSocketManager: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(_):
            print("🟢🟢連線成功\n===========================")
        case .disconnected(let reason, _):
            print("🟢🟢結束\(reason)")
            print(GlobalUtil.dateStr() + "\n🟢Server: " + "結束連接" + "\n===========================")
        case .text(let string):
            print(GlobalUtil.dateStr() + "\n🟢Server: " + string + "\n")
            getServiceText(string)
        case .binary(let data):
            let text = String(data: data, encoding: .utf16) ?? ""
            print(GlobalUtil.dateStr() + "\n🟢Server: " + text + "\n")
        case .ping: break
        case .pong: break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            connect()
            print(GlobalUtil.dateStr() + "\n🟢Server: " + "結束連接" + "\n")
        case .error(let error):
            print("🟢失敗\(String(describing: error))")
        }
    }
}
