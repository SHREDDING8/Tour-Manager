//
//  EmploeeViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 01.06.2023.
//

import UIKit
import AlertKit

final class EmploeeViewController: BaseViewController {
    
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
        
        self.setBackButton()
        
        configureInfo()
        
        configureAccessLevels()
       
        addTargets()
        addDelegates()
        
        self.presenter.getUserInfoFromServer()
                
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
        
        self.view().scrollView.refreshControl = UIRefreshControl(frame: .zero, primaryAction: UIAction(handler: { _ in
            self.presenter.getUserInfoFromServer()
        }))
        
    }
    
    private func addDelegates(){
        self.view().profileImagesCollectionView.delegate = self
        self.view().profileImagesCollectionView.dataSource = self
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


// MARK: - Collection view DataSource

extension EmploeeViewController:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let num = self.presenter.getNumberOfPhotos()
        return num == 0 ? 1 : num
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfilePhotoCollectionViewCell", for: indexPath) as! ProfilePhotoCollectionViewCell
        
        if let image = self.presenter.getProfilePhoto(indexPath: indexPath){
            cell.setProfilePhoto(image: image)
        }
        
        return cell
    }
    
    
}

extension EmploeeViewController:UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.width)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Рассчитываем центральную точку коллекции
        
        if scrollView == self.view().profileImagesCollectionView{
            let centerX = scrollView.contentOffset.x + (scrollView.bounds.width / 2)

            // Находим индекс страницы, используя центральную точку
            if let indexPath = self.view().profileImagesCollectionView.indexPathForItem(at: CGPoint(x: centerX, y: self.view().profileImagesCollectionView.bounds.height / 2)) {
                
                if let cell = self.view().profileImagesCollectionView.cellForItem(at: indexPath) as? ProfilePhotoCollectionViewCell{
                    self.view().BGimageView.image = cell.profileImage.image
                }
            }
            
        }

    }
}



extension EmploeeViewController:EmployeeViewProtocol{
    func loadUserInfoFromServer() {
        self.configureInfo()
        self.configureAccessLevels()
        
        self.view().profileImagesCollectionView.reloadData()
        self.view().scrollView.refreshControl?.endRefreshing()
    }
    
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
    
    
    func updateImage(at indexPath:IndexPath, image:UIImage){
        if let cell = self.view().profileImagesCollectionView.cellForItem(at: indexPath) as? ProfilePhotoCollectionViewCell{
            cell.setProfilePhoto(image: image, animated: true)
        }
    }
    
}
