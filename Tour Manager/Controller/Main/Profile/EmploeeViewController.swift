//
//  EmploeeViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 01.06.2023.
//

import UIKit

class EmploeeViewController: UIViewController {
    
    let user = AppDelegate.user
    let profileModel = Profile()
    
    var employee:User!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var profilePhoto: UIImageView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurationView()
        
        profilePhotoConfiguration()
        
    }
    
    
    // MARK: - ConfigurationView
    
    public func configurationView(){
        self.navigationItem.title = employee.getFullName()
    }
    
    
    
    fileprivate func setProfilePhoto(image:UIImage){
        UIView.transition(with: self.profilePhoto, duration: 0.3, options: .transitionCrossDissolve) {
            self.profilePhoto.image = image
        }
    }
    
    fileprivate func profilePhotoConfiguration(){
        self.profilePhoto.clipsToBounds = true
        self.profilePhoto.layer.masksToBounds = true
        
        self.profilePhoto.layer.cornerRadius = self.profilePhoto.frame.height / 2
        
        self.user?.downloadProfilePhoto(localId: self.employee.getLocalID() ?? "", completion: { data, error in
            if data != nil{
                self.setProfilePhoto(image: UIImage(data: data!)!)
            }
        })
    }


}


// MARK: - Table view Delegate

extension EmploeeViewController:UITableViewDelegate,UITableViewDataSource{
    
    // MARK: - Header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        let title = UILabel(frame: CGRect(x: 15, y: 0, width: self.view.frame.width - 30, height: 50))
        header.addSubview(title)
        
        header.backgroundColor = .white
        title.font = UIFont(name: "American Typewriter Bold", size: 24)
        
        switch section{
        case 0: title.text = "Персональные данные"
        case 1: title.text = "Права доступа"
        default: title.text = ""
        }
        return header
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 5
        case 1:
            return employee.getNumberOfAccessLevel() - 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        switch indexPath.section{
        case 0:
            cell = personalDataCell(indexPath: indexPath)
        case 1:
            cell = accessLevelCell(indexPath: indexPath)
        default:
            break
        }

        return cell

    }
    
    
    
    // MARK: - PersonalData Cell
    
    fileprivate func personalDataCell(indexPath:IndexPath) -> UITableViewCell{
        var cell = UITableViewCell()
        let cellType = profileModel.getProfilePersonalDataCellType(index: indexPath.row)
        
        switch indexPath.row{
        case 0...1, 3...4:
            cell = tableView.dequeueReusableCell(withIdentifier: "profileSettingsCell", for: indexPath)
            
            let textField:UITextField = cell.viewWithTag(2) as! UITextField
            
            
            switch cellType{
                
            case .firstName:
                textField.text = employee.getFirstName()
            case .lastName:
                textField.text = employee.getSecondName()

            case .email:
                textField.text = employee.getEmail()
            case .phone:
                textField.text = employee.getPhone()
            case .changePassword:
                break
            case .birthday:
                break
            }

            textField.restorationIdentifier = cellType.rawValue.2
            
            let cellLabel:UILabel = cell.viewWithTag(1) as! UILabel
            cellLabel.text = cellType.rawValue.0

            let changeButton:UIButton = cell.viewWithTag(3) as! UIButton
           
            changeButton.isHidden = true
        
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "birthdayCell", for: indexPath)
            
            let cellLabel:UILabel = cell.viewWithTag(1) as! UILabel
            cellLabel.text = cellType.rawValue.0
            
            let cellLabel2:UILabel = cell.viewWithTag(2) as! UILabel
            cellLabel2.text = employee.getBirthday()
            
            let changeButton:UIButton = cell.viewWithTag(3) as! UIButton
            changeButton.isHidden = true


        default:
            break
        }
        
        return cell
        
    }
    
    fileprivate func accessLevelCell(indexPath:IndexPath) ->UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "levelAccessCell", for: indexPath)
        
        let label = cell.viewWithTag(1) as! UILabel
        
        let switchButton = cell.viewWithTag(2) as! UISwitch
        
        
        
        let rule = employee.getAccessLevelRule(index: indexPath.row + 1)
        label.text = employee.getAccessLevelLabel(rule: rule)
        
        switchButton.isOn = employee.getAccessLevel(rule: rule)
        
        switchButton.addAction(UIAction(handler: { _ in
            self.user?.updateAccessLevel(targetId: self.employee.getLocalID() ?? "", accessLevel: rule, value: switchButton.isOn) { isUpdated, error in
                if isUpdated{
                    
                }
                if error != nil{
                    switchButton.isOn = !switchButton.isOn
                }
            }
        }), for: .valueChanged)
        
        
        if !(self.user?.getAccessLevel(rule: .canChangeAccessLevel) ?? false) || !(self.user?.getAccessLevel(rule: rule) ?? false) || self.user?.getLocalID() == employee.getLocalID() || self.employee.getAccessLevel(rule: .isOwner){
            switchButton.isEnabled = false
            switchButton.layer.opacity = 0.5
        }

        
        return cell
        
    }
    
}
