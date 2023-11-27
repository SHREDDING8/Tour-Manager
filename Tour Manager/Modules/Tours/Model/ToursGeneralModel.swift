//
//  ToursGeneralModel.swift
//  Tour Manager
//
//  Created by SHREDDING on 27.11.2023.
//

import Foundation
import UIKit
enum Status:String{
    case waiting = "waiting"
    case cancel = "cancel"
    case accepted = "accept"
    case emptyGuides = "emptyGuides"
    
    public func getColor()->UIColor{
        switch self{
            
        case .waiting:
            return .systemYellow
        case .cancel:
            return .systemRed
        case .accepted:
            return .systemGreen
        case .emptyGuides:
            return .systemBlue
        }
    }
}
