//
//  ProfileNewViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 10.11.2023.
//

import UIKit

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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureGeneralInfo()
        configurePersonalInfo()
        
    }
    
    // MARK: - Targets
    
    private func addTargets(){
        
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
    
}

extension ProfileNewViewController:ProfileViewProtocol{
    func setProfilePhoto(image: UIImage) {
        UIView.transition(with: self.view().profileImage, duration: 0.3, options: .transitionCrossDissolve) {
            self.view().profileImage.image = image
        }
    }
    
    
}
