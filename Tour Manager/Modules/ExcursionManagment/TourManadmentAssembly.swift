//
//  TourManadmentAssembly.swift
//  Tour Manager
//
//  Created by SHREDDING on 09.10.2023.
//

import Foundation
import UIKit

protocol TourManadmentAssemblyProtocol{
    static func createNewTourController(isUpdate:Bool,dateTime:Date?, model:ExcrusionModel?) -> UIViewController
    static func createAutoFillComponentsController(type:AutofillType, baseValue:String?) -> UIViewController
    static func createAddGuideController(selectedGuides:[ExcrusionModel.Guide]) -> UIViewController
    
    static func createTourForGuideViewController(tour: ExcrusionModel)->UIViewController
}

class TourManadmentAssembly:TourManadmentAssemblyProtocol{
    static func createNewTourController(isUpdate:Bool,dateTime:Date? = nil ,model:ExcrusionModel?  = nil) -> UIViewController{
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewExcursionTableViewController") as! NewExcursionTableViewController
        vc.isUpdate = isUpdate
        vc.hidesBottomBarWhenPushed = true
        let presenter = NewExcursionPresenter(view: vc, tour: model, date: dateTime)
        vc.presenter = presenter
        
        return vc
    }
    
    static func createAutoFillComponentsController(type:AutofillType, baseValue:String?) -> UIViewController{
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddingNewComponentViewController") as! AddingNewComponentViewController
        
        let presenter = AddingNewComponentPresenter(view: vc, type: type, baseValue: baseValue)
        vc.presenter = presenter
        
        return vc
    }
    
    static func createAddGuideController(selectedGuides:[ExcrusionModel.Guide] = []) -> UIViewController{
        let view = AddGuideViewController()
        let presenter = AddGuidePresenter(view: view)
        presenter.selectedGuides = selectedGuides
        view.presenter = presenter
        
        return view
    }
    
    static func createTourForGuideViewController(tour: ExcrusionModel)->UIViewController{
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ExcursionForGuideTableViewController") as! ExcursionForGuideTableViewController
        
        let presenter = OneGuideExcursionPresenter(view: vc, tour: tour)
        vc.presenter = presenter
        return vc
    }

}
