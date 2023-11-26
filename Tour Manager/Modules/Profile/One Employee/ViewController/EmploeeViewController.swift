//
//  EmploeeViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 01.06.2023.
//

import UIKit
import AlertKit

final class EmploeeViewController: UIViewController {
    
    var presenter:EmployeePresenter!
    
    let alerts = Alert()
            
    let generalLogic = GeneralLogic()
    
    private func view() -> OneEmployeView {
        return view as! OneEmployeView
    }
    
    override func loadView() {
        super.loadView()
        self.view = OneEmployeView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureInfo()
        
        configureAccessLevels()
        view().setPhoto(image: presenter.user.image)
        
        addTargets()
                
    }
    
    
    // MARK: - ConfigurationView
    
    private func configureAccessLevels(){
        let accessLevels = presenter.user.accessLevels
        view().configureAccessLevels(
            isReadGeneralCompanyInformation: accessLevels.readGeneralCompanyInformation,
            isWriteGeneralCompanyInformation: accessLevels.writeGeneralCompanyInformation,
            isReadLocalIdCompany: accessLevels.readLocalIdCompany,
            isReadCompanyEmployee: accessLevels.readCompanyEmployee,
            isChangeAccessLevels: accessLevels.canChangeAccessLevel,
            isReadTours: accessLevels.canReadTourList,
            isWriteTour: accessLevels.canWriteTourList,
            isGuide: accessLevels.isGuide,
            isOwner: accessLevels.isOwner
        )
        
        view().configureIsChangingAccessLevels(
            isReadGeneralCompanyInformation: presenter.getAccessLevel(.readGeneralCompanyInformation),
            isWriteGeneralCompanyInformation: presenter.getAccessLevel(.writeGeneralCompanyInformation),
            isReadLocalIdCompany: presenter.getAccessLevel(.readLocalIdCompany),
            isReadCompanyEmployee: presenter.getAccessLevel(.readCompanyEmployee),
            isChangeAccessLevels: presenter.getAccessLevel(.canChangeAccessLevel),
            isReadTours: presenter.getAccessLevel(.canReadTourList),
            isWriteTour: presenter.getAccessLevel(.canWriteTourList),
            isGuide: presenter.getAccessLevel(.isGuide),
            isOwner: presenter.getAccessLevel(.isOwner)
        )
    }
    
    private func configureInfo(){
        view().configureInfo(
            companyName: self.presenter.getCompanyName(),
            name: self.presenter.user.firstName,
            lastName: self.presenter.user.secondName,
            birthday: self.presenter.user.birthday.birthdayToString(),
            email: self.presenter.user.email,
            phone: self.presenter.user.phone
        )
    }
    
    private func addTargets(){
        let gesture = UITapGestureRecognizer(target: self, action: #selector(call))
        self.view().phone.addGestureRecognizer(gesture)
        
        self.view().readGeneralInformation.switchControll.addTarget(self, action: #selector(changeAccessLevel(_:)), for: .valueChanged)
        
        self.view().writeGeneralInformation.switchControll.addTarget(self, action: #selector(changeAccessLevel(_:)), for: .valueChanged)
        self.view().readCompanyId.switchControll.addTarget(self, action: #selector(changeAccessLevel(_:)), for: .valueChanged)
        self.view().readEmployee.switchControll.addTarget(self, action: #selector(changeAccessLevel(_:)), for: .valueChanged)
        self.view().changeAccessLevel.switchControll.addTarget(self, action: #selector(changeAccessLevel(_:)), for: .valueChanged)
        self.view().readTours.switchControll.addTarget(self, action: #selector(changeAccessLevel(_:)), for: .valueChanged)
        self.view().writeTours.switchControll.addTarget(self, action: #selector(changeAccessLevel(_:)), for: .valueChanged)
        self.view().isGuide.switchControll.addTarget(self, action: #selector(changeAccessLevel(_:)), for: .valueChanged)
        
    }
    
    // MARK: - Actions
    
    @objc private func call(){
        generalLogic.callNumber(phoneNumber: self.view().phone.textField.text ?? "")
    }
    
    @objc private func changeAccessLevel(_ switchControll: UISwitch){
        var changeLevelType: UsersModel.AccessLevel
        
        switch switchControll.restorationIdentifier{
            
        case "ReadGeneral":
            changeLevelType = .readGeneralCompanyInformation
            
        case "WriteGeneral":
            changeLevelType = .writeGeneralCompanyInformation
        
        case "ReadId":
            changeLevelType = .readLocalIdCompany
        
        case "SeeEmployee":
            changeLevelType = .readCompanyEmployee
        
        case "ChangeAccessLevels":
            changeLevelType = .canChangeAccessLevel
            
        case "ReadTours":
            changeLevelType = .canReadTourList
            
        case "WriteTours":
            changeLevelType = .canWriteTourList
        
        case "IsGuide":
            changeLevelType = .isGuide
        
        default:
            fatalError("Unknown Switch Controll")
        }
        
        presenter.updateAccessLevel(accessLevel: changeLevelType, value: switchControll.isOn)
    }
}


// MARK: - Table view Delegate

//extension EmploeeViewController:UITableViewDelegate,UITableViewDataSource{
        
    // MARK: - PersonalData Cell
        
//    fileprivate func accessLevelCell(indexPath:IndexPath) ->UITableViewCell{
        

//        let rule = employee.getAccessLevelRule(index: indexPath.row + 1)
//        label.text = employee.getAccessLevelLabel(rule: rule)
//        
//        switchButton.isOn = employee.getAccessLevel(rule: rule)
        
//        switchButton.removeTarget(self, action: nil, for: .valueChanged)
//        switchButton.addAction(UIAction(handler: { _ in
//            self.presenter?.updateAccessLevel(employe: self.employee, accessLevel: rule, value: switchButton.isOn) { isUpdated, error in
//
//                if  let err = error{
//                    self.alerts.errorAlert(self, errorCompanyApi: err) {
//                        switchButton.isOn = !switchButton.isOn
//                    }
//                }
//            }
//        }), for: .valueChanged)
        
        
//        if !(self.presenter?.getAccessLevel(localId: employee.localId ?? "", rule: .canChangeAccessLevel) ?? false) ||
//            !(self.presenter?.getAccessLevel(localId: employee.localId ?? "", rule: .canReadTourList) ?? false) || // rule
//            self.presenter?.getLocalID() == employee.getLocalID() ||
//            self.employee.getAccessLevel(rule: .isOwner){
//            switchButton.isEnabled = false
//            switchButton.layer.opacity = 0.5
//        }
        
//        if self.presenter?.getAccessLevel(localId: employee.localId ?? "", rule: .isOwner) ?? false && rule == .isGuide{
//            switchButton.isEnabled = true
//            switchButton.layer.opacity = 1
//        }

        
//        return UITableViewCell()
        
//    }
    

extension EmploeeViewController:EmployeeViewProtocol{
    func changeLevelSuccess() {
        AlertKitAPI.present(
            title: "Права доступа изменены",
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
    }
    
    func changeLevelError() {
        self.configureAccessLevels()
        
        AlertKitAPI.present(
            title: "Ошибка изменения прав доступа",
            icon: .error,
            style: .iOS17AppleMusic,
            haptic: .error
        )
    }
    
    
    func setImage(imageData: Data) {
        
    }
    
}
