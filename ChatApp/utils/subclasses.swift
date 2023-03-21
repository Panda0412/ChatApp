//
//  subclasses.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 15.03.2023.
//

import UIKit

public class ThemeButton: UIButton {
    var theme: UIUserInterfaceStyle = .unspecified
    
    init(theme: UIUserInterfaceStyle) {
        super.init(frame: .zero)
        self.theme = theme
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class ThemeTapGestureRecognizer: UITapGestureRecognizer {
    var theme: UIUserInterfaceStyle = .unspecified
    
    init(target: Any, action: Selector, theme: UIUserInterfaceStyle) {
        super.init(target: target, action: action)
        self.theme = theme
    }
}
