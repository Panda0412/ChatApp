//
//  CombineServiceError.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 20.04.2023.
//

import Foundation

public enum CombineServiceError: Error {
    case writingError
    case readingError
    case cancel
}
