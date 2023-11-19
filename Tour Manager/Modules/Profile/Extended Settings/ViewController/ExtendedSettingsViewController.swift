//
//  ExtendedSettingsViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 19.11.2023.
//

import UIKit
import AlertKit

class ExtendedSettingsViewController: UIViewController {
    
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
        
        addTargets()

        self.view().configureDevices(devices: [
            DevicesModel(type: .iphone, name: "14 pro max 123 asd dsgsdf  asdf  ad f a ddsf sdfsdf s"),
            DevicesModel(type: .ipad, name: "Ipad 9 generatino 324 sfasdf asdf adf sdfsd sdf"),
            DevicesModel(type: .mac, name: "macbook PRO 1078293081 0187238018023  sdfsdfsdfsdf "),
            DevicesModel(type: .telegram, name: "XR"),
            DevicesModel(type: .unknowm, name: "123 ljhjkfdslj alksjdhfkjas hjdhjfkalsf sdfsdfsdfsdfsdf"),
            
            DevicesModel(type: .iphone, name: "14 pro max"),
            DevicesModel(type: .ipad, name: "Ipad 9 generatino"),
            DevicesModel(type: .mac, name: "macbook PRO"),
            DevicesModel(type: .telegram, name: "XR"),
            DevicesModel(type: .unknowm, name: "123")
        ])
    }
    
    func addTargets(){
        self.view().deleteAccount.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        
        let changePasswordGesture = UITapGestureRecognizer(target: self, action: #selector(goToChangePassword))
        self.view().changePasswordStackView.addGestureRecognizer(changePasswordGesture)
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
        let controllers = Controllers()
        
        let vc = controllers.getControllerMain(.changePasswordViewController)
        
        self.navigationController?.pushViewController(vc, animated: true)
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
    
}
