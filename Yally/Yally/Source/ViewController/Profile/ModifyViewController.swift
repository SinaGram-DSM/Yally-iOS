//
//  ModifyViewController.swift
//  Yally
//
//  Created by 문지수 on 2020/10/28.
//

import UIKit

import RxSwift
import RxCocoa

class ModifyViewController: UIViewController {

    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nickNameTxtField: UITextField!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var logOutBtn: UIButton!

    let picker = UIImagePickerController()

    private let disposeBag = DisposeBag()
    private let viewModel = ModifyProfileViewModel()
    private let loadData = BehaviorSubject<Void>(value: ())
    private let image = BehaviorRelay<String>(value: "")

    lazy var imagePicker: UIImagePickerController = {
        let picker: UIImagePickerController = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        return picker
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        bindAction()
        setUI()
        bindViewModel()
    }

    func bindViewModel() {

        let api = ProfileAPI()
        let input = ModifyProfileViewModel.input(nickName: nickNameTxtField.rx.text.orEmpty.asDriver(onErrorJustReturn: "" ), userImage: image.asDriver(), doneTap: saveBtn.rx.tap.asSignal())

        let output = viewModel.transform(input)

        output.result.emit(onCompleted: { self.navigationController?.popViewController(animated: true)}
        ).disposed(by: rx.disposeBag)
    }

    func setUI() {
        profileImage.layer.cornerRadius = profileImage.frame.width/2
        profileImage.clipsToBounds = true

        imageButton.layer.cornerRadius = imageButton.frame.width/2
        imageButton.layer.backgroundColor = UIColor.white.cgColor

        nickNameTxtField.underLine()
    }

    func bindAction() {
        imageButton.rx.tap.subscribe(onNext: { _ in
            self.imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.imagePicker.allowsEditing = false
            self.present(self.imagePicker, animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)

        saveBtn.rx.tap.subscribe(onNext: { _ in
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "profile") as! ProfileViewController
            let navigation = UINavigationController(rootViewController: vc)
        }).disposed(by: disposeBag)

        logOutBtn.rx.tap.subscribe(onNext: { _ in
            let alert = UIAlertController(title: "로그아웃", message: "로그아웃 하시겠습니까?", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "네", style: .default) { _ in
                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
            }
            let noAction = UIAlertAction(title: "아니요", style: .default)
            alert.addAction(okAction)
            alert.addAction(noAction)

            self.present(alert, animated: false, completion: nil)
        }).disposed(by: disposeBag)

    }

}

extension UIViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

}

extension UITextField {
    func underLine() {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.gray.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}
