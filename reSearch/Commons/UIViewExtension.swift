//
//  UIViewExtension.swift
//  reSearch
//
//  Created by Jennifer Ruiz on 30/06/21.
//

import UIKit

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get { return cornerRadius }
        set {
            self.layer.cornerRadius = newValue
        }
    }
}
