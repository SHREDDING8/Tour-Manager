//
//  ChoiceOfTypeAccountViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 06.05.2023.
//

import UIKit

final class TypeAccountViewController: BaseViewController {
    
    // MARK: - my Variables
    
    private func view() -> TypeOfAccountView{
        return view as! TypeOfAccountView
    }

    override func loadView() {
        super.loadView()
        self.view = TypeOfAccountView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleString = "Тип аккаунта"
        self.setBackButton()
        
        addTargets()
    }
    
    private func addTargets(){
        self.view().employee.addTarget(self, action: #selector(employeeTapped), for: .touchUpInside)
        self.view().newCompany.addTarget(self, action: #selector(newCompanyTapped), for: .touchUpInside)
    }
    
    
    @objc func employeeTapped(){
        let vc = AuthAssembly.createSetInfoViewController(type: .newEmployee)
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc func newCompanyTapped(){
        let vc = AuthAssembly.createSetInfoViewController(type: .newCompany)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
