//
//  UIRESPONDER.swift
//  Tour Manager
//
//  Created by SHREDDING on 12.12.2023.
//

import Foundation
import UIKit

extension UIResponder {
    private static weak var _currentFirstResponder: UIResponder? = nil

    static var currentFirstResponder: UIResponder? {
        _currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(findFirstResponder), to: nil, from: nil, for: nil)
        return _currentFirstResponder
    }

    @objc private func findFirstResponder(_ sender: Any) {
        UIResponder._currentFirstResponder = self
    }
}
