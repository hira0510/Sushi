//
//  PlayerView.swift
//  Sushi
//
//  Created by Hira on 2023/5/12.
//

import UIKit
import AVFoundation

class PlayerView: BaseView {
    
    enum FromType {
        case playerVc
        case cycleCell
    }
    
    @IBOutlet weak var youtubePlayerView: YouTubePlayerView!
    @IBOutlet weak var mPlayerView: UIView!

    public var urlStr: String = ""
    private var isFirstInit: Bool = false
    private var player: AVPlayer?
    private var mType: FromType?
    public lazy var playerLayer: AVPlayerLayer = {
        let remoteURL = URL(string: urlStr)
        self.player = AVPlayer(url: remoteURL!)
        let layer = AVPlayerLayer(player: self.player)
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        loadNibContent()
    } 

    public func setupPlayer(_ urlStr: String, type: FromType) {
        self.mType = type
        self.urlStr = urlStr
        guard let videoUrl = URL(string: self.urlStr) else { return }
        if self.urlStr.contains("youtube") {
            youtubePlayerView.isHidden = false
            youtubePlayerView.isUserInteractionEnabled = false
            mPlayerView.isHidden = true
            if !youtubePlayerView.ready {
                youtubePlayerView.loadVideoURL(videoUrl)
                isFirstInit = true
            }
            youtubePlayerView.delegate = self
        } else {
            youtubePlayerView.isHidden = true
            mPlayerView.isHidden = false
            if mPlayerView.layer.sublayers == nil {
                playerLayer.frame = mPlayerView.bounds
                mPlayerView.layer.addSublayer(self.playerLayer)
            }
        }
    }
    
    public func stop() {
        if self.urlStr.contains("youtube") {
            youtubePlayerView.stop()
        } else {
            player?.pause()
        }
    }
    
    public func play() {
        if self.urlStr.contains("youtube") {
            youtubePlayerView.play()
        } else {
            player?.play()
        }
        if mType == .cycleCell {
            mute()
        }
    }
    
    private func mute() {
        if self.urlStr.contains("youtube") {
            youtubePlayerView.mute()
        } else {
            player?.isMuted = true
        }
    }
}
extension PlayerView: YouTubePlayerDelegate {
    func playerReady(_ videoPlayer: YouTubePlayerView) {
        if isFirstInit {
            play()
            isFirstInit = false
        }
    }
}
