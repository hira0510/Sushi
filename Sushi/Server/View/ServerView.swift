//
//  ServerView.swift
//  Sushi
//
//  Created by Hira on 2023/5/2.
//

import UIKit
import RxGesture
import SnapKit
import RxSwift
import RxCocoa

enum ServerViewType {
    case service(_ model: [(String, TimeInterval)] = [])
    case record(_ model: [RecordModel] = [])
    case checkout(_ model: [RecordModel] = [], _ time: [TimeInterval] = [])

    var rawStr: String {
        switch self {
        case .service(_):
            return "服務"
        case .record(_):
            return "點餐紀錄"
        case .checkout(_, _):
            return "結帳"
        }
    }

    static func == (lhs: ServerViewType, rhs: ServerViewType) -> Bool {
        return lhs.rawStr == rhs.rawStr
    }

    static func != (lhs: ServerViewType, rhs: ServerViewType) -> Bool {
        return lhs.rawStr != rhs.rawStr
    }
}

class ServerView: UIView, NibOwnerLoadable {

    @IBOutlet var mView: UIView!
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var bgView: NGSCustomizableView!
    @IBOutlet weak var triangleImgView: UIImageView!

    private lazy var bag: DisposeBag! = {
        return DisposeBag()
    }()

    private var orderSqlite: OrderSQLite {
        get {
            return OrderSQLite()
        }
    }

    public var mType: BehaviorRelay<ServerViewType> = BehaviorRelay<ServerViewType>(value: .record())
    public var triangleImgViewConstraints: Constraint? = nil
    private var orderTimer: Timer?

    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        // 如果此view加到父Vc添加timer,反之刪除
        if newSuperview == nil {
            self.orderTimer?.invalidate()
            self.orderTimer = nil
        } else {
            addOrderTimer()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    // MARK: - 私有
    private func commonInit() {
        loadNibContent()
        
        setupTableView()
        mType.bind(to: mTableView.rx.reloadData).disposed(by: bag)

        //View下方三角形隨著父VC點擊的按鈕變換位置
        triangleImgView.snp.makeConstraints { make in
            make.top.equalTo(bgView.snp.bottom).offset(-8)
            make.width.equalTo(40)
            make.height.equalTo(40)
            triangleImgViewConstraints = make.left.equalToSuperview().offset(0).constraint
        }

        //點擊空白處返回
        mView.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.removeFromSuperview()
        }).disposed(by: bag)

        //如果當前在服務通知頁面就不用顯示紅點
        UserDefaults.standard.rx.observe(Dictionary<String, TimeInterval>.self, "serviceTableAry").subscribe(onNext: { [weak self] dic in
            guard let `self` = self, let newDic = dic else { return }
            guard self.mType.value == .service() else { return }
            UserDefaults.standard.serviceHintIsHidden = true
            self.mType.accept(.service(newDic.sortAry))
        }).disposed(by: bag)

