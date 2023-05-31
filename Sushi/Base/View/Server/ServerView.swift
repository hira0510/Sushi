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

class ServerView: BaseView {

    @IBOutlet var mView: UIView!
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var bgView: NGSCustomizableView!
    @IBOutlet weak var triangleImgView: UIImageView!

    private var mType: BehaviorRelay<ServerViewType> = BehaviorRelay<ServerViewType>(value: .record())
    private var triangleImgViewConstraints: Constraint? = nil
    private var orderTimer: Timer?
    /// 已選取的項目
    private var selectIndexAry: [IndexPath] = []

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
    
    // MARK: - public
    public func getType() -> ServerViewType { return mType.value }
    public func setupType(_ type: ServerViewType, _ section: Int? = nil) {
        mType.accept(type)
        mTableView.allowsSelection = type == .record()
        mTableView.allowsMultipleSelection = type == .record()
        guard let section = section else { return mTableView.toReloadData() }
        mTableView.toReloadSection(section)
    }
    public func setupConstraints(_ constraints: CGFloat) {
        triangleImgViewConstraints?.update(offset: constraints)
    }

    // MARK: - private
    private func commonInit() {
        loadNibContent()
        
        setupTableView()

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
            guard self.getType() == .service() else { return }
            UserDefaults.standard.serviceHintIsHidden = true
            self.setupType(.service(newDic.sortTimeAry))
        }).disposed(by: bag)

        //如果當前在結帳通知頁面就不用顯示紅點
        UserDefaults.standard.rx.observe(Dictionary<String, TimeInterval>.self, "checkoutTableAry").subscribe(onNext: { [weak self] dic in
            guard let `self` = self, let newDic = dic else { return }
            guard self.getType() == .checkout() else { return }
            let sql = OrderSQLite()
            UserDefaults.standard.checkoutHintIsHidden = true
            self.setupType(.checkout(sql.readUniteData(tableAry: newDic.getSortTimeKey), newDic.getSortTimeValue))
        }).disposed(by: bag)
    }

    private func setupTableView() {
        mTableView.delegate = self
        mTableView.dataSource = self
        mTableView.register(RecordTableViewCell.nib, forCellReuseIdentifier: "RecordTableViewCell")
        mTableView.register(RecordFooterView.nib, forHeaderFooterViewReuseIdentifier: "RecordFooterView")
        mTableView.register(ServiceHeaderView.nib, forHeaderFooterViewReuseIdentifier: "ServiceHeaderView")
        mTableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
        mTableView.rowHeight = GlobalUtil.calculateWidthHorizontalScaleWithSize(width: 35)
        mTableView.separatorColor = .black
        mTableView.toReloadData()
    }
    
    private func addOrderTimer() {
        orderTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(timerReciprocal), userInfo: nil, repeats: true)
    }
    
    // MARK: - @objc
    @objc private func timerReciprocal() {
        mTableView.toReloadData()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ServerView: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        switch getType() {
        case .service:
            return 1
        case .record(let model):
            return model.count
        case .checkout(let model, _):
            return model.count
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch getType() {
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
        switch getType() {
        case .service(let model):
            cell.adminServiceCellConfig(model[indexPath.row])
        case .record(let models):
            let model = models[indexPath.section]
            let item = model.item[indexPath.row]
            let isSelect = selectIndexAry.contains(indexPath)
            let type: RecordType = RecordType.getType(model.timestamp, item.isComplete)
            cell.adminRecordCellConfig(item, type: type, isSelect: isSelect)
        case .checkout(let model, _):
            cell.adminCheckoutCellConfig(model[indexPath.section].item[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch getType() {
        case .service, .checkout: return
        case .record(let model):
            guard !model[indexPath.section].item[indexPath.row].isComplete, let cell = tableView.cellForRow(at: indexPath) as? RecordTableViewCell else { return }
            cell.isSelectChangeBg(true, false)
            selectIndexAry = unwrap(tableView.indexPathsForSelectedRows, [])
            guard let header = tableView.headerView(forSection: indexPath.section) as? ServiceHeaderView else { return }
            header.completeBtn.isEnabled = selectIndexAry.count > 0
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        switch getType() {
        case .service, .checkout: return
        case .record(let model):
            guard !model[indexPath.section].item[indexPath.row].isComplete, let cell = tableView.cellForRow(at: indexPath) as? RecordTableViewCell else { return }
            cell.isSelectChangeBg(false, false)
            selectIndexAry = unwrap(tableView.indexPathsForSelectedRows, [])
            guard let header = tableView.headerView(forSection: indexPath.section) as? ServiceHeaderView else { return }
            header.completeBtn.isEnabled = selectIndexAry.count > 0
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ServiceHeaderView") as! ServiceHeaderView
        switch getType() {
        case .service:
            return nil
        case .record(let model):
            header.configView(model: model[section], section: section, text: "桌", delegate: self, type: getType(), selectCount: selectIndexAry.count)
        case .checkout(let model, let time):
            let price = model[section].item.map { $0.price.toInt }
            let resultPrice = price.reduce(0, { $0 + $1 })
            let text = "桌 " + resultPrice.toStr + "元 " + GlobalUtil.specificTimeIntervalStr(timeInterval: time[section], format: "HH:mm:ss")
            header.configView(model: model[section], section: section, text: text, delegate: self, type: getType(), selectCount: 0)
        }
        return header
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch getType() {
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
        switch getType() {
        case .service, .checkout(_, _): return 0
        case .record(_): return 50
        }
    }
}

// MARK: - Header的Protocol
extension ServerView: ServiceHeaderProtocol {
    /// 點擊完成更新SQL,且通知Client端(已結清/已送達)
    func clickCompleteBtn(_ section: Int) {
        switch getType() {
        case .service: break
        case .checkout(let models, _):
            let table = models[section].tableNumber
            StarscreamWebSocketManager.shard.writeMsg(["桌號": table, "msg": "已結清"])
            UserDefaults.standard.checkoutTableAry.removeValue(forKey: table)
            orderSqlite.delData(_tableNumber: table)
        case .record(let models):
            let model = models[section]
            var sendData: [String] = []
            self.selectIndexAry.forEach { indexpath in
                model.item[indexpath.item].isComplete = true
                sendData.append(model.item[indexpath.item].name)
                self.mTableView.deselectRow(at: indexpath, animated: false)
            }
            self.selectIndexAry = []
            StarscreamWebSocketManager.shard.writeMsg(["桌號": model.tableNumber, "msg": "已送達", "numId": model.numId, "item": sendData.aryToStr])
            let isComplete = model.item.compactMap { $0.isComplete }
            let isCompleteStr = isComplete.aryToStr
            self.orderSqlite.updateIsCompleteData(_id: model.id, _isComplete: isCompleteStr, success: { [weak self] in
                guard let `self` = self else { return }
                let recordModel = self.orderSqlite.readData()
                self.setupType(.record(recordModel), section)
            })
        }
    }
}

// MARK: - Footer的Protocol
extension ServerView: RecordFooterViewProtocol {
    /// 點擊x分鐘更新SQL,且通知Client端預定送達時間
    func clickMinBtn(_ min: String, _ section: Int) {
        switch getType() {
        case .service, .checkout(_, _): break
        case .record(let models):
            let model = models[section]
            StarscreamWebSocketManager.shard.writeMsg(["桌號": model.tableNumber, "分鐘": min, "numId": model.numId])
            let timeStamp = min.toTime * 60 + GlobalUtil.getCurrentTime()
            orderSqlite.updateTimeData(_id: model.id, _timeStamp: timeStamp, success: { [weak self] in
                guard let `self` = self else { return }
                let recordModel = self.orderSqlite.readData()
                self.setupType(.record(recordModel), section)
            })
        }
    }
}
