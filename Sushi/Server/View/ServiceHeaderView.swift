//
//  ServiceHeaderView.swift
//  Sushi
//
//  Created by Hira on 2023/5/3.
//

import UIKit

protocol ServiceHeaderProtocol: AnyObject {
    func clickCompleteBtn(_ section: Int)
}

class ServiceHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var completeBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var mSection: Int = 0 
    private weak var delegate: ServiceHeaderProtocol?
     
    static var nib: UINib {
        return UINib(nibName: "ServiceHeaderView", bundle: Bundle(for: self))
    }
    
    public func configView(model: RecordModel, section: Int, text: String, delegate: ServiceHeaderProtocol, type: ServerViewType) {
        self.delegate = delegate
        self.mSection = section
        
        self.textLabel?.isHidden = true
        self.titleLabel.text = model.tableNumber + text
        self.titleLabel.font = UIFont(name: "PingFangTC-Regular", size: 24.0)!
        self.titleLabel.textColor = UIColor.white
        
        self.completeBtn.addTarget(self, action: #selector(clickComplete), for: .touchUpInside)
        self.completeBtn.isEnabled = type == .checkout() || !model.timestamp.isZero
        self.completeBtn.isSelected = model.isComplete
        self.isUserInteractionEnabled = !model.isComplete
        self.completeBtn.setBackgroundColor(UIColor(named: "main_btn_isEnable"), for: .normal)
        self.completeBtn.setBackgroundColor(UIColor(named: "main_btn_isSelect"), for: .selected)
        self.completeBtn.setBackgroundColor(UIColor(named: "main_btn_isDisable"), for: .disabled)
    }
    
    @objc private func clickComplete() {
        delegate?.clickCompleteBtn(mSection)
    }
}
