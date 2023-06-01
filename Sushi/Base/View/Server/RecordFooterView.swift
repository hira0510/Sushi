//
//  RecordFooterView.swift
//  Sushi
//
//  Created by Hira on 2023/5/3.
//

import UIKit

protocol RecordFooterViewProtocol: AnyObject {
    func clickMinBtn(_ min: String, _ section: Int)
}

class RecordFooterView: UITableViewHeaderFooterView {
  
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var min3Btn: UIButton!
    @IBOutlet weak var min5Btn: UIButton!
    @IBOutlet weak var min10Btn: UIButton!
    @IBOutlet weak var min15Btn: UIButton!
    
    private var mSection: Int = 0
    private weak var delegate: RecordFooterViewProtocol?
     
    static var nib: UINib {
        return UINib(nibName: "RecordFooterView", bundle: Bundle(for: self))
    }
    
    public func configView(model: RecordModel, section: Int, delegate: RecordFooterViewProtocol) {
        self.delegate = delegate
        self.mSection = section
        self.textLabel?.isHidden = true
         
        timeLabel.text = "時間".twEng()
        min3Btn.setTitle("3" + "分鐘".twEng(), for: .normal)
        min5Btn.setTitle("5" + "分鐘".twEng(), for: .normal)
        min10Btn.setTitle("10" + "分鐘".twEng(), for: .normal)
        min15Btn.setTitle("15" + "分鐘".twEng(), for: .normal)
        
        let btnAry = [min3Btn, min5Btn, min10Btn, min15Btn]
        btnAry.forEach { btn in
            btn?.addTarget(self, action: #selector(clickTime), for: .touchUpInside)
            btn?.isEnabled = model.timestamp.isZero
        }
    }
    
    @objc private func clickTime(sender: NGSCustomizableButton) {
        guard let min = sender.titleLabel?.text?.replacingOccurrences(of: "分鐘".twEng(), with: "") else { return }
        delegate?.clickMinBtn(min, mSection)
    }
}
