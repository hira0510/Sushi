//
//  TYCycleCell.swift
//  Sushi
//
//  Created by Hira on 2023/5/12.
//

import UIKit

class TYCycleCell: UICollectionViewCell {
 
    @IBOutlet weak var mPlayerView: PlayerView!
    @IBOutlet weak var mImageView: UIImageView!

    private var urlStr: String = ""
    static var nib: UINib {
        return UINib(nibName: "TYCycleCell", bundle: Bundle(for: self))
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configCell(_ urlStr: String) {
        self.urlStr = urlStr
        mPlayerView.isHidden = urlStr.isImageType()
        mImageView.isHidden = !urlStr.isImageType()
         
        DispatchQueue.main.async {
            if urlStr.isImageType() { 
                self.mImageView.loadImage(url: urlStr, options: [.transition(.fade(0.5)), .loadDiskFileSynchronously])
            } else {
                self.mPlayerView.setupPlayer(urlStr, type: .cycleCell)
            }
        }
    }
    
    func whenScrollStopVideo() {
        if !urlStr.isImageType() {
            mPlayerView.stop()
        }
    }
    
    func whenScrollPlayVideo() {
        if !urlStr.isImageType() {
            mPlayerView.play()
        }
    }
}
