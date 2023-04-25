//
//  ThemeButton.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 20.04.2023.
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
