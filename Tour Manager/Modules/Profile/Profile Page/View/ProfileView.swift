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
    
    public lazy var profileImagesCollectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.isPagingEnabled = true
        view.contentInsetAdjustmentBehavior = .never
        view.register(ProfilePhotoCollectionViewCell.self, forCellWithReuseIdentifier: "ProfilePhotoCollectionViewCell")
        return view
    }()
        
    lazy var BGimageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        imageView.image = UIImage(resource: .noProfilePhoto)
        
        var blur = UIBlurEffect(style: .regular)
        var blurView = UIVisualEffectView(effect: blur)
                
        imageView.addSubview(blurView)
        
        blurView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        return imageView
    }()
    
    
    lazy var nameView:UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
                        
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
    
    lazy var changePhotoButton:UIButton = {
        var conf = UIButton.Configuration.plain()
        
        conf.buttonSize = .large
        
        let button = UIButton(configuration: conf)
        button.setImage(UIImage(systemName:"camera.fill"), for: .normal)
        button.tintColor = .white
        
        button.layer.shadowOffset = CGSize(width: 1, height: 1)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 5
        
        return button
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
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        
        label.text = "Личные данные"
        return label
    }()
    
    lazy var firstName:ProfileViewElement = {
        let view = ProfileViewElement()
        view.elementLabel.text = "Имя"
        
        view.textField.isUserInteractionEnabled = false
        
        view.button.addAction(UIAction(handler: { _ in
            view.textField.isUserInteractionEnabled = true
            view.textField.becomeFirstResponder()
        }), for: .touchUpInside)
        return view
    }()
    
    lazy var lastName:ProfileViewElement = {
        let view = ProfileViewElement()
        view.elementLabel.text = "Фамилия"
        
        view.textField.isUserInteractionEnabled = false
        
        view.button.addAction(UIAction(handler: { _ in
            view.textField.isUserInteractionEnabled = true
            view.textField.becomeFirstResponder()
        }), for: .touchUpInside)
        
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
        
        datePicker.addAction(UIAction(handler: { _ in
            view.textField.text = datePicker.date.birthdayToString()
        }), for: .valueChanged)
        
        view.button.addAction(UIAction(handler: { _ in
            view.textField.isUserInteractionEnabled = true
            view.textField.becomeFirstResponder()
        }), for: .touchUpInside)
        
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
        view.elementLabel.text = "Телефон"
        view.textField.isUserInteractionEnabled = false
        
        view.textField.keyboardType = .phonePad
        view.textField.addDoneCancelToolbar()
        
        view.button.addAction(UIAction(handler: { _ in
            view.textField.isUserInteractionEnabled = true
            view.textField.becomeFirstResponder()
        }), for: .touchUpInside)
        
        return view
    }()
    
    lazy var extendedSettings:ProfileViewElement = {
        let view = ProfileViewElement()
        view.elementLabel.isHidden = true
        view.textField.text = "Расширенные настройки"
        
        view.textField.isUserInteractionEnabled = false
        
        view.button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var companyStackView:UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .equalCentering
        
        return view
    }()
    lazy var companyInfoLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        
        label.text = "Компания"
        return label
    }()
    
    lazy var companyNameElement:ProfileViewElement = {
        let view = ProfileViewElement()
        view.elementLabel.text = "Название"
        
        view.textField.isUserInteractionEnabled = false
        
        view.button.addAction(UIAction(handler: { _ in
            view.textField.isUserInteractionEnabled = true
            view.textField.becomeFirstResponder()
        }), for: .touchUpInside)
        
        return view
    }()
    
    lazy var companyId:ProfileViewElement = {
        let view = ProfileViewElement()
        view.elementLabel.text = "Индентификатор"
        
        view.textField.isUserInteractionEnabled = false
        view.textField.isSecureTextEntry = true
        view.button.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)

        return view
    }()
    
    lazy var employee:ProfileViewElement = {
        let view = ProfileViewElement()
        view.isUserInteractionEnabled = true
        
        view.elementLabel.isHidden = true
        view.textField.text = "Сотрудники"
        view.textField.isUserInteractionEnabled = false
        
        view.button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        return view
    }()
    
    lazy var logOutButton:UIButton = {
        let button = UIButton()
        button.setTitle("Выйти", for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.systemRed, for: .normal)
        return button
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
        self.profileImagesCollectionView.backgroundView = self.BGimageView
        
        self.addSubview(profileImagesCollectionView)
        
        self.addSubview(nameView)
        self.nameView.addSubview(fullName)
        self.nameView.addSubview(companyName)
                
        self.addSubview(scrollView)
        
        profileImagesCollectionView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(self.snp.width)
        }
        
        nameView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalTo(profileImagesCollectionView)
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
            make.top.equalTo(profileImagesCollectionView.snp.bottom)
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
        scrollContent.addSubview(extendedSettings)
                
        scrollContent.addSubview(logOutButton)
        
        scrollContent.addSubview(companyStackView)
        companyStackView.addArrangedSubview(companyInfoLabel)
        companyStackView.addArrangedSubview(companyNameElement)
        companyStackView.addArrangedSubview(companyId)
        companyStackView.addArrangedSubview(employee)
        
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
        extendedSettings.snp.makeConstraints { make in
            make.top.equalTo(phone.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        companyStackView.snp.makeConstraints { make in
            make.top.equalTo(extendedSettings.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
        }
                
        logOutButton.snp.makeConstraints { make in
            make.top.equalTo(companyStackView.snp.bottom).offset(50)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
    }
    
    
    // MARK: - Configuration Info
    
    public func configureGeneralInfo(fullname:String, companyName:String?){
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
    
    public func configureCompanyInfo(
        companyName:String,
        companyId:String
    ){
        self.companyNameElement.textField.text = companyName
        self.companyId.textField.text = companyId
    }
    
    public func configureVisibleElements(
        isReadLocalIdCompany:Bool,
        isReadGeneralCompanyInformation:Bool,
        isReadCompanyEmployee:Bool,
        isWriteGeneralCompanyInformation:Bool
    ){
        // removeAll
        for subview in companyStackView.subviews{
            subview.removeFromSuperview()
        }
        
        if isReadGeneralCompanyInformation{
            companyStackView.addArrangedSubview(companyInfoLabel)
            companyStackView.addArrangedSubview(companyNameElement)
            
            if isReadLocalIdCompany{
                companyStackView.addArrangedSubview(companyId)
            }
            if isReadCompanyEmployee{
                companyStackView.addArrangedSubview(employee)
            }
            
        }
        
        self.layoutIfNeeded()
        
        // show close companyName editable
        self.companyNameElement.button.isHidden = !isWriteGeneralCompanyInformation
       
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
            newConstraintConstant = max(scrollViewOffset - scrollDiff, -(self.profileImagesCollectionView.frame.height - self.safeAreaLayoutGuide.layoutFrame.minY - 5))
            
        } else if contentMovesDown {
            // Увеличиваем константу констрэйнта
            newConstraintConstant = min(scrollViewOffset - scrollDiff, 0)
            
        }
                
        if newConstraintConstant != scrollViewOffset {
            
            self.scrollView.snp.updateConstraints { make in
                make.top.equalTo(profileImagesCollectionView.snp.bottom).offset(newConstraintConstant)
            }
            
            scrollView.contentOffset.y = previousContentOffsetY
            scrollViewOffset = newConstraintConstant
                        
        }
        
        self.previousContentOffsetY = scrollView.contentOffset.y
        
        let opacity = 1 - (abs(scrollViewOffset) / (self.profileImagesCollectionView.frame.height - self.safeAreaLayoutGuide.layoutFrame.minY - 5))
        
        self.profileImagesCollectionView.layer.opacity = Float(opacity)
    }
    
}

import SwiftUI
#Preview(body: {
    ProfileView().showPreview()
})
