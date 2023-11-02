//
//  Results Extension.swift
//  Tour Manager
//
//  Created by SHREDDING on 22.10.2023.
//

import Foundation
import RealmSwift

extension Results {
    func toArray() -> [Element] {
      return compactMap {
        $0
      }
    }
 }
