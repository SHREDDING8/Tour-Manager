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
enum fontStyle:String{
    case regular = "Regular"
    case bold = "Bold"
    case light = "Light"
    case semiBold = "Semibold"
}

class Font{
    public func getFont(name: fontNames, style:fontStyle, size:CGFloat) -> UIFont{
        return UIFont(name: "\(name.rawValue) \(style.rawValue)", size: size)!
    }
    
}
