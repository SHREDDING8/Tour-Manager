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
    static func createTourDetailDatePicker(date:Date, doAfterChange:((Date)->Void)?) -> UIViewController
    
    static func createAutoFillComponentsController(type:AutofillType, baseValue:String?) -> UIViewController
    
    static func createAddGuideController(selectedGuides:[ExcrusionModel.Guide]) -> UIViewController
    
    static func createTourForGuideViewController(tour: ExcrusionModel)->UIViewController
    
    static func createToursManadgmentViewController() -> UIViewController
    
    static func createGuidesToursViewController() -> UIViewController
    
    static func createFullCalendarViewController(isGuide:Bool) -> UIViewController
}

final class TourManadmentAssembly:TourManadmentAssemblyProtocol{
    static func createNewTourController(isUpdate:Bool,dateTime:Date? = nil ,model:ExcrusionModel?  = nil) -> UIViewController{
        
        let vc = TourDetailViewController()
        vc.hidesBottomBarWhenPushed = true
        
        let presenter = NewExcursionPresenter(view: vc, tour: model, date: dateTime)
        vc.presenter = presenter
        
        return vc
    }
    
    static func createTourDetailDatePicker(date:Date, doAfterChange:((Date)->Void)?) -> UIViewController{
        let vc = TourDetailDatePickerViewController()
        vc.datePicker.date = date
        vc.doAfterChange = doAfterChange
        
        if let sheetController = vc.sheetPresentationController{
            sheetController.detents = [.large(),.medium()]
            sheetController.prefersGrabberVisible = true
            sheetController.preferredCornerRadius = 20
            sheetController.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        
        return vc
    }
    
    static func createAutoFillComponentsController(type:AutofillType, baseValue:String?) -> UIViewController{
        let vc = AddingNewComponentViewController()
        
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
        let vc = TourDetailForGuideViewController()
        vc.hidesBottomBarWhenPushed = true
                
        let presenter = OneGuideExcursionPresenter(view: vc, tour: tour)
        vc.presenter = presenter
        return vc
    }
    
    static func createGuidesToursViewController() -> UIViewController{
        let vc = GuideToursViewController()
        let presenter = ExcursionsGuideCalendarPresenter(view: vc)
        vc.presenter = presenter
        return BaseNavigationViewController(rootViewController: vc)
    }
    
    static func createToursManadgmentViewController() -> UIViewController{
        let vc = TourManadgmentViewController()
        
        let presenter =  ExcursionManadmentPresenter(view: vc)
        
        vc.presenter = presenter
        
        return BaseNavigationViewController(rootViewController: vc)
    }
    
    static func createFullCalendarViewController(isGuide:Bool) -> UIViewController{
        let vc = FullCalendarViewController()
        let presenter = FullCalendarPresenter(view: vc, isGuide: isGuide)
        vc.presenter = presenter
        
        let navVc = BaseNavigationViewController(rootViewController: vc)
        navVc.modalPresentationStyle = .fullScreen
        
        return navVc
    }

}
