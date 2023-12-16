//
//  OneGuideExcursionPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 10.10.2023.
//

import Foundation
import UIKit
import RealmSwift
import WidgetKit

protocol OneGuideExcursionViewProtocol:AnyObject, BaseViewControllerProtocol{
    func updateGuideStatus(guideStatus: Status)
    func fillGuides()
    func refreshSuccess()
    func endRefreshing()
}

protocol OneGuideExcursionPresenterProtocol:AnyObject{
    init(view:OneGuideExcursionViewProtocol, tour:ExcrusionModel)
    
    var tour:ExcrusionModel! { get set }
    
    func getUser(by id:String) -> UsersModel?
    
    func setGuideTourStatus(guideStatus: Status)
    func loadTourFromServer()
    
    func getGuides()->[(guideId:String, guideName:String, guideStatus:UIColor, guideImage:UIImage?, isMain:Bool)]
    
}

class OneGuideExcursionPresenter:OneGuideExcursionPresenterProtocol{
    weak var view:OneGuideExcursionViewProtocol?
    
    var tour:ExcrusionModel!
    
    let apiManagerExcursions = ApiManagerExcursions()
    let keychain = KeychainService()
    let apiUserData = ApiManagerUserData()
    
    let toursNetworkService:ApiManagerExcursionsProtocol = ApiManagerExcursions()
    let tourRealmService:ExcursionsRealmServiceForGuideProtocol = ExcursionsRealmServiceForGuide()
    let usersRealmService:UsersRealmServiceProtocol = UsersRealmService()
    let usersNetworkSevise:ApiManagerUserDataProtocol = ApiManagerUserData()
    let imageService:ImagesRealmServiceProtocol = ImagesRealmService()
    
    required init(view:OneGuideExcursionViewProtocol, tour:ExcrusionModel) {
        self.view = view
        self.tour = tour
    }
    
    func loadTourFromServer(){
        if tour.tourId.isEmpty { fatalError("It is new tour")}
        view?.setUpdating()
        Task{
            do{
                let tourFromServer = try await toursNetworkService.getTour(
                    tourDate: tour.dateAndTime.birthdayToString(),
                    tourId: tour.tourId,
                    guideOnly: false
                )
                
                DispatchQueue.main.async {
                    
                    let guides:List<OneGuideRealmModelForGuide> = List<OneGuideRealmModelForGuide>()
                    
                    for tourGuide in tourFromServer.tourGuides{
                        let guide = OneGuideRealmModelForGuide(
                            id: tourGuide.guideID,
                            firstName: tourGuide.guideFirstName ?? "",
                            lastName: tourGuide.guideLastName ?? "",
                            image: nil,
                            isMain: tourGuide.isMain,
                            status: .init(rawValue: tourGuide.status) ?? .waiting
                        )
                        guides.append(guide)
                        
                        self.usersRealmService.ovverideImages(userId: tourGuide.guideID, pictureIds: tourGuide.profilePictures)
                    }
                    
                    let updatedTour = ExcursionRealmModelForGuide(
                        tourId: tourFromServer.tourId,
                        tourTitle: tourFromServer.tourName,
                        route: tourFromServer.tourRoute,
                        notes: tourFromServer.tourNotes,
                        guideCanSeeNotes: tourFromServer.tourNotesVisible,
                        dateAndTime: Date.dateAndTimeToDate(
                            dateString: self.tour.dateAndTime.birthdayToString(),
                            timeString: tourFromServer.tourTimeStart
                        ),
                        numberOfPeople: tourFromServer.tourNumberOfPeople,
                        customerCompanyName: tourFromServer.customerCompanyName,
                        customerGuideName: tourFromServer.customerGuideName,
                        companyGuidePhone: tourFromServer.customerGuideContact,
                        paymentMethod: tourFromServer.paymentMethod,
                        paymentAmount: tourFromServer.paymentAmount,
                        isPaid: tourFromServer.isPaid,
                        guides: guides
                    )
                    
                    self.tourRealmService.updateTour(tourId: tourFromServer.tourId, tour: updatedTour)
                
                    var guidesForLocalModel:[ExcrusionModel.Guide] = []
                    
                    for tourGuide in tourFromServer.tourGuides{
                        let guide = ExcrusionModel.Guide(
                            id: tourGuide.guideID,
                            firstName: tourGuide.guideFirstName ?? "",
                            lastName: tourGuide.guideLastName ?? "",
                            isMain: tourGuide.isMain,
                            status: .init(rawValue: tourGuide.status) ?? .waiting
                        )
                        
                        guidesForLocalModel.append(guide)
                    }
                    self.tour = ExcrusionModel(
                        tourId: tourFromServer.tourId,
                        tourTitle: tourFromServer.tourName,
                        route: tourFromServer.tourRoute,
                        notes: tourFromServer.tourNotes,
                        guideCanSeeNotes: tourFromServer.tourNotesVisible,
                        dateAndTime: Date.dateAndTimeToDate(
                            dateString: self.tour.dateAndTime.birthdayToString(),
                            timeString: tourFromServer.tourTimeStart
                        ),
                        numberOfPeople: tourFromServer.tourNumberOfPeople,
                        customerCompanyName: tourFromServer.customerCompanyName,
                        customerGuideName: tourFromServer.customerGuideName,
                        companyGuidePhone: tourFromServer.customerGuideContact,
                        paymentMethod: tourFromServer.paymentMethod,
                        paymentAmount: tourFromServer.paymentAmount,
                        isPaid: tourFromServer.isPaid,
                        guides: guidesForLocalModel
                    )
                    
                    self.view?.refreshSuccess()
                }
                
            } catch let error{
                if let err = error as? NetworkServiceHelper.NetworkError{
                    self.view?.showError(error: err)
                }
            }
            DispatchQueue.main.async {
                self.view?.endRefreshing()
                self.view?.stopUpdating()
            }
            
            
        }
    }
    
