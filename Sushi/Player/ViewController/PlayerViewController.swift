//
//  PlayerViewController.swift
//  Sushi
//
//  Created by Hira on 2023/5/12.
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation

class PlayerViewController: BaseViewController {

    @IBOutlet weak var previousBtn: UIButton! {
        didSet {
            previousBtn.rx.tap.subscribe { [weak self] event in
                guard let `self` = self else { return }
                self.previousBack()
            }.disposed(by: bag)
        }
    }
    @IBOutlet weak var playerView: PlayerView!

    public var urlStr: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        playerView.setupPlayer(urlStr, type: .playerVc)
        playerView.play()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerView.playerLayer.frame = playerView.bounds
    }
 
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let width = playerView.bounds.height
        let height = playerView.bounds.width
        UIView.animate(withDuration: 0.3) {
            self.playerView.mPlayerView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        }
    }
}
