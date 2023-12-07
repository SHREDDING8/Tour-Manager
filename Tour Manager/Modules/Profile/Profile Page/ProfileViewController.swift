//
//  ProfileNewViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 10.11.2023.
//

import UIKit
import AlertKit

class ProfileViewController: UIViewController{
    
    var presenter:ProfilePagePresenterProtocol!
    
    lazy var imagePicker:UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
       
        return picker
    }()
    
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
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.view().changePhotoButton)
        
        DispatchQueue.main.async {
            self.addTargets()
            self.addDelegates()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureGeneralInfo()
        self.configurePersonalInfo()
        self.configureCompanyInfo()
        
        self.configureVisibleElements()
        
    }

    
    // MARK: - Targets
    
    private func addTargets(){
        let gesture = UITapGestureRecognizer(target: self, action: #selector(employeeTapped))
        self.view().employee.addGestureRecognizer(gesture)
        
        self.view().companyId.button.addTarget(self, action: #selector(copyCompanyId), for: .touchUpInside)
        
        self.view().changePhotoButton.addTarget(self, action: #selector(tapChangePhoto), for: .touchUpInside)
        
        let tapExtendedGesture = UITapGestureRecognizer(target: self, action: #selector(tapExtended))
        self.view().extendedSettings.addGestureRecognizer(tapExtendedGesture)
        
        self.view().logOutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
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
        let destination = ProfileAssembly.createEmployeeListViewController()
        
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
    
    @objc private func tapChangePhoto(){
        let alert = UIAlertController(title: "Изменить фото", message: nil, preferredStyle: .actionSheet)
        
        let actionLibary = UIAlertAction(title: "Медиатека", style: .default) { [self] _ in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true)
        }
        let actionCamera = UIAlertAction(title: "Камера", style: .default) { [self] _ in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true)
        }
        
        let actionDeletePhoto = UIAlertAction(title: "Удалить фотографию", style: .default) { _ in
            
            self.presenter.deleteProfilePhoto()
                        
        }
        let actionCancel = UIAlertAction(title: "Отменить", style: .cancel)
        
        alert.addAction(actionLibary)
        alert.addAction(actionCamera)
        alert.addAction(actionCancel)
        if self.view().profileImage.image != UIImage(resource: .noProfilePhoto){
            alert.addAction(actionDeletePhoto)
        }
        
        
        self.present(alert, animated: true)
     }
    
    @objc func tapExtended(){
        let view = ProfileAssembly.createExtendedSettingsViewController()
        
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    @objc func logout(){
        let alert = UIAlertController(title: "Вы уверены что хотите выйти?", message: nil, preferredStyle: .actionSheet)
        
        let exit = UIAlertAction(title: "Выйти", style: .destructive) { _ in
            self.presenter.logOut()
        }
        
        let cancel = UIAlertAction(title: "Отменить", style: .cancel)
        
        alert.addAction(exit)
        alert.addAction(cancel)
        
        self.present(alert, animated: true)
        
    }
    
}

extension ProfileViewController:UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.restorationIdentifier == "birthday"{
            (textField.inputView as? UIDatePicker)?.date = Date.birthdayFromString(dateString: self.presenter.getBirthday())
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.isUserInteractionEnabled = false
        
        
        self.view().firstName.textField.restorationIdentifier = "firstName"
        self.view().lastName.textField.restorationIdentifier = "lastName"
        self.view().birthday.textField.restorationIdentifier = "birthday"
        self.view().phone.textField.restorationIdentifier = "phone"
        
        self.view().companyNameElement.textField.restorationIdentifier = "companyNameElement"
        
        var updateField:UserDataFields? = nil
        switch textField.restorationIdentifier{
        case "firstName":
            updateField = .firstName
        case "lastName":
            updateField = .secondName
        case "birthday":
            updateField = .birthdayDate
        case "phone":
            updateField = .phone
        case "companyNameElement":
            self.presenter.updateCompanyInfo(companyName: textField.text ?? "")
        default:
            fatalError("Unknown TextField")
        }
        
        if let field = updateField{
            self.presenter.updatePersonalData(updateField: field, value: textField.text ?? "")
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
}

extension ProfileViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage{
            self.dismiss(animated: true)
            
            
            self.presenter.uploadProfilePhoto(image: image)
            
        }
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
}

extension ProfileViewController:ProfileViewProtocol{
    
    func logoutSuccess() {
        
        // TODO сделать алерт в котроллере логина
        AlertKitAPI.present(
            title: "Вы вышли из системы",
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
        AuthAssembly.goToLogin(view: self.view())
    }
    
    func logoutError() {
        AlertKitAPI.present(
            title: "Ошибка выхода из системы",
            icon: .error,
            style: .iOS17AppleMusic,
            haptic: .error
        )
    }
    
    
    func updateCompanyInfoError() {
        self.configureCompanyInfo()
        
        AlertKitAPI.present(
            title: "Ошибка изменения данных",
            icon: .error,
            style: .iOS17AppleMusic,
            haptic: .error
        )
    }
    
    func updateCompanyInfoSuccess() {
        self.configureGeneralInfo()
        AlertKitAPI.present(
            title: "Данные изменены",
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
    }
    
    
    func updateInfoSuccess() {
        self.configureGeneralInfo()
        
        AlertKitAPI.present(
            title: "Данные изменены",
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
    }
    
    func updateInfoError() {
        self.configureGeneralInfo()
        self.configurePersonalInfo()
        
        AlertKitAPI.present(
            title: "Ошибка изменения данных",
            icon: .error,
            style: .iOS17AppleMusic,
            haptic: .error
        )
    }
    
    func uploadSuccess(image: UIImage) {
        self.setProfilePhoto(image: image)
        
        AlertKitAPI.present(
            title: "Фото загружено",
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
    }
    
    func uploadError() {
        AlertKitAPI.present(
            title: "Ошибка при загрузке фото",
            icon: .error,
            style: .iOS17AppleMusic,
            haptic: .error
        )
    }
    

    func deletePhotoSuccess() {
        self.view().profileImage.image = UIImage(resource: .noProfilePhoto)
        
        AlertKitAPI.present(
            title: "Фото удалено",
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
    }
    
    func deletePhotoError() {
        AlertKitAPI.present(
            title: "Ошибка при удалении фото",
            icon: .error,
            style: .iOS17AppleMusic,
            haptic: .error
        )
    }
    
    func setProfilePhoto(image: UIImage) {
        UIView.transition(with: self.view().profileImage, duration: 0.3, options: .transitionCrossDissolve) {
            self.view().profileImage.image = image
        }
    }
    
}
