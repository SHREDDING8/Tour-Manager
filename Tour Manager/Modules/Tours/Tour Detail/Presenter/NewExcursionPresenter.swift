//
//  NewExcursionPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 09.10.2023.
//

import Foundation
import UIKit
import RealmSwift
import WidgetKit

protocol NewExcursionViewProtocol:AnyObject, BaseViewControllerProtocol{
    func deleteSuccessful()
    func addedSuccessful()
    func updatedSuccessful()
    
    func refreshSuccess()
    func endRefreshing()
        
    func validationError(title:String, msg:String)
    
    func fillFields()
    func fillGuides()
}

protocol NewExcursionPresenterProtocol:AnyObject{
    init(view:NewExcursionViewProtocol, tour:ExcrusionModel?, date:Date?)
    
    var tour:ExcrusionModel! { get set }
    var oldTour:ExcrusionModel! { get }
    
    func isAccessLevel(key:AccessLevelKeys) -> Bool
    
    func getUser(by id:String) -> UsersModel?
    
    func isEqualTours()->Bool
    
    func saveButtonClick()
            
    func deleteTour()
        
    func getGuides()->[(guideId:String, guideName:String, guideStatus:UIColor, guideImage:UIImage?, isMain:Bool)]
    
    func loadTourFromServer()
        
}

class NewExcursionPresenter:NewExcursionPresenterProtocol{
    weak var view:NewExcursionViewProtocol?
    
    let validation = StringValidation()
    var tour:ExcrusionModel!
    
    var oldTour:ExcrusionModel!
    
    let keychain = KeychainService()
    
    let apiUserData = ApiManagerUserData()
    
    let toursNetworkService:ApiManagerExcursionsProtocol = ApiManagerExcursions()
    let toursRealmService:ExcursionsRealmServiceProtocol = ExcursionsRealmService()
    
    let usersRealmService:UsersRealmServiceProtocol = UsersRealmService()
    let imageService:ImagesRealmServiceProtocol = ImagesRealmService()
    let usersNetworkSevise:ApiManagerUserDataProtocol = ApiManagerUserData()

    required init(view:NewExcursionViewProtocol, tour:ExcrusionModel?, date:Date?) {
        self.view = view
        if tour != nil{
            self.tour = tour
            oldTour = tour
        }else{
            self.tour = ExcrusionModel(guides: [])
            self.tour?.dateAndTime = date ?? Date.now
            
            oldTour = self.tour
        }
        
    }
    
    public func isAccessLevel(key:AccessLevelKeys) -> Bool{
        return usersRealmService.getUserAccessLevel(localId: keychain.getLocalId() ?? "", key)
    }
    
    func isEqualTours()->Bool{
        return self.tour == oldTour
    }
    
    public func saveButtonClick(){
        
        if !validation.validateLenghtString(string: self.tour.tourTitle, min: 1, max: 100){
            view?.validationError(
                title: "Ошибка в названии экскурсии",
                msg: "Минимальная длина - 1. Максимальная длина - 100"
            )
            return
        }
        
        if !validation.validateLenghtString(string: self.tour.notes, max: 1000){
            
            view?.validationError(
                title: "Ошибка в заметках",
                msg: "Максимальная длина - 1000"
            )
            return
        }
        
        
        if !validation.validateNumberWithPlus(value: self.tour.numberOfPeople){
            view?.validationError(
                title: "Ошибка в количестве человек",
                msg: "Доступные символы: '0123456789+'"
            )
            return
        }
        
        if !validation.validateNumberWithPlus(value: self.tour.paymentAmount){
            
            view?.validationError(
                title: "Ошибка сумме оплаты",
                msg: "Доступные символы: '0123456789+'"
            )
            
            return
        }
        
        if self.tour.tourId.isEmpty{
            self.createNewExcursion()
        }else{
            self.updateExcursion()
        }
    }
    
    func loadTourFromServer(){
        if tour.tourId.isEmpty { fatalError("It is new tour")}
        view?.setUpdating()
        Task{
            do{
                let tourFromServer = try await toursNetworkService.getTour(
                    tourDate: oldTour.dateAndTime.birthdayToString(),
                    tourId: oldTour.tourId,
                    guideOnly: false
                )
                
                DispatchQueue.main.async {
                    
                    let guides:List<OneGuideRealmModel> = List<OneGuideRealmModel>()
                    
                    for tourGuide in tourFromServer.tourGuides{
                        let guide = OneGuideRealmModel(
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
                    
                    let updatedTour = ExcursionRealmModel(
                        tourId: tourFromServer.tourId,
                        tourTitle: tourFromServer.tourName,
                        route: tourFromServer.tourRoute,
                        notes: tourFromServer.tourNotes,
                        guideCanSeeNotes: tourFromServer.tourNotesVisible,
                        dateAndTime: Date.dateAndTimeToDate(
                            dateString: self.oldTour.dateAndTime.birthdayToString(),
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
                    
                    self.toursRealmService.updateTour(tourId: tourFromServer.tourId, tour: updatedTour)
                    
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
                            dateString: self.oldTour.dateAndTime.birthdayToString(),
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
    
    private func updateExcursion(){
        view?.setSaving()
        view?.showLoadingView()
        Task{
            do{
                if try await toursNetworkService.updateTour(tour: tour, oldDate:oldTour.dateAndTime){
                    DispatchQueue.main.async {
                        self.view?.updatedSuccessful()
                    }
                }
            } catch let error{
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
    
    private func createNewExcursion(){
        view?.setSaving()
        view?.showLoadingView()
        Task{
            do{
                if try await toursNetworkService.addNewTour(tour:self.tour){
                    DispatchQueue.main.async {
                        self.view?.addedSuccessful()
                    }
                }
                
            } catch let error{
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
    
    func deleteTour(){
        view?.setSaving()
        view?.showLoadingView()
        Task{
            do{
                let result = try await toursNetworkService.deleteTour(date: oldTour.dateAndTime.birthdayToString(), tourId: tour.tourId)
                
                if result{
                    DispatchQueue.main.async {
                        self.toursRealmService.deleteTour(tourId: self.tour.tourId)
                        self.view?.deleteSuccessful()
                    }
                }
                
            } catch let error{
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
    
    // MARK: - setData
    func setAmount(text:String){
        tour.paymentAmount = text
    }
}
