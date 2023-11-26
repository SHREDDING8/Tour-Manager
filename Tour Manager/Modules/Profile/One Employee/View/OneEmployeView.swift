//
//  OneEmployeView.swift
//  Tour Manager
//
//  Created by SHREDDING on 14.10.2023.
//

import Foundation

import UIKit
import SnapKit

class OneEmployeView: UIView {
    var firstLoad = true
    var employeeIsOwner = false
    
    lazy var profileImage:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        imageView.image = UIImage(resource: .noProfilePhoto)
        
        return imageView
    }()
    
    lazy var nameView:UIView = {
        let view = UIView()
        
        return view
    }()
    
    lazy var fullName:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 0
        
        label.layer.shadowOffset = CGSize(width: 1, height: 1)
        label.layer.shadowOpacity = 0.5
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 5
        
        return label
    }()
    
    lazy var companyName:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 0
        
        label.layer.shadowOffset = CGSize(width: 1, height: 1)
        label.layer.shadowOpacity = 0.5
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 5
        
        return label
    }()
    
    // MARK: - Scroll
    var previousContentOffsetY:CGFloat = 0
    lazy var scrollView:UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = UIColor(resource: .background)
        
        view.layer.cornerRadius = 20
        
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        view.delegate = self
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        
        
        return view
    }()
    
    var scrollViewOffset:CGFloat = 0
    
    lazy var scrollContent:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(resource: .background)
        return view
    }()
    
    lazy var userInfoLabel:UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        
        label.text = "Личные данные"
        return label
    }()
    
    lazy var firstName:ProfileViewElement = {
        let view = ProfileViewElement()
        view.elementLabel.text = "Имя"
        
        view.textField.isUserInteractionEnabled = false
        
        view.button.isHidden = true
        return view
    }()
    
    lazy var lastName:ProfileViewElement = {
        let view = ProfileViewElement()
        view.elementLabel.text = "Фамилия"
        
        view.textField.isUserInteractionEnabled = false
        
        view.button.isHidden = true
        
        return view
    }()
    
    lazy var birthday:ProfileViewElement = {
        let view = ProfileViewElement()
        view.elementLabel.text = "Дата рождения"
        view.textField.isUserInteractionEnabled = false
        
        let datePicker = UIDatePicker(frame: .zero)
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        view.textField.inputView = datePicker
        view.textField.addDoneCancelToolbar()
        
        view.button.isHidden = true
        
        return view
    }()
    
    lazy var email:ProfileViewElement = {
        let view = ProfileViewElement()
        view.elementLabel.text = "Email"
        view.textField.isUserInteractionEnabled = false
        view.button.isHidden = true
        
        return view
    }()
    
    lazy var phone:ProfileViewElement = {
        let view = ProfileViewElement()
        view.isUserInteractionEnabled = true
        
        view.elementLabel.text = "Телефон"
        view.textField.isUserInteractionEnabled = false
        
        view.textField.keyboardType = .phonePad
        view.textField.addDoneCancelToolbar()
        
        view.button.isUserInteractionEnabled = false
        view.button.setImage(UIImage(systemName: "phone.fill"), for: .normal)
        
        return view
    }()
    
    lazy var userAcessLevelLabel:UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        
        label.text = "Права доступа"
        return label
    }()
    
    lazy var userAccessLevelStack:UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 10
        
        return stack
    }()
    
    lazy var readGeneralInformation:AccessLevelElement = {
        let element = AccessLevelElement()
        element.title.text = "Чтение общей информации"
        element.switchControll.restorationIdentifier = "ReadGeneral"
        return element
    }()
    
    lazy var writeGeneralInformation:AccessLevelElement = {
        let element = AccessLevelElement()
        element.title.text = "Изменение общей информации"
        element.switchControll.restorationIdentifier = "WriteGeneral"
        return element
    }()
    
    lazy var readCompanyId:AccessLevelElement = {
        let element = AccessLevelElement()
        element.title.text = "Чтение идентификатора"
        element.switchControll.restorationIdentifier = "ReadId"
        return element
    }()
    
    lazy var readEmployee:AccessLevelElement = {
        let element = AccessLevelElement()
        element.title.text = "Просмотр сотрудников"
        element.switchControll.restorationIdentifier = "SeeEmployee"
        return element
    }()
    
    lazy var changeAccessLevel:AccessLevelElement = {
        let element = AccessLevelElement()
        element.title.text = "Изменение прав доступа"
        element.switchControll.restorationIdentifier = "ChangeAccessLevels"
        return element
    }()
    
    lazy var readTours:AccessLevelElement = {
        let element = AccessLevelElement()
        element.title.text = "Чтение экскурсий"
        element.switchControll.restorationIdentifier = "ReadTours"
        return element
    }()
    
    lazy var writeTours:AccessLevelElement = {
        let element = AccessLevelElement()
        element.title.text = "Изменение экскурсий"
        element.switchControll.restorationIdentifier = "WriteTours"
        return element
    }()
    
    lazy var isGuide:AccessLevelElement = {
        let element = AccessLevelElement()
        element.title.text = "Экскурсовод"
        element.switchControll.restorationIdentifier = "IsGuide"
        return element
    }()
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.backgroundColor = UIColor(resource: .background)
        self.addSubview(profileImage)
        self.profileImage.addSubview(nameView)
        self.nameView.addSubview(fullName)
        self.nameView.addSubview(companyName)
        
        self.addSubview(scrollView)
        
        profileImage.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(self.snp.width)
        }
        
        nameView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
        }
        
        fullName.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(20)
        }
        
        companyName.snp.makeConstraints { make in
            make.top.equalTo(fullName.snp.bottom).offset(5)
            make.leading.trailing.bottom.equalToSuperview().inset(20)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(profileImage.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
        }
        
        configureScrollView()
    }
    
    private func configureScrollView(){
        scrollView.addSubview(scrollContent)
        
        scrollContent.addSubview(userInfoLabel)
        scrollContent.addSubview(firstName)
        scrollContent.addSubview(lastName)
        scrollContent.addSubview(birthday)
        scrollContent.addSubview(email)
        scrollContent.addSubview(phone)
        scrollContent.addSubview(userAccessLevelStack)
        
        scrollContent.addSubview(userAcessLevelLabel)
        userAccessLevelStack.addArrangedSubview(readGeneralInformation)
        userAccessLevelStack.addArrangedSubview(writeGeneralInformation)
        userAccessLevelStack.addArrangedSubview(readCompanyId)
        userAccessLevelStack.addArrangedSubview(readEmployee)
        userAccessLevelStack.addArrangedSubview(changeAccessLevel)
        userAccessLevelStack.addArrangedSubview(readTours)
        userAccessLevelStack.addArrangedSubview(writeTours)
        userAccessLevelStack.addArrangedSubview(isGuide)
        
        scrollContent.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
            
            make.width.equalToSuperview()
        }
        
        userInfoLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
        }
        
        firstName.snp.makeConstraints { make in
            make.top.equalTo(userInfoLabel.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        lastName.snp.makeConstraints { make in
            make.top.equalTo(firstName.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        birthday.snp.makeConstraints { make in
            make.top.equalTo(lastName.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        email.snp.makeConstraints { make in
            make.top.equalTo(birthday.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        phone.snp.makeConstraints { make in
            make.top.equalTo(email.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        userAcessLevelLabel.snp.makeConstraints { make in
            make.top.equalTo(phone.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        userAccessLevelStack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(userAcessLevelLabel.snp.bottom).offset(20)
            make.bottom.equalToSuperview().inset(20)
        }
    }
        
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if firstLoad{
            // Создайте градиентный слой
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = nameView.bounds
            gradientLayer.colors = [UIColor.clear.cgColor, UIColor(resource: .black40).cgColor]
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)

            // Добавьте градиентный слой в слои вашего view
            nameView.layer.insertSublayer(gradientLayer, at: 0)
            firstLoad = false
        }

    }
    
    func configureAccessLevels(
        isReadGeneralCompanyInformation:Bool,
        isWriteGeneralCompanyInformation:Bool,
        isReadLocalIdCompany:Bool,
        isReadCompanyEmployee:Bool,
        isChangeAccessLevels:Bool,
        isReadTours:Bool,
        isWriteTour:Bool,
        isGuide:Bool,
        isOwner:Bool
    ){
        self.readGeneralInformation.switchControll.setOn(isReadGeneralCompanyInformation, animated: true)
        self.writeGeneralInformation.switchControll.setOn(isWriteGeneralCompanyInformation, animated: true)
        self.readCompanyId.switchControll.setOn(isReadLocalIdCompany, animated: true)
        self.readEmployee.switchControll.setOn(isReadCompanyEmployee, animated: true)
        self.changeAccessLevel.switchControll.setOn(isChangeAccessLevels, animated: true)
        self.readTours.switchControll.setOn(isReadTours, animated: true)
        self.writeTours.switchControll.setOn(isWriteTour, animated: true)
        self.isGuide.switchControll.setOn(isGuide, animated: true)
        
        self.employeeIsOwner = isOwner
    }
    
    func configureIsChangingAccessLevels(
        isReadGeneralCompanyInformation:Bool,
        isWriteGeneralCompanyInformation:Bool,
        isReadLocalIdCompany:Bool,
        isReadCompanyEmployee:Bool,
        isChangeAccessLevels:Bool,
        isReadTours:Bool,
        isWriteTour:Bool,
        isGuide:Bool,
        isOwner:Bool
    ){
        if self.employeeIsOwner && isOwner{
            for subView in userAccessLevelStack.arrangedSubviews{
                (subView as! AccessLevelElement).switchControll.isUserInteractionEnabled = false
            }
            
            self.isGuide.switchControll.isUserInteractionEnabled = true
            
            return
        }
        
        if self.employeeIsOwner{
            for subView in userAccessLevelStack.arrangedSubviews{
                (subView as! AccessLevelElement).switchControll.isUserInteractionEnabled = false
            }
            
            return
        }
        
        if !isChangeAccessLevels{
            for subView in userAccessLevelStack.subviews{
                subView.removeFromSuperview()
            }
            
            self.userAcessLevelLabel.isHidden = true
            
            userAccessLevelStack.snp.remakeConstraints{ make in
                make.leading.trailing.equalToSuperview().inset(20)
                make.top.equalTo(userAcessLevelLabel.snp.bottom).offset(20)
                make.bottom.equalToSuperview().inset(20)
            }
            
        }
                
    }
    
    func configureInfo(
        companyName:String,
        name:String,
        lastName:String,
        birthday:String,
        email:String,
        phone:String
    ){
        self.fullName.text = "\(name) \(lastName)"
        self.companyName.text = companyName
        self.firstName.textField.text = name
        self.lastName.textField.text = lastName
        self.birthday.textField.text = birthday
        self.email.textField.text = email
        self.phone.textField.text = phone
        
    }
    func setPhoto(image:UIImage?){
        if image != nil{
            self.profileImage.image = image
        }else{
            self.profileImage.image = UIImage(resource: .noProfilePhoto)
        }
        
    }
    
}

extension OneEmployeView: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentContentOffsetY = scrollView.contentOffset.y
        let scrollDiff = currentContentOffsetY - self.previousContentOffsetY
        
        let bounceBorderContentOffsetY = -scrollView.contentInset.top
        
        
        let contentMovesUp = scrollDiff > 0 && currentContentOffsetY > bounceBorderContentOffsetY
                
        let contentMovesDown = scrollDiff < 0 && currentContentOffsetY < bounceBorderContentOffsetY
        
        
        var newConstraintConstant = scrollViewOffset
        
        if contentMovesUp {
            // Уменьшаем константу констрэйнта
            newConstraintConstant = max(scrollViewOffset - scrollDiff, -(self.profileImage.frame.height - self.safeAreaLayoutGuide.layoutFrame.minY - 5))
            
        } else if contentMovesDown {
            // Увеличиваем константу констрэйнта
            newConstraintConstant = min(scrollViewOffset - scrollDiff, 0)
            
        }
                
        if newConstraintConstant != scrollViewOffset {
            
            self.scrollView.snp.updateConstraints { make in
                make.top.equalTo(profileImage.snp.bottom).offset(newConstraintConstant)
            }
            
            scrollView.contentOffset.y = previousContentOffsetY
            scrollViewOffset = newConstraintConstant
                        
        }
        
        self.previousContentOffsetY = scrollView.contentOffset.y
        
        let opacity = 1 - (abs(scrollViewOffset) / (self.profileImage.frame.height - self.safeAreaLayoutGuide.layoutFrame.minY - 5))
        
        self.profileImage.layer.opacity = Float(opacity)
    }
    
}

#if DEBUG
import SwiftUI

#Preview(body: {
    OneEmployeView().showPreview()
})
#endif
