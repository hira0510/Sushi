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
        
        let btnAry = [min3Btn, min5Btn, min10Btn, min15Btn]
        btnAry.forEach { btn in
            btn?.addTarget(self, action: #selector(clickTime), for: .touchUpInside)
            btn?.isEnabled = model.timestamp.isZero
            btn?.setBackgroundColor(UIColor(named: "main_btn_isEnable"), for: .normal)
            btn?.setBackgroundColor(UIColor(named: "main_btn_isDisable"), for: .disabled)
        }
    }
    
    @objc private func clickTime(sender: NGSCustomizableButton) {
        guard let min = sender.titleLabel?.text?.replacingOccurrences(of: "分鐘", with: "") else { return }
        delegate?.clickMinBtn(min, mSection)
    }
}
