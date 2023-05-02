//
//  RecordTableViewCell.swift
//  Sushi
//
//  Created by Hira on 2023/4/27.
//

import UIKit

enum RecordType {
    case suc
    case wait(_ min: Int)
    
    var stringValue: String {
        switch self {
        case .suc: return "已送達".twEng()
        case .wait(let min): return min.toStr + " 分鐘".twEng()
        }
    }
     
    static func == (lhs: RecordType, rhs: RecordType) -> Bool {
        return lhs.stringValue == rhs.stringValue
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
    
    func cellConfig(_ model: SushiModel, _ type: RecordType) {
        priceLabel.text = SuShiSingleton.share().getIsEng() ? "$" + model.money : model.money + "元"
        titleLabel.text = SuShiSingleton.share().getIsEng() ? model.titleEng: model.title
        statusLabel.text = type.stringValue
        statusLabel.textColor = type == .suc ? .black: .red
    }
}
