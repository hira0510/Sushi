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
    
    static func getType(_ timestamp: TimeInterval, _ isComplete: Bool = false) -> RecordType {
        if timestamp <= 0 {
            return .waitForAdmin
        } else if timestamp > GlobalUtil.getCurrentTime() && !isComplete {
            let waitMin = ((timestamp - GlobalUtil.getCurrentTime()) / 60) + 1
            return SuShiSingleton.share().getIsAdmin() ? .adminPreparing(waitMin.toInt): .wait(waitMin.toInt)
        } else {
            return .suc
        }
    }
}

class RecordTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    static var nib: UINib {
        return UINib(nibName: "RecordTableViewCell", bundle: Bundle(for: self))
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func isSelectChangeBg(_ isSelect: Bool, _ isComplete: Bool) {
        self.bgView.backgroundColor = isComplete ? #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1): isSelect ? #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1): .white
        self.priceLabel.backgroundColor = isComplete ? #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1): isSelect ? #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1): .white
        self.titleLabel.backgroundColor = isComplete ? #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1): isSelect ? #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1): .white
        self.statusLabel.backgroundColor = isComplete ? #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1): isSelect ? #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1): .white
    }
    
    /// Client 點餐紀錄
    func cellConfig(_ model: SushiRecordModel) {
        priceLabel.text = SuShiSingleton.share().getIsEng() ? "$" + model.money : model.money + "元"
        titleLabel.text = SuShiSingleton.share().getIsEng() ? model.titleEng: model.title
        let type: RecordType = RecordType.getType(model.arrivedTime, false)
        statusLabel.text = type.stringValue
        statusLabel.textColor = type == .wait() ? .red: .black
        statusLabel.isHidden = false
        priceLabel.isHidden = false
        isSelectChangeBg(false, false)
    }
    
    /// Server點餐紀錄
    func adminRecordCellConfig(_ model: RecordItemModel, type: RecordType, isSelect: Bool) {
        titleLabel.text = model.name
        statusLabel.textColor = type == .adminPreparing() ? .red: .black
        statusLabel.text = type.stringValue
        statusLabel.isHidden = false
        priceLabel.isHidden = true
        isSelectChangeBg(isSelect, model.isComplete)
    }
    
    /// Server結帳
    func adminCheckoutCellConfig(_ model: RecordItemModel) {
        priceLabel.text = model.price + "元"
        titleLabel.text = model.name
        statusLabel.textColor = .black
        statusLabel.isHidden = true
        priceLabel.isHidden = false
        isSelectChangeBg(false, false)
    }
    
    /// Server服務
    func adminServiceCellConfig(_ model: (String, TimeInterval)) {
        titleLabel.text = "\(model.0)桌呼喚服務"
        statusLabel.text = GlobalUtil.specificTimeIntervalStr(timeInterval: model.1, format: "HH:mm:ss")
        statusLabel.textColor = .black
        statusLabel.isHidden = false
        priceLabel.isHidden = true
        isSelectChangeBg(false, false)
    }
}
