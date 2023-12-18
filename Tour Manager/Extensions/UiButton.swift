//
//  UiButton.swift
//  Tour Manager
//
//  Created by SHREDDING on 04.06.2023.
//

import Foundation
import UIKit

extension UIButton{
    
    public func setTitle(title:String,size:Int, style:fontStyle){
        let title = NSAttributedString(string: title ,attributes: [.font : Font.getFont(name: .americanTypewriter, style: .bold, size: CGFloat(size))])
        
        UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve) {
            self.setAttributedTitle(title, for: .normal)
        }
    }
    
}
