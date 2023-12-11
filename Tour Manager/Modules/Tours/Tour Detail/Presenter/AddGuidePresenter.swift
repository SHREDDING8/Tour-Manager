//
//  AddGuidePresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 23.10.2023.
//

import Foundation

protocol AddGuideViewProtocol:AnyObject{
    func updateUsersList()
    func updateAllGuidesList()
}

protocol AddGuidePresenterProtocol:AnyObject{
    init(view:AddGuideViewProtocol)
    
    var selectedGuides:[ExcrusionModel.Guide] { get }
    var presentedGuides:[UsersModel] { get }
    
    func filterPresentedGuides() -> [UsersModel]
    
    func loadGuides()
    func getUsersFromServer()
    func getPresentGuide(index:Int) -> UsersModel
    func isGuideContains(index:Int) -> Bool
    func didSelectPresented(index:Int)
    func didSelectSelected(index:Int)
    func setMain(index:Int)
    func isMain(index:Int) ->Bool
    
    func textFieldChanged(text: String)
}

class AddGuidePresenter:AddGuidePresenterProtocol{
    weak var view:AddGuideViewProtocol?
    
    var selectedGuides:[ExcrusionModel.Guide] = []
    var allGuides:[UsersModel] = []
    var presentedGuides:[UsersModel] = []
    
    var usersRealmService:UsersRealmServiceProtocol = UsersRealmService()
    var employeeNetworkService:EmployeeNetworkServiceProtocol = EmployeeNetworkService()
    
    required init(view:AddGuideViewProtocol) {
        self.view = view
    }
    
    func loadGuides(){
        getUsersFromRealm()
        getUsersFromServer()
    }
    
    func filterPresentedGuides() -> [UsersModel]{
        return presentedGuides.filter { presentedGuide in
            
            !selectedGuides.contains { selectedGuide in
                selectedGuide.id == presentedGuide.localId
            }
            
        }
    }
    
    func getPresentGuide(index:Int) -> UsersModel{
        return self.filterPresentedGuides()[index]
    }
    
    func isGuideContains(index:Int) -> Bool{
        
        selectedGuides.contains { selectedGuide in
            selectedGuide.id == presentedGuides[index].localId
        }

    }
    
    func didSelect(index:Int){
        let selectedGuide = presentedGuides[index]
        var guideModel = ExcrusionModel.Guide(
            id: selectedGuide.localId,
            firstName: selectedGuide.firstName,
            lastName: selectedGuide.secondName,
            isMain: false,
            status: .waiting
        )
        if !isGuideContains(index: index){
            if selectedGuides.count == 0{
                guideModel.isMain = true
            }
            self.selectedGuides.append(guideModel)
        }else{
            self.selectedGuides.removeAll { guide in
                guide.id == selectedGuide.localId
            }
        }
        
        self.view?.updateUsersList()
        
    }
    
    func didSelectPresented(index:Int){
        let selectedGuide = filterPresentedGuides()[index]
        let guideModel = ExcrusionModel.Guide(
            id: selectedGuide.localId,
            firstName: selectedGuide.firstName,
            lastName: selectedGuide.secondName,
            isMain: selectedGuides.count == 0 ? true : false,
            status: .waiting
        )
        self.selectedGuides.append(guideModel)
        self.view?.updateUsersList()
        
    }
    
    func didSelectSelected(index:Int){
        let deleted = self.selectedGuides.remove(at: index)
        if deleted.isMain{
            if selectedGuides.count > 0{
                selectedGuides[0].isMain = true
            }
        }
        self.view?.updateUsersList()
    }
    
