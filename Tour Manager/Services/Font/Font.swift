//
//  Font.swift
//  Tour Manager
//
//  Created by SHREDDING on 05.05.2023.
//

import Foundation
import UIKit


enum fontNames:String{
    case americanTypewriter = "American Typewriter"
}
public enum fontStyle:String{
    case regular = ""
    case bold = "Bold"
    case light = "Light"
    case semiBold = "Semibold"
}

class Font{
    static public func getFont(name: fontNames, style:fontStyle, size:CGFloat) -> UIFont{
        if style == .regular{
            return UIFont(name: "\(name.rawValue)", size: size)!
        }
        return UIFont(name: "\(name.rawValue) \(style.rawValue)", size: size)!
    }
    
}
