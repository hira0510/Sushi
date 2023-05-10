//
//  OrderListView.swift
//  Sushi
//
//  Created by Hira on 2023/4/26.
//

import UIKit

protocol ToggleLayoutViewDelegate: AnyObject {
    func onToggleLayoutClick(layoutType: ToggleLayoutView.LayoutType)
}

@IBDesignable
class ToggleLayoutView: BaseView {
    ///layout類型
    enum LayoutType {
        case grid ///網格
        case linear ///線性
    }
    
    @IBOutlet weak var toggleGridButton: UIButton!
    @IBOutlet weak var toggleLinearButton: UIButton!
    @IBOutlet weak var borderLine: UIView!

    var layoutType: LayoutType = .grid {
        didSet {
            setToggleButtons()
        }
    }
    weak var delegate: ToggleLayoutViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        loadNibContent()
        toggleLinearButton.addTarget(self, action: #selector(toggleLayoutType), for: .touchUpInside)
        toggleGridButton.addTarget(self, action: #selector(toggleLayoutType), for: .touchUpInside)
        setToggleButtons()
    }
    
    private func setToggleButtons() {
        switch layoutType {
        case .grid:
            toggleGridButton.setBackgroundImage(UIImage(named: "menu_image_grid_on"), for: .normal)
            toggleLinearButton.setBackgroundImage(UIImage(named: "menu_image_linear_off"), for: .normal)
        case .linear:
            toggleGridButton.setBackgroundImage(UIImage(named: "menu_image_grid_off"), for: .normal)
            toggleLinearButton.setBackgroundImage(UIImage(named: "menu_image_linear_on"), for: .normal)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        borderLine.cornerRadius = self.frame.height / 2
    }
    
    @objc func toggleLayoutType() {
        switch layoutType {
        case .grid: layoutType = .linear
        case .linear: layoutType = .grid
        }
        setToggleButtons()
        delegate?.onToggleLayoutClick(layoutType: layoutType)
    }
}
