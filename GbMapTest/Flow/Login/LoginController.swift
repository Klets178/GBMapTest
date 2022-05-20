//
//  LoginController.swift
//  GbMapTest
//
//  Created by KKK on 23.03.2022.
//

import UIKit
import Combine
import RealmSwift
import SwiftUI

class LoginController: UIViewController {

    var autoCompletionPossibilities = [ "mail.ru", "yandex.ru", "google.com" ]

    
    var loginViewModel: LoginViewModel?

    var onLogin: ((_ login: String, _ passord: String) -> Bool)?
    
    var cancellable = Set<AnyCancellable>()
    let passwordPublisher = PassthroughSubject<Bool, Never>()
    let userNamePublisher = PassthroughSubject<Bool, Never>()
    
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
        userNameField.textPublisher
//            .map { $0.last }
//            .compactMap{ $0.flatMap(String.init) }
            .map { $0 }
            .sink(receiveValue: { val in
                print(val)
                self.autoComplete(textField: self.userNameField, repString: val, arrayComplete: self.autoCompletionPossibilities)
            })
            .store(in: &cancellable)
                     
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
        userNameField.textPublisher
            .map { $0.count > 3 }
            .subscribe(userNamePublisher)
            .store(in: &cancellable)
         
        passwordField.textPublisher
            .map { $0.count > 3 }
            .subscribe(passwordPublisher)
            .store(in: &cancellable)
         
        Publishers.CombineLatest(userNamePublisher, passwordPublisher)
            .map { $0 && $1 }
            .assign(to: \.isEnabled, on: gotoTrackButton)
            .store(in: &cancellable)
    }
     
}

extension UITextField {

    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(
            for: UITextField.textDidChangeNotification,
            object: self
        )
        .compactMap { ($0.object as? UITextField)?.text }
        .eraseToAnyPublisher()
    }
    

}

extension LoginController {
    
    func autoComplete(textField: UITextField, repString: String, arrayComplete: [String]) {
        guard let text = textField.text else { return }
            let matches = arrayComplete.filter {
                $0.hasPrefix(repString)
            }

            if !(matches.isEmpty) {
                textField.text = matches.first!
                if let pos = textField.position(from: textField.beginningOfDocument, offset: text.count) {
                    textField.selectedTextRange = textField.textRange(from: pos, to: textField.endOfDocument)
                }
            }

    }
    
}
    
    

    

