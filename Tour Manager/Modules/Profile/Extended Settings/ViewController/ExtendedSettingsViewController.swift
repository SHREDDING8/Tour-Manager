//
//  ExtendedSettingsViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 19.11.2023.
//

import UIKit
import AlertKit

final class ExtendedSettingsViewController: BaseViewController {
    
    var presenter:ExtendedSettingsPresenterProtocol!
    
    private func view()->ExtendedSettingsView{
        return view as! ExtendedSettingsView
    }
    
    override func loadView() {
        super.loadView()
        self.view = ExtendedSettingsView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setBackButton()
        self.titleString = "Расширенные настройки"
        
        addTargets()
        self.presenter.loadLoggedDevices()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.loadLoggedDevices()
    }
    
    func addTargets(){
        self.view().deleteAccount.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        
        let changePasswordGesture = UITapGestureRecognizer(target: self, action: #selector(goToChangePassword))
        self.view().changePasswordStackView.addGestureRecognizer(changePasswordGesture)
        
        self.view().logoutAll.addTarget(self, action: #selector(logoutAll), for: .touchUpInside)
        
        let refresh = UIRefreshControl(frame: .zero, primaryAction: UIAction(handler: { _ in
            self.presenter.getLoggedDevicesFromServer()
        }))
        self.view().scrollView.refreshControl = refresh
    }
    
    // MARK: - Actions
    
    @objc func deleteTapped(){
        let isOwner = presenter.isOwner()
        
        let alertTitle = isOwner == true ? "Вы действительно хотите удалить аккаунт?\nВы также удалите свою компанию" : "Вы уверены что хотите удалить аккаунт?"
        
        let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        
        let delete = UIAlertAction(title: "Удалить", style: .destructive) { _ in
            
            let confirmAlertTitle = isOwner == true ? "Введите название компании" : "Введите свое имя и фамилию"
            let confirmAlert = UIAlertController(title: confirmAlertTitle, message: nil, preferredStyle: .alert)
            confirmAlert.addTextField()
            
            let confirmDelete = UIAlertAction(title: "Удалить", style: .destructive) { _ in
                if isOwner{
                    if self.presenter.getCompanyName() == confirmAlert.textFields![0].text{
                        self.presenter.deleteCompany()
                    }else{
                        self.showDataError()
                    }
                }else{
                    if self.presenter.getFullName() == confirmAlert.textFields![0].text{
                        self.presenter.deleteAccount()
                    }else{
                        self.showDataError()
                    }
                }
            }
            
            let confirmCancel = UIAlertAction(title: "Отменить", style: .cancel)
            
            confirmAlert.addAction(confirmDelete)
            confirmAlert.addAction(confirmCancel)
            self.present(confirmAlert, animated: true)
        }
        
        let cancel = UIAlertAction(title: "Отменить", style: .cancel)
        
        alert.addAction(delete)
        alert.addAction(cancel)
        self.present(alert, animated: true)
    }
    
    @objc func goToChangePassword(){
        
        let vc = ProfileAssembly.createChangePasswordViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func logoutAll(){
        let alert = UIAlertController(title: "Выйти со всех устройств кроме текущего", message: "Введите пароль", preferredStyle: .alert)
        let exit = UIAlertAction(title: "Выйти", style: .destructive) { _ in
            self.presenter.revokeAllDevices(password: alert.textFields?.first?.text ?? "")
        }
        let cancel = UIAlertAction(title: "Отменить", style: .cancel)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Пароль"
            textField.isSecureTextEntry = true
            // Обработчик события изменения текста в текстовом поле
            textField.addAction(UIAction(handler: { _ in
                if let text = textField.text, !text.isEmpty {
                    alert.actions[0].isEnabled = true
                } else {
                    alert.actions[0].isEnabled = false
                }
            }), for: .editingChanged)
            
        }
        alert.addAction(exit)
        alert.addAction(cancel)
        alert.actions[0].isEnabled = false
        self.present(alert, animated: true)
        
    }
    
    private func showDataError(){
        AlertKitAPI.present(
            title: "Не правильно введены данные",
            icon: .error,
            style: .iOS17AppleMusic,
            haptic: .error
        )
    }
    
}

extension ExtendedSettingsViewController:ExtendedSettingsViewProtocol{
    func deleteSuccess() {
        MainAssembly.goToLoginPage(view: self.view)
    }
    
    func logoutAllSuccessful() {
        AlertKitAPI.present(
            title: "Вы вышли со всех устройств",
            subtitle: nil,
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
    }
        
    func updateLoggedDevices(devices: [DevicesModel]) {
        self.view().configureDevices(devices: devices)
    }
    
    func endRefreshing(){
        self.view().scrollView.refreshControl?.endRefreshing()
    }
    
    
}
