//
//  MesssageView.swift
//  GbMapTest
//
//  Created by KKK on 23.03.2022.
//

import UIKit

class MesssageView: NSObject {
    static let instance = MesssageView()

    func alertMain(view: UIViewController, title: String, message: String = "Не известная ошибка!") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(okButton)

        view.present(alert, animated: true)
     }
    
}
