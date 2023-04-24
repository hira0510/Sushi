//
//  AddSushiViewController.swift
//  Sushi
//
//  Created by admin on 2023/4/21.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import Kingfisher

class AddSushiViewController: BaseViewController {
    
    internal var menuStrAry: [MenuStrModel] = []
    private let viewModel = AddSushiViewModel()
    private let stringPickerAdapter = RxPickerViewStringAdapter<[String]>(
        components: [],
        numberOfComponents: { _,_,_  in 1 },
        numberOfRowsInComponent: { (_, _, items, _) -> Int in
            return items.count},
        titleForRow: { (_, _, items, row, _) -> String? in
            return items[row]}
    )
    
    @IBOutlet weak var menuPickerView: UIPickerView! {
        didSet {
            let strAry = menuStrAry.map { $0.title }
            Observable.just(strAry)
                .bind(to: menuPickerView.rx.items(adapter: stringPickerAdapter))
                .disposed(by: bag)
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
    
    @IBOutlet weak var mImageView: UIImageView! {
        didSet {
            viewModel.mImage.bind(to: mImageView.rx.image).disposed(by: bag)
            let myImageTouch = UITapGestureRecognizer(target: self, action: #selector(didClickCameraBtn))
            mImageView.isUserInteractionEnabled = true
            self.mImageView.addGestureRecognizer(myImageTouch)
        }
    }
    
    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            nameTextField.rx.text.orEmpty.bind(to: viewModel.mName).disposed(by: bag)
            nameTextField.rx.controlEvent(.editingDidEndOnExit).subscribe(onNext: {
                [weak self] (_) in
                guard let `self` = self else { return }
                self.nameTextField.resignFirstResponder()
            }).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var sendBtn: NGSCustomizableButton! {
        didSet {
            Observable.combineLatest(viewModel.mName, viewModel.mImage) { name, img -> Bool in
                return !name.isEmpty && img != UIImage()
            }.map { $0 }.bind(to: sendBtn.rx.isEnabled).disposed(by: bag)
            
            sendBtn.rx.tap.subscribe { [weak self] event in
                guard let `self` = self else { return }
                
                let toastView = ToastView(frame: self.view.frame, text: "新增中...")
                toastView.type = .sending
                self.view.addSubview(toastView)
                
                let index = menuPickerView.selectedRow(inComponent: 0)
                FireBaseManager().writeSushi(self.menuStrAry[index].menu, self.viewModel.mName.value, self.viewModel.mImage.value) { [weak self] model in
                    guard let `self` = self else { return }
                    self.removeToast()
                    let toastView = ToastView(frame: self.view.frame, text: "新增成功")
                    toastView.type = .sending
                    self.view.addSubview(toastView)
                }
            }.disposed(by: bag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func removeToast() {
        for view in self.view.subviews {
            if view.isKind(of: ToastView.self) {
                view.removeFromSuperview()
            }
        }
    }
    
    /// 點擊相機
    @objc private func didClickCameraBtn() {

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true

        let mView = CameraView(frame: self.view.frame)
        mView.clickCameraBtnHandler = { [weak self] in
            guard let `self` = self else { return }
            imagePicker.sourceType = .camera
            imagePicker.cameraDevice = .rear
            imagePicker.cameraCaptureMode = .photo
            imagePicker.cameraFlashMode = .off
            self.show(imagePicker, sender: self)
        }
        mView.clickAlbumBtnHandler = { [weak self] in
            guard let `self` = self else { return }
            imagePicker.sourceType = .photoLibrary
            if #available(iOS 13.0, *) {
                imagePicker.modalPresentationStyle = .automatic
            } else {
                imagePicker.modalPresentationStyle = .overFullScreen
            }
            self.show(imagePicker, sender: self)
        }

        self.view.addSubview(mView)
    }
}
// MARK: - UIImagePickerControllerDelegate - 相片編輯完成
extension AddSushiViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image = info[.editedImage] as! UIImage // 取得拍下的編輯後照片
        viewModel.mImage.accept(image)
        dismiss(animated: true, completion: nil)
    }
}
