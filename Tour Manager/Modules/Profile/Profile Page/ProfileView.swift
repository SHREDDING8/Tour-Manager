//
//  ProfileView.swift
//  Tour Manager
//
//  Created by SHREDDING on 10.11.2023.
//

import UIKit
import SnapKit

class ProfileView: UIView {
    
    var firstLoad = true
    
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
    
    
    // MARK: - scroll
    
    var previousContentOffsetY:CGFloat = 0
    lazy var scrollView:UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = UIColor(resource: .background)
        
        view.layer.cornerRadius = 20
        
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        view.delegate = self
        view.alwaysBounceVertical = true
        
        
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
        return view
    }()
    
    lazy var lastName:ProfileViewElement = {
        let view = ProfileViewElement()
        view.elementLabel.text = "Фамилия"
        return view
    }()
    
    lazy var birthday:ProfileViewElement = {
        let view = ProfileViewElement()
        view.elementLabel.text = "Дата рождения"
        return view
    }()
    
    lazy var email:ProfileViewElement = {
        let view = ProfileViewElement()
        view.elementLabel.text = "Email"
        return view
    }()
    
    lazy var phone:ProfileViewElement = {
        let view = ProfileViewElement()
        view.elementLabel.text = "Телефон"
        return view
    }()
    
    lazy var changePassword:ProfileViewElement = {
        let view = ProfileViewElement()
        view.elementLabel.isHidden = true
        view.textField.text = "Изменить пароль"
        view.button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        return view
    }()
    
    
    lazy var companyInfoLabel:UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        
        label.text = "Компания"
        return label
    }()
    
    lazy var companyNameElement:ProfileViewElement = {
        let view = ProfileViewElement()
        view.elementLabel.text = "Название"
        return view
    }()
    
    lazy var companyId:ProfileViewElement = {
        let view = ProfileViewElement()
        view.elementLabel.text = "Индентификатор"
        return view
    }()
    
    lazy var employee:ProfileViewElement = {
        let view = ProfileViewElement()
        view.elementLabel.isHidden = true
        view.textField.text = "Сотрудники"
        view.button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        return view
    }()
        
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    
    func commonInit(){
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
    
    func configureScrollView(){
        scrollView.addSubview(scrollContent)
        
        scrollContent.addSubview(userInfoLabel)
        scrollContent.addSubview(firstName)
        scrollContent.addSubview(lastName)
        scrollContent.addSubview(birthday)
        scrollContent.addSubview(email)
        scrollContent.addSubview(phone)
        scrollContent.addSubview(changePassword)
        
        scrollContent.addSubview(companyInfoLabel)
        scrollContent.addSubview(companyNameElement)
        scrollContent.addSubview(companyId)
        scrollContent.addSubview(employee)
        
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
        changePassword.snp.makeConstraints { make in
            make.top.equalTo(phone.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        companyInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(changePassword.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        companyNameElement.snp.makeConstraints { make in
            make.top.equalTo(companyInfoLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        companyId.snp.makeConstraints { make in
            make.top.equalTo(companyNameElement.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        employee.snp.makeConstraints { make in
            make.top.equalTo(companyId.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
    }
    
    
    // MARK: - Configuration Info
    
    public func configureGeneralInfo(userImage:UIImage?, fullname:String, companyName:String?){
        self.profileImage.image = userImage != nil ? userImage : UIImage(resource: .noProfilePhoto)
        self.fullName.text = fullname
        self.companyName.text = companyName
    }
    
    public func configurePersonalInfo(
        name:String,
        lastName:String,
        birhday:String,
        email:String,
        phone:String
    ){
        self.firstName.textField.text = name
        self.lastName.textField.text = lastName
        self.birthday.textField.text = birhday
        self.email.textField.text = email
        self.phone.textField.text = phone
    }
    
}

extension ProfileView: UIScrollViewDelegate{
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

import SwiftUI
#Preview(body: {
    ProfileView().showPreview()
})
