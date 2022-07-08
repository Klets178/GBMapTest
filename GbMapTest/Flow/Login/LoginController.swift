//
//  LoginController.swift
//  GbMapTest
//
//  Created by KKK on 23.03.2022.
//

import UIKit
import RealmSwift
import RxSwift
import RxCocoa

class LoginController: UIViewController {

    var autoCompletionPossibilities = [ "mail.ru", "yandex.ru", "google.com" ]

    var notificationManager = NotificationManager.instance
    
    var loginViewModel: LoginViewModel?

    var onLogin: ((_ login: String, _ passord: String) -> Bool)?
    
    let userDefaults = UserDefaults.standard
    
//    var cancellable = Set<AnyCancellable>()
//    let passwordPublisher = PassthroughSubject<Bool, Never>()
//    let userNamePublisher = PassthroughSubject<Bool, Never>()

    let disposeBag = DisposeBag()
    var passwordPublisher = PublishSubject<Bool>()
    var userNamePublisher = PublishSubject<Bool>()
    
//    var isPasswordView = true
    let isPasswordView  = BehaviorRelay<Bool>(value: true)
    
    @IBOutlet weak var passwordViewButton: UIButton!
    @IBAction func didPasswordView(_ sender: UIButton) {
//        isPasswordView.toggle()
//        let smallSizeImage = UIImage.SymbolConfiguration(scale: .small)
//        if isPasswordView {
//            passwordField.isSecureTextEntry = true
//            sender.setImage(UIImage(systemName: "eye.slash.fill", withConfiguration: smallSizeImage), for: .normal)
//        } else {
//            passwordField.isSecureTextEntry = false
//            sender.setImage(UIImage(systemName: "eye.fill", withConfiguration: smallSizeImage), for: .normal)
//        }
    }
    
    
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var gotoTrackButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBAction func didUserNameField(_ sender: UITextField) {
//        userNamePublisher.send(sender.text)
    }
    
    @IBAction func didGotoTrack(_ sender: UIButton) {
        guard
            let login = userNameField.text,
            let password = passwordField.text,
            onLogin?(login, password) == true
                
        else {
            MesssageView.instance.alertMain(view: self, title: "Attention", message: "\nlogin, password не верны!" )
            return
        }
        
        guard
            Reachability.instance.isConnectedToNetwork()
        else {
            MesssageView.instance.alertMain(view: self, title: "Attention", message: "\nОшибка подключения к интернету!" )
            return
        }
        
        clearFields()
        loginViewModel?.gotoTrackController()
    }
    
    @IBAction func didRegistrationTouch(_ sender: UIButton) {
        loginViewModel?.gotoRegistrationController()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        print("􀘰􀘰 realm = \n", Realm.Configuration.defaultConfiguration.fileURL!, "\n 􀘰􀘰")
        
        // Жест нажатия
        let hideKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        // Присваиваем его UIScrollVIew
        scrollView?.addGestureRecognizer(hideKeyboardGesture)
        
        checkLogin()
        
//        userNameField.delegate = self
        
//        userNameField.textPublisher
////            .map { $0.last }
////            .compactMap{ $0.flatMap(String.init) }
//            .map { $0 }
//            .sink(receiveValue: { val in
//                print(val)
//                self.autoComplete(textField: self.userNameField, repString: val, arrayComplete: self.autoCompletionPossibilities)
//            })
//            .store(in: &cancellable)
                
        passwordViewButtonTap()
        passwordViewSecureTextEntry()
        
        checkNotificationCenter()

    }
    
    
    func checkNotificationCenter() {
        notificationManager.checkNotificationCenter( completion: { [self] res in
            var countRun: Int = userDefaults.object(forKey: "countRun") as? Int ?? 0
            countRun = countRun + 1
            print("countRun",countRun)
            if (!res && (countRun > 3)) {
                MesssageView.instance.goSettings(view: self)
            }
            if countRun > 3 { countRun = 0 } //  что-бы не зашкалило если разрешение есть
            userDefaults.set((countRun), forKey: "countRun")
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        gotoTrackButton.isEnabled = false
        
        // Подписываемся на два уведомления: одно приходит при появлении клавиатуры
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown), name: UIResponder.keyboardWillShowNotification, object: nil)
        // Второе — когда она пропадает
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    
//    func checkInputLogin(login: String, password: String) -> Bool {
//        enum Constants {
//            static let login = "admin"
//            static let password = "123456"
//        }
//
//       return login == Constants.login && password == Constants.password
//
//    }
    
    func clearFields() {
        userNameField.text = String()
        passwordField.text = String()
        
    }

}

extension LoginController {
    
    // Когда клавиатура появляется
    @objc func keyboardWasShown(notification: Notification) {
        // Получаем размер клавиатуры
        let info = notification.userInfo! as NSDictionary
        let kbSize = (info.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue).cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: kbSize.height, right: 0.0)

        // Добавляем отступ внизу UIScrollView, равный размеру клавиатуры
        self.scrollView?.contentInset = contentInsets
        scrollView?.scrollIndicatorInsets = contentInsets
    }

     //Когда клавиатура исчезает
    @objc private func keyboardWillBeHidden(notification: Notification) {
         // Устанавливаем отступ внизу UIScrollView, равный 0
        let contentInsets = UIEdgeInsets.zero
        scrollView?.contentInset = contentInsets
     }
    
    @objc private func hideKeyboard() {
        self.scrollView?.endEditing(true)
    }
    
}

extension LoginController {

    func checkLogin() {
//        userNameField.textPublisher
//            .map { $0.count > 3 }
//            .subscribe(userNamePublisher)
//            .store(in: &cancellable)
//
//        passwordField.textPublisher
//            .map { $0.count > 3 }
//            .subscribe(passwordPublisher)
//            .store(in: &cancellable)
//
//        Publishers.CombineLatest(userNamePublisher, passwordPublisher)
//            .map { $0 && $1 }
//            .assign(to: \.isEnabled, on: gotoTrackButton)
//            .store(in: &cancellable)

        
        let userNamePublisher = userNameField.rx.text
            .orEmpty
            .map {$0.count > 0}

        let passwordPublisher = passwordField.rx.text
            .orEmpty
            .map {$0.count > 0}
        
        Observable
            .combineLatest(userNamePublisher, passwordPublisher) { $0 && $1 }
            .bind { [weak gotoTrackButton] (bool) in
                gotoTrackButton?.isEnabled = bool
            }
            .disposed(by: disposeBag)

    }

}

extension LoginController {
    func passwordViewButtonTap() {
        passwordViewButton.rx.tap
            .map{self.isPasswordView.value}
            .bind(onNext: { [weak isPasswordView] (bool) in
                isPasswordView?.accept(!bool)
            } )
            .disposed(by: disposeBag)
    }
    
    
    func passwordViewSecureTextEntry() {
        enum nameImages: String {
            case open = "eye.fill"
            case close = "eye.slash.fill"
        }
        
        isPasswordView
            .asObservable()
            .bind(onNext: { [weak passwordField] (bool) in
                passwordField?.isSecureTextEntry = bool
                
                let smallSizeImage = UIImage.SymbolConfiguration(scale: .small)
                var nameImage = nameImages.open
                if bool { nameImage = nameImages.close }
                self.passwordViewButton.setImage(UIImage(systemName: nameImage.rawValue, withConfiguration: smallSizeImage), for: .normal)
            } )
            .disposed(by: disposeBag)
    }
    
    
    
}