        //如果當前在結帳通知頁面就不用顯示紅點
        UserDefaults.standard.rx.observe(Dictionary<String, TimeInterval>.self, "checkoutTableAry").subscribe(onNext: { [weak self] dic in
            guard let `self` = self, let newDic = dic else { return }
            guard self.mType.value == .checkout() else { return }
            let sql = OrderSQLite()
            UserDefaults.standard.checkoutHintIsHidden = true
            self.mType.accept(.checkout(sql.readUniteData(tableAry: newDic.getSortKey), newDic.getSortValue))
        }).disposed(by: bag)
    }

    private func setupTableView() {
        mTableView.delegate = self
        mTableView.dataSource = self
        mTableView.register(RecordTableViewCell.nib, forCellReuseIdentifier: "RecordTableViewCell")
        mTableView.register(RecordFooterView.nib, forHeaderFooterViewReuseIdentifier: "RecordFooterView")
        mTableView.register(ServiceHeaderView.nib, forHeaderFooterViewReuseIdentifier: "ServiceHeaderView")
        mTableView.allowsMultipleSelectionDuringEditing = false
        mTableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
        mTableView.rowHeight = GlobalUtil.calculateWidthHorizontalScaleWithSize(width: 35)
        mTableView.separatorColor = .black
        mTableView.reloadData()
    }
    
    private func addOrderTimer() {
        orderTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(timerReciprocal), userInfo: nil, repeats: true)
    }
    
    // MARK: - @objc
    @objc private func timerReciprocal() {
        mTableView.reloadData()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ServerView: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        switch mType.value {
        case .service:
            return 1
        case .record(let model):
            return model.count
        case .checkout(let model, _):
            return model.count
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch mType.value {
        case .service(let model):
            return model.count
        case .record(let model):
            return model[section].item.count
        case .checkout(let model, _):
            return model[section].item.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordTableViewCell", for: indexPath) as! RecordTableViewCell
        switch mType.value {
        case .service(let model):
            cell.adminServiceCellConfig(model[indexPath.item])
        case .record(let model):
            let type: RecordType = RecordType.getType(model[indexPath.section].timestamp)
            cell.adminRecordCellConfig(model[indexPath.section].item[indexPath.item], type: type)
        case .checkout(let model, _):
            cell.adminCheckoutCellConfig(model[indexPath.section].item[indexPath.item])
        }
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ServiceHeaderView") as! ServiceHeaderView
        switch mType.value {
        case .service:
            return nil
        case .record(let model):
            header.configView(model: model[section], section: section, text: "桌", delegate: self, type: mType.value)
        case .checkout(let model, let time):
            let price = model[section].item.map { $0.price.toInt }
            let resultPrice = price.reduce(0, { $0 + $1 })
            let text = "桌 " + resultPrice.toStr + "元 " + GlobalUtil.specificTimeIntervalStr(timeInterval: time[section], format: "HH:mm:ss")
            header.configView(model: model[section], section: section, text: text, delegate: self, type: mType.value)
        }
        return header
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch mType.value {
        case .service, .checkout(_, _):
            return nil
        case .record(let model):
            let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: "RecordFooterView") as! RecordFooterView
            footer.configView(model: model[section], section: section, delegate: self)
            return footer
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch mType.value {
        case .service, .checkout(_, _): return 0
        case .record(_): return 50
        }
    }
}

// MARK: - Header的Protocol
extension ServerView: ServiceHeaderProtocol {
    /// 點擊完成更新SQL,且通知Client端(已結清/已送達)
    func clickCompleteBtn(_ section: Int) {
        switch mType.value {
        case .service: break
        case .checkout(let models, _):
            let table = models[section].tableNumber
            StarscreamWebSocketManager.shard.writeMsg("桌號\(table)已結清")
            UserDefaults.standard.checkoutTableAry.removeValue(forKey: table)
            orderSqlite.delData(_tableNumber: table)
        case .record(let models):
            let model = models[section]
            StarscreamWebSocketManager.shard.writeMsg("桌號\(model.tableNumber)已送達,numId:\(model.numId)")
            orderSqlite.updateIsCompleteData(_id: model.id, _isComplete: true, success: { [weak self] in
                guard let `self` = self else { return }
                let recordModel = orderSqlite.readData()
                mType.accept(.record(recordModel))
            })
        }
    }
}

// MARK: - Footer的Protocol
extension ServerView: RecordFooterViewProtocol {
    /// 點擊x分鐘更新SQL,且通知Client端預定送達時間
    func clickMinBtn(_ min: String, _ section: Int) {
        switch mType.value {
        case .service, .checkout(_, _): break
        case .record(let models):
            let model = models[section]
            StarscreamWebSocketManager.shard.writeMsg("桌號:\(model.tableNumber):分鐘:\(min):numId:\(model.numId)")
            let timeStamp = min.toTime * 60 + GlobalUtil.getCurrentTime()
            orderSqlite.updateTimeData(_id: model.id, _timeStamp: timeStamp, success: { [weak self] in
                guard let `self` = self else { return }
                let recordModel = orderSqlite.readData()
                mType.accept(.record(recordModel))
            })
        }
    }
}
