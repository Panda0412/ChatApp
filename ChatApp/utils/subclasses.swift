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

class AsyncOperation: Operation {
    public enum State: String {
        case ready
        case executing
        case finished

        var keyPath: String {
            return "is" + rawValue.capitalized
        }
    }

    private var stateLock = NSLock()
    private var _state: State = .ready
    private var state: State {
        get {
            return _state
        }
        set {
            stateLock.lock()
            let oldValue = _state
            willChangeValue(forKey: oldValue.keyPath)
            willChangeValue(forKey: newValue.keyPath)
            _state = newValue
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: newValue.keyPath)
            stateLock.unlock()
        }
    }

    open override var isReady: Bool {
        return super.isReady && state == .ready
    }

    open override var isExecuting: Bool {
        return state == .executing
    }

    open override var isFinished: Bool {
        return state == .finished
    }

    open override var isAsynchronous: Bool {
        return true
    }

    open override func start() {
        guard !isCancelled else {
            state = .finished
            return
        }

        state = .executing
        main()
    }

    public func finish() {
        guard state != .finished else { return }

        state = .finished
    }
}