    func setGuideTourStatus(guideStatus: Status){
        view?.setSaving()
        view?.showLoadingView()
        Task{
            do{
                if try await toursNetworkService.setGuideTourStatus(tourDate: tour.dateAndTime.birthdayToString(), tourId: tour.tourId, guideStatus: guideStatus){
                    DispatchQueue.main.async {
                        self.view?.updateGuideStatus(guideStatus:guideStatus)
                    }
                }
            }catch let error{
                if let err = error as? NetworkServiceHelper.NetworkError{
                    self.view?.showError(error: err)
                }
            }
            
            DispatchQueue.main.async {
                self.view?.stopSaving()
                self.view?.stopLoadingView()
            }
            
        }
        
    }
    
    func getUser(by id:String) -> UsersModel?{
        if let userRealm = usersRealmService.getUserInfo(localId: id){
            let res = UsersModel(
                localId: id,
                firstName: userRealm.firstName,
                secondName: userRealm.secondName,
                email: userRealm.email ?? "",
                phone: userRealm.phone ?? "",
                birthday: userRealm.birthday ?? Date.now,
                images: [],
                accessLevels: UsersModel.UserAccessLevels(
                    readCompanyEmployee: userRealm.accesslLevels?.readCompanyEmployee ?? false,
                    readLocalIdCompany: userRealm.accesslLevels?.readLocalIdCompany ?? false,
                    readGeneralCompanyInformation: userRealm.accesslLevels?.readGeneralCompanyInformation ?? false,
                    writeGeneralCompanyInformation: userRealm.accesslLevels?.writeGeneralCompanyInformation ?? false,
                    canChangeAccessLevel: userRealm.accesslLevels?.canChangeAccessLevel ?? false,
                    isOwner: userRealm.accesslLevels?.isOwner ?? false,
                    canReadTourList: userRealm.accesslLevels?.canReadTourList ?? false,
                    canWriteTourList: userRealm.accesslLevels?.canWriteTourList ?? false,
                    isGuide: userRealm.accesslLevels?.isGuide ?? false
                )
            )
            
            return res
        }
        return nil
    }
    
    func getGuides()->[(guideId:String,guideName:String, guideStatus:UIColor, guideImage:UIImage?, isMain:Bool)]{
        var imagesForDownload:[String] = []
        var res:[(guideId:String, guideName:String, guideStatus:UIColor, guideImage:UIImage?, isMain:Bool)] = []
        
        for guide in tour.guides {
            var filledGuide:(guideId:String, guideName:String, guideStatus:UIColor, guideImage:UIImage?, isMain:Bool) = (guide.id,"\(guide.firstName) \(guide.lastName)", guide.status.getColor(), nil, guide.isMain)
            
            if let userImageId = usersRealmService.getUserInfo(localId: guide.id)?.imageIDs.first{
                if let imageData = imageService.getImage(by: userImageId){
                    filledGuide.guideImage = UIImage(data: imageData)
                }else{
                    imagesForDownload.append(userImageId)
                }
            }
            
            res.append(filledGuide)
            
            
        }
        if imagesForDownload.count > 0{
            downloadPhotos(ids: imagesForDownload)
        }
        
        return res
    }
    
    private func downloadPhotos(ids:[String]){
        Task{
            var res:[(String, Data)] = []
            
            for id in ids {
                do{
                    let imageData = try await usersNetworkSevise.downloadProfilePhoto(pictureId: id)
                    res.append((id,imageData))
                    
                }catch let error{
                    if let err = error as? NetworkServiceHelper.NetworkError{
                        self.view?.showError(error: err)
                        if err == .noConnection{
                            return
                        }
                    }
                    
                }
            }
            
            DispatchQueue.main.sync {
                for i in res{
                    self.imageService.setNewImage(id: i.0, i.1)
                }
                
                self.view?.fillGuides()
            }
        }
    }
    
}
