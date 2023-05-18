//
//  UIColor+HexInit.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 27.04.2023.
//

import UIKit

extension UIColor {
    convenience init(hexString: String) {
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hex = String(hexString[start...])
            
            let scanner = Scanner(string: hex)
            var color: UInt64 = 0
            let mask = 0x000000FF
            
            scanner.scanHexInt64(&color)
            
            let red = CGFloat(Int(color >> 16) & mask) / 255.0
            let green = CGFloat(Int(color >> 8) & mask) / 255.0
            let blue = CGFloat(Int(color) & mask) / 255.0
                        
            self.init(red: red, green: green, blue: blue, alpha: 1)
            return
        }
        
        self.init(red: 0, green: 0, blue: 0, alpha: 1)
    }
}
