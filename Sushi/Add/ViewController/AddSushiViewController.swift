//
//  AddSushiViewController.swift
//  Sushi
//
//  Created by admin on 2023/4/21.
//

import UIKit
import RxCocoa
import RxSwift

class AddSushiViewController: BaseViewController {

    public let viewModel = AddSushiViewModel()

    @IBOutlet weak var menuPickerView: UIPickerView! {
        didSet {
            let strAry = viewModel.menuStrAry.map { $0.title }
            Observable.just(strAry)
                .bind(to: menuPickerView.rx.items(adapter: viewModel.stringPickerAdapter))
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
            mImageView.addGestureRecognizer(myImageTouch)
        }
    }

    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            _ = nameTextField.rx.textInput <-> viewModel.mName
            nameTextField.rx.controlEvent(.editingDidEndOnExit).subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.nameEngTextField.becomeFirstResponder()
            }).disposed(by: bag)
        }
    }

    @IBOutlet weak var nameEngTextField: UITextField! {
        didSet {
            _ = nameEngTextField.rx.textInput <-> viewModel.mNameEng
            nameEngTextField.rx.controlEvent(.editingDidEndOnExit).subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.priceTextField.becomeFirstResponder()
            }).disposed(by: bag)
        }
    }

    @IBOutlet weak var priceTextField: UITextField! {
        didSet {
            _ = priceTextField.rx.textInput <-> viewModel.mPrice
            priceTextField.rx.controlEvent(.editingDidEndOnExit).subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.priceTextField.resignFirstResponder()
            }).disposed(by: bag)
        }
    }

    @IBOutlet weak var sendBtn: NGSCustomizableButton! {
        didSet {
            Observable.combineLatest(viewModel.mName, viewModel.mNameEng, viewModel.mPrice, viewModel.mImage) { name, nameEng, price, img -> Bool in
                return !name.isEmpty && !nameEng.isEmpty && !price.isEmpty && Validation().isValidPrice(price) && img != UIImage(named: "noImg")!
            }.map { $0 }.bind(to: sendBtn.rx.isEnabled).disposed(by: bag)

            sendBtn.rx.tap.subscribe { [weak self] event in
                guard let `self` = self else { return }
                if self.viewModel.mType == .add {
                    self.addStorageImage()
                    self.addToast(txt: "新增中...", type: .sending)
                } else {
                    self.editRequset()
                    self.addToast(txt: "修改中...", type: .sending)
                }
            }.disposed(by: bag)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupEditUI()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    // MARK: - private
    private func setupEditUI() {
        guard let model = viewModel.editModel.data else { return }
        menuPickerView.isHidden = true
 
        viewModel.mName.accept(model.title)
        viewModel.mPrice.accept(model.price)
        viewModel.mNameEng.accept(model.eng)
        
        mImageView.loadImage(url: model.img, placeholder: UIImage(named: "noImg"), options: [.transition(.fade(0.5)), .loadDiskFileSynchronously]) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let value):
                self.viewModel.mTempEditImage.accept(value.image)
                self.viewModel.mImage.accept(value.image)
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }

    private func addStorageImage() {
        guard viewModel.mImage.value != viewModel.mTempEditImage.value else {
            if let img = viewModel.editModel.data?.img {
                self.addRequset(img)
            }
            return
        }
        let name = viewModel.mName.value
        let img = viewModel.mImage.value
        viewModel.addStorageImg(name, img).subscribe(onNext: { [weak self] (imgUrl) in
            guard let `self` = self, !imgUrl.isEmpty else { return }
            self.addRequset(imgUrl)
        }, onError: { [weak self] _ in
            guard let `self` = self else { return }
            self.addAndRemoveToast(txt: self.viewModel.mType == .add ? "新增失敗" : "修改失敗")
        }).disposed(by: bag)
    }

    private func addRequset(_ imgUrl: String) {
        let index = menuPickerView.selectedRow(inComponent: 0)

        let menu = viewModel.menuStrAry.count > index ? viewModel.menuStrAry[index].menu : self.viewModel.editModel.menu
        let sushiCount = viewModel.mType == .add ? viewModel.menuStrAry[index].sushiCount: viewModel.mType.index
        let model: SushiModel = viewModel.toSushiModel(imgUrl)
        viewModel.addData(.addSushi(menu, sushiCount.toStr), model.toAnyObject()).subscribe(onNext: { [weak self] (result) in
            guard let `self` = self else { return }
            self.addAndRemoveToast(txt: self.viewModel.mType == .add ? "新增成功" : "修改成功")
            self.viewModel.delegate?.requestSuc(menu)
        }, onError: { [weak self] _ in
            guard let `self` = self else { return }
            self.addAndRemoveToast(txt: self.viewModel.mType == .add ? "新增失敗" : "修改失敗")
        }).disposed(by: bag)
    }

    private func editRequset() {
        let title = unwrap(self.viewModel.editModel.data?.title, "")
        
        viewModel.delStorageImg(title).subscribe(onNext: { [weak self] (result) in
            guard let `self` = self else { return }
            self.addStorageImage()
        }).disposed(by: bag)
    }

    // MARK: - @objc
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
