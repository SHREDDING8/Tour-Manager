//
//  GuideExcursionsPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 10.10.2023.
//

import Foundation
import RealmSwift

protocol ExcursionsGuideCalendarViewProtocol:AnyObject{
    func updateTours()
    func updateEvents()
}

protocol ExcursionsGuideCalendarPresenterProtocol:AnyObject{
    init(view:ExcursionsGuideCalendarViewProtocol)
        
    var tours:[String:[ExcrusionModel]] { get set }
    
    func loadTours(date:Date)
    
    func getExcursionsListForGuideByRange(startDate:String, endDate:String, completion: @escaping (Bool, ExcursionsListForGuideByRange?, customErrorExcursion?)->Void )
    }

class ExcursionsGuideCalendarPresenter:ExcursionsGuideCalendarPresenterProtocol{
    weak var view:ExcursionsGuideCalendarViewProtocol?
        
    var tours:[String:[ExcrusionModel]] = [:]
    
    let keychain = KeychainService()
    let apiManagerExcursions = ApiManagerExcursions()
    
    let toursRealmService:ExcursionsRealmServiceForGuideProtocol = ExcursionsRealmServiceForGuide()
    
    let toursNetworkService:ApiManagerExcursionsProtocol = ApiManagerExcursions()
    
    required init(view:ExcursionsGuideCalendarViewProtocol) {
        self.view = view
    }
    
    func loadTours(date:Date){
        DispatchQueue.main.async {
            self.loadToursFromRealm(date: date)
            self.loadToursFromServer(date: date)
        }
    }
    
    private func loadToursFromRealm(date:Date){
        let dateString = date.birthdayToString()
        self.view?.updateTours()
        
        print("toursRealmService.getTours")
        if let tours = toursRealmService.getToursForGuide(dateString: dateString)?.getTours(){
            var toursModel:[ExcrusionModel] = []
            for tour in tours{
                var guides:[ExcrusionModel.Guide] = []
                
                for guide in tour.guides{
                    let guideStatus:ExcrusionModel.GuideStatus = {
                        switch guide.status {
                        case .waiting:
                            return .waiting
                        case .cancel:
                            return .cancel
                        case .accept:
                            return .accept
                        }
                    }()
                    print(guide.status)
                    let newGuide = ExcrusionModel.Guide(
                        id: guide.id, firstName: guide.firstName,
                        lastName: guide.lastName,
                        isMain: guide.isMain,
                        status: guideStatus)
                    
                    guides.append(newGuide)
                }
                
                
                let newTourModel = ExcrusionModel(
                    tourId: tour.tourId,
                    tourTitle: tour.tourTitle,
                    route: tour.route,
                    notes: tour.notes,
                    guideCanSeeNotes: tour.guideCanSeeNotes,
                    dateAndTime: tour.dateAndTime,
                    numberOfPeople: tour.numberOfPeople,
                    customerCompanyName: tour.customerCompanyName,
                    customerGuideName: tour.customerGuideName,
                    companyGuidePhone: tour.companyGuidePhone,
                    paymentMethod: tour.paymentMethod,
                    paymentAmount: tour.paymentAmount,
                    isPaid: tour.isPaid,
                    guides: guides)
                
                toursModel.append(newTourModel)
            }
            
            self.tours.updateValue(toursModel, forKey: dateString)
            print("toursRealmService.updateTours")
            self.view?.updateTours()
            
        }
    }
    
    private func loadToursFromServer(date:Date){
        Task{
            do{
                let toursJson = try await toursNetworkService.GetExcursionsForGuide(date: date.birthdayToString())
                
                let realmTours:List<ExcursionRealmModelForGuide> = List<ExcursionRealmModelForGuide>()
                for tourJson in toursJson{
                    let guides: List<OneGuideRealmModelForGuide> = List<OneGuideRealmModelForGuide>()
                    
                    for tourGuide in tourJson.tourGuides {
                        let guide = OneGuideRealmModelForGuide(
                            id: tourGuide.guideID,
                            firstName: tourGuide.guideFirstName ?? "",
                            lastName: tourGuide.guideLastName ?? "",
                            image: nil,
                            isMain: tourGuide.isMain,
                            status: .init(rawValue: tourGuide.status) ?? .waiting
                        )
                        guides.append(guide)
                    }
                    
                    
                    let newRealmTour = ExcursionRealmModelForGuide(
                        tourId: tourJson.tourId,
                        tourTitle: tourJson.tourName,
                        route: tourJson.tourRoute,
                        notes: tourJson.tourNotes,
                        guideCanSeeNotes: tourJson.tourNotesVisible,
                        dateAndTime: Date.dateAndTimeToDate(dateString: date.birthdayToString(), timeString: tourJson.tourTimeStart),
                        numberOfPeople: tourJson.tourNumberOfPeople,
                        customerCompanyName: tourJson.customerCompanyName,
                        customerGuideName: tourJson.customerGuideName,
                        companyGuidePhone: tourJson.customerGuideContact,
                        paymentMethod: tourJson.paymentMethod,
                        paymentAmount: tourJson.paymentAmount,
                        isPaid: tourJson.isPaid,
                        guides: guides
                    )
                    
                    realmTours.append(newRealmTour)
                }
                
                let realm = DatesExcursionForGuide(dateString: date.birthdayToString(), tours: realmTours)
                
                DispatchQueue.main.async {
                    self.toursRealmService.setToursForGuide(dateExcursions: realm)
                    self.loadToursFromRealm(date: date)
                }
                
            }catch{
                
            }
        }
    }
    
    
    
    public func getExcursionsListForGuideByRange(startDate:String, endDate:String, completion: @escaping (Bool, ExcursionsListForGuideByRange?, customErrorExcursion?)->Void ){
        apiManagerExcursions.getExcursionsForGuideListByRange(token: keychain.getAcessToken() ?? "", companyId: keychain.getCompanyLocalId() ?? "", startDate: startDate, endDate: endDate) { isGetted, list, error in
            completion(isGetted,list,error)
        }
    }
}
