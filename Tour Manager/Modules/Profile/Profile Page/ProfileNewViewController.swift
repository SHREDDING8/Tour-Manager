//
//  ProfileNewViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 10.11.2023.
//

import UIKit
import AlertKit

class ProfileNewViewController: UIViewController {
    
    var presenter:ProfilePagePresenterProtocol!
    
    private func view() -> ProfileView{
        return self.view as! ProfileView
    }
    
    // MARK: - Life Cycle
    override func loadView() {
        super.loadView()
        self.view = ProfileView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTargets()
        addDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureGeneralInfo()
        configurePersonalInfo()
        configureCompanyInfo()
        
        configureVisibleElements()
        
    }
    
    // MARK: - Targets
    
    private func addTargets(){
        let gesture = UITapGestureRecognizer(target: self, action: #selector(employeeTapped))
        self.view().employee.addGestureRecognizer(gesture)
        
        self.view().companyId.button.addTarget(self, action: #selector(copyCompanyId), for: .touchUpInside)
    }
    
    private func addDelegates(){
        self.view().firstName.textField.delegate = self
        self.view().lastName.textField.delegate = self
        self.view().birthday.textField.delegate = self
        self.view().phone.textField.delegate = self
        
        self.view().companyNameElement.textField.delegate = self
        
        self.view().firstName.textField.restorationIdentifier = "firstName"
        self.view().lastName.textField.restorationIdentifier = "lastName"
        self.view().birthday.textField.restorationIdentifier = "birthday"
        self.view().phone.textField.restorationIdentifier = "phone"
        
        self.view().companyNameElement.textField.restorationIdentifier = "companyNameElement"
        
    }
    
    // MARK: - configureViewWithData
    private func configureGeneralInfo(){
        
        presenter.getProfilePhoto()
        
        self.view().configureGeneralInfo(
            userImage: presenter.getProfilePhotoFromRealm(),
            fullname: presenter.getFullName(),
            companyName: presenter.isAccessLevel(key: .readGeneralCompanyInformation) == true ? presenter.getCompanyName() : nil
        )
    }
    
    private func configurePersonalInfo(){
        self.view().configurePersonalInfo(
            name: presenter.getFirstName(),
            lastName: presenter.getSecondName(),
            birhday: presenter.getBirthday(),
            email: presenter.getEmail(),
            phone: presenter.getPhone()
        )
    }
    
    private func configureCompanyInfo(){
        self.view().configureCompanyInfo(
            companyName: presenter.getCompanyName(),
            companyId: presenter.getCompanyId()
        )
    }
    
    private func configureVisibleElements(){
        self.view().configureVisibleElements(
            isReadLocalIdCompany: presenter.isAccessLevel(key: .readLocalIdCompany),
            isReadGeneralCompanyInformation: presenter.isAccessLevel(key: .readGeneralCompanyInformation),
            isReadCompanyEmployee: presenter.isAccessLevel(key: .readCompanyEmployee),
            isWriteGeneralCompanyInformation: presenter.isAccessLevel(key: .writeGeneralCompanyInformation)
        )
    }
    
    // MARK: - Actions
    
    @objc func employeeTapped(){
        let controllers = Controllers()
        let destination = controllers.getControllerMain(.emploeeTableViewController)
        
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
    @objc func copyCompanyId(){
        UIPasteboard.general.string = presenter.getCompanyId()
        AlertKitAPI.present(
            title: "Индентификатор скопирован",
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
    }
    
}

extension ProfileNewViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.isUserInteractionEnabled = false
        return true
    }
    
}

extension ProfileNewViewController:ProfileViewProtocol{
    func setProfilePhoto(image: UIImage) {
        UIView.transition(with: self.view().profileImage, duration: 0.3, options: .transitionCrossDissolve) {
            self.view().profileImage.image = image
        }
    }
    
}
