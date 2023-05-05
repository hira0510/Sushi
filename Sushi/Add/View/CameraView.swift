//
//  CameraView.swift
//  Sushi
//
//  Created by admin on 2023/4/21.
//
 
import UIKit

class CameraView: UIView, NibOwnerLoadable {

    @IBOutlet var mView: UIView!
    @IBOutlet weak var cameraButton: NGSCustomizableButton!
    @IBOutlet weak var albumButton: NGSCustomizableButton!
    @IBOutlet weak var cancelButton: NGSCustomizableButton!
    
    internal var clickCameraBtnHandler: (() -> Void)? = { }
    internal var clickAlbumBtnHandler: (() -> Void)? = { }

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
        
        cameraButton.addTarget(self, action: #selector(didClickCameraBtn), for: .touchUpInside)
        albumButton.addTarget(self, action: #selector(didClickAlbumBtn), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(didClickCancelBtn), for: .touchUpInside)
    }
    
    @objc private func didClickCameraBtn() {
        didClickCancelBtn()
        clickCameraBtnHandler?()
    }
    
    @objc private func didClickAlbumBtn() {
        didClickCancelBtn()
        clickAlbumBtnHandler?()
    }
    
    @objc private func didClickCancelBtn() {
        removeFromSuperview()
    }

}
