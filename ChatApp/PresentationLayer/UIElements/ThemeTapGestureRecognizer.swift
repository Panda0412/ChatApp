//
//  ThemeTapGestureRecognizer.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 20.04.2023.
//

import UIKit

public class ThemeTapGestureRecognizer: UITapGestureRecognizer {
    var theme: UIUserInterfaceStyle = .unspecified
    
    init(target: Any, action: Selector, theme: UIUserInterfaceStyle) {
        super.init(target: target, action: action)
        self.theme = theme
    }
}
