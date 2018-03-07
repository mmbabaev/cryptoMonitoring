//
//  UINavigationBar+TextColor.swift
//  CryptoMonitoring
//
//  Created by Mihail Babaev on 07.03.2018.
//  Copyright © 2018 . All rights reserved.
//

import UIKit

extension UINavigationBar {
    func setTextColor(_ color: UIColor) {
        var attributes = self.titleTextAttributes ?? [:]
        attributes[NSAttributedStringKey.foregroundColor] = color
        self.titleTextAttributes = attributes
    }
}
