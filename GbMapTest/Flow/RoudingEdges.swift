//
//  RoudingEdges.swift
//
//  Created by KKK on 22.04.2021.
//

import UIKit

 class RoudingEdgesView: UIView {
    @IBInspectable var borderColor: UIColor = .gray
    @IBInspectable var borderWidth: CGFloat = 1.5
    
    override func awakeFromNib() {
        self.layer.cornerRadius = self.frame.height / 3
        self.layer.masksToBounds = true
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
    }
    
}

class RoudingEdgesButton: UIButton {
    @IBInspectable var borderColor: UIColor = .white
    @IBInspectable var borderWidth: CGFloat = 1.5
   
   override func awakeFromNib() {
       self.layer.cornerRadius = self.frame.height / 3
       self.layer.masksToBounds = true
       self.layer.borderWidth = borderWidth
       self.layer.borderColor = borderColor.cgColor
    }
   
}


class RoudingEdgesLabel: UILabel {
    @IBInspectable var borderColor: UIColor = .white
    @IBInspectable var borderWidth: CGFloat = 1.5
   
   override func awakeFromNib() {
       self.layer.cornerRadius = self.frame.height / 3
       self.layer.masksToBounds = true
       self.layer.borderWidth = borderWidth
       self.layer.borderColor = borderColor.cgColor
    }
   
}

class RoudingEdgesImage: UIImageView {
   @IBInspectable var borderColor: UIColor = .gray
   @IBInspectable var borderWidth: CGFloat = 1.5
   
   override func awakeFromNib() {
       self.layer.cornerRadius = self.frame.height / 2
       self.layer.masksToBounds = true
       self.layer.borderWidth = borderWidth
       self.layer.borderColor = borderColor.cgColor
   }
}