    func setMain(index:Int){
        if self.isGuideContains(index: index){
            for guideIndex in 0..<selectedGuides.count {
                if selectedGuides[guideIndex].id == selectedGuides[index].id{
                    selectedGuides[guideIndex].isMain = true
                }else{
                    selectedGuides[guideIndex].isMain = false
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
            self.view?.updateUsersList()
        }
    }
    
    func isMain(index:Int) ->Bool{
        if self.isGuideContains(index: index){
            return selectedGuides.first { selectedGuide in
                selectedGuide.id == selectedGuides[index].id
            }?.isMain ?? false
        }
        
        return false
    }
    
    func textFieldChanged(text: String){
        if text.isEmpty{
            self.presentedGuides = self.allGuides
        }else{
            self.presentedGuides = []
            
            for guide in allGuides{
                if guide.firstName.lowercased().contains(text.lowercased()) || guide.secondName.lowercased().contains(text.lowercased()) {
                    presentedGuides.append(guide)
                }
            }
        }
        
        view?.updateAllGuidesList()
    }
    
    
    func getUsersFromRealm(){
        let realmUsers = usersRealmService.getAllUsers()
        self.allGuides = []
        
        for user in realmUsers{
            if (user.accesslLevels?.isGuide ?? false){
                let newUserModel = UsersModel(
                    localId: user.localId,
                    firstName: user.firstName,
                    secondName: user.secondName,
                    email: user.email ?? "",
                    phone: user.phone ?? "",
                    birthday: user.birthday ?? Date.now,
                    images: [],
                    accessLevels: UsersModel.UserAccessLevels(
                        readCompanyEmployee: user.accesslLevels?.readCompanyEmployee ?? false,
                        readLocalIdCompany: user.accesslLevels?.readLocalIdCompany ?? false,
                        readGeneralCompanyInformation: user.accesslLevels?.readGeneralCompanyInformation ?? false,
                        writeGeneralCompanyInformation: user.accesslLevels?.writeGeneralCompanyInformation ?? false,
                        canChangeAccessLevel: user.accesslLevels?.canChangeAccessLevel ?? false,
                        isOwner: user.accesslLevels?.isOwner ?? false,
                        canReadTourList: user.accesslLevels?.canReadTourList ?? false,
                        canWriteTourList: user.accesslLevels?.canWriteTourList ?? false,
                        isGuide: user.accesslLevels?.isGuide ?? false))
                
                self.allGuides.append(newUserModel)
            }
            
        }
        
        self.presentedGuides = allGuides
        
        view?.updateUsersList()
    }
    
    func getUsersFromServer(){
        Task{
            do {
                // TODO
                let jsonUsers = try await self.employeeNetworkService.getCompanyUsers()
                
                for jsonUser in jsonUsers {
                    let realmUser = UserRealm(
                        localId: jsonUser.uid,
                        firstName: jsonUser.firstName,
                        secondName: jsonUser.lastName,
                        email: jsonUser.email,
                        phone: jsonUser.phone,
                        birthday: Date.birthdayFromString(dateString: jsonUser.birthdayDate), imageIDs: [],
                        accesslLevels: UserAccessLevelRealm(
                            readCompanyEmployee: jsonUser.accessLevels.readCompanyEmployee,
                            readLocalIdCompany: jsonUser.accessLevels.readLocalIDCompany,
                            readGeneralCompanyInformation: jsonUser.accessLevels.readGeneralCompanyInformation,
                            writeGeneralCompanyInformation: jsonUser.accessLevels.writeGeneralCompanyInformation,
                            canChangeAccessLevel: jsonUser.accessLevels.canChangeAccessLevel,
                            isOwner: jsonUser.accessLevels.isOwner,
                            canReadTourList: jsonUser.accessLevels.canReadTourList,
                            canWriteTourList: jsonUser.accessLevels.canWriteTourList,
                            isGuide: jsonUser.accessLevels.isGuide))
                    
                    DispatchQueue.main.sync {
                        usersRealmService.setUserInfo(user: realmUser)
                    }
                    
                }
                DispatchQueue.main.async {
                    self.getUsersFromRealm()
                }
                
            } 
//            catch customErrorCompany.unknowmError{
//                DispatchQueue.main.async {
////                    self.view?.unknownError()
//                }
//            }
        }
    }
    
}
