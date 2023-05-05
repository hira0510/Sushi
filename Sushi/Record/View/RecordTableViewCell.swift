//
//  RecordTableViewCell.swift
//  Sushi
//
//  Created by Hira on 2023/4/27.
//

import UIKit

enum RecordType {
    case suc
    case wait(_ min: Int = 0)
    case waitForAdmin
    case adminPreparing(_ min: Int = 0)
    
    var stringValue: String {
        switch self {
        case .suc: return "已送達".twEng()
        case .wait(let min): return min.toStr + " 分鐘".twEng()
        case .waitForAdmin: return "等待中".twEng()
        case .adminPreparing(let min): return min.toStr + "分鐘".twEng()
        }
    }
    
    private var index: Int {
        switch self {
        case .suc: return 0
        case .wait: return 1
        case .waitForAdmin: return 2
        case .adminPreparing: return 3
        }
    }
     
    static func == (lhs: RecordType, rhs: RecordType) -> Bool {
        return lhs.index == rhs.index
    }
    
    static func getType(_ timestamp: TimeInterval) -> RecordType {
        if timestamp > GlobalUtil.getCurrentTime() {
            let waitMin = ((timestamp - GlobalUtil.getCurrentTime()) / 60) + 1
            return SuShiSingleton.share().getIsAdmin() ? .adminPreparing(waitMin.toInt): .wait(waitMin.toInt)
        } else if timestamp <= 0 {
            return .waitForAdmin
        } else {
            return .suc
        }
    }
}

class RecordTableViewCell: UITableViewCell {
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    static var nib: UINib {
        return UINib(nibName: "RecordTableViewCell", bundle: Bundle(for: self))
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    /// Client 點餐紀錄
    func cellConfig(_ model: SushiRecordModel) {
        priceLabel.text = SuShiSingleton.share().getIsEng() ? "$" + model.money : model.money + "元"
        titleLabel.text = SuShiSingleton.share().getIsEng() ? model.titleEng: model.title
        let type: RecordType = RecordType.getType(model.arrivedTime)
        statusLabel.text = type.stringValue
        statusLabel.textColor = type == .wait() ? .red: .black
        statusLabel.isHidden = false
        priceLabel.isHidden = false
    }
    
    /// Server點餐紀錄
    func adminRecordCellConfig(_ model: RecordItemModel, type: RecordType) { 
        titleLabel.text = model.name
        statusLabel.textColor = type == .adminPreparing() ? .red: .black
        statusLabel.text = type.stringValue
        statusLabel.isHidden = false
        priceLabel.isHidden = true
    }
    
    /// Server結帳
    func adminCheckoutCellConfig(_ model: RecordItemModel) {
        priceLabel.text = model.price + "元"
        titleLabel.text = model.name
        statusLabel.textColor = .black
        statusLabel.isHidden = true
        priceLabel.isHidden = false
    }
    
    /// Server服務
    func adminServiceCellConfig(_ model: (String, TimeInterval)) {
        titleLabel.text = "\(model.0)桌呼喚服務"
        statusLabel.text = GlobalUtil.specificTimeIntervalStr(timeInterval: model.1, format: "HH:mm:ss")
        statusLabel.textColor = .black
        statusLabel.isHidden = false
        priceLabel.isHidden = true
    }
}
