//
//  RecordViewController.swift
//  Sushi
//
//  Created by Hira on 2023/4/27.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

class RecordViewController: BaseViewController {
    
    var mModel: [SushiModel] = []

    @IBOutlet weak var previousBtn: UIButton! {
        didSet {
            previousBtn.rx.tap.subscribe { [weak self] event in
                guard let `self` = self else { return }
                self.previousBack()
            }.disposed(by: bag)
        }
    }
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var mTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPriceLabel()
        setupTableView()
    }
    
    func setupPriceLabel() {
        let price = mModel.map { $0.money.toInt }
        let resultPrice = price.reduce(0, { $0 + $1 }) 
        priceLabel.text = SuShiSingleton.share().getIsEng() ? "$\(resultPrice)": "\(resultPrice)元"
    }
    
    func setupTableView() {
        mTableView.delegate = self
        mTableView.dataSource = self
        mTableView.register(RecordTableViewCell.nib, forCellReuseIdentifier: "RecordTableViewCell")
        mTableView.estimatedSectionFooterHeight = 0
        mTableView.estimatedSectionHeaderHeight = 0
        mTableView.allowsMultipleSelectionDuringEditing = false
        mTableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        mTableView.rowHeight = GlobalUtil.calculateWidthHorizontalScaleWithSize(width: 35)
        mTableView.separatorColor = .black
        mTableView.reloadData()
    }
}

extension RecordViewController: UITableViewDelegate, UITableViewDataSource {
     
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordTableViewCell", for: indexPath) as! RecordTableViewCell
        cell.cellConfig(mModel[indexPath.item], .wait(5))
        return cell
    }
}
