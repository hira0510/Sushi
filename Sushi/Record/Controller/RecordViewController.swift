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
    
    public let viewModel = RecordViewModel()
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var mTableView: UITableView! {
        didSet {
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
    @IBOutlet weak var previousBtn: UIButton! {
        didSet {
            previousBtn.rx.tap.subscribe { [weak self] event in
                guard let `self` = self else { return }
                self.previousBack()
            }.disposed(by: bag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPriceLabel()
        addOrderTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.viewModel.orderTimer?.invalidate()
        self.viewModel.orderTimer = nil
    }
    
    private func setupPriceLabel() {
        let price = viewModel.mModel.map { $0.money.toInt }
        let resultPrice = price.reduce(0, { $0 + $1 }) 
        priceLabel.text = SuShiSingleton.share().getIsEng() ? "$\(resultPrice)": "\(resultPrice)元"
    }
     
    private func addOrderTimer() {
        viewModel.orderTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(timerReciprocal), userInfo: nil, repeats: true)
    }
    
    @objc private func timerReciprocal() {
        mTableView.reloadData()
    }
}

extension RecordViewController: UITableViewDelegate, UITableViewDataSource {
     
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.mModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordTableViewCell", for: indexPath) as! RecordTableViewCell
        cell.cellConfig(viewModel.mModel[indexPath.item])
        return cell
    }
}

extension RecordViewController: MenuVcProtocol {
    func setupRecordVcData(_ data: [SushiRecordModel]) {
        viewModel.mModel = data
        mTableView.reloadData()
    }
}
