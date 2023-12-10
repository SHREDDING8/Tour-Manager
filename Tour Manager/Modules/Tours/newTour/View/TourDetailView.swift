//
//  TourDetailView.swift
//  Tour Manager
//
//  Created by SHREDDING on 09.12.2023.
//

import UIKit
import SnapKit

@objc protocol TourDetailViewDelegate{
    @objc optional func didSelectDate(date:Date)
    func guideTapped(guideId:String)
}

class TourDetailView: UIView {
    
    var delegate:TourDetailViewDelegate!
    
    var isGuide:Bool = false
    var canWrite:Bool = true
    
    lazy var scrollView:UIScrollView = {
        let scroll = UIScrollView()
        scroll.backgroundColor = .clear
        scroll.showsVerticalScrollIndicator = false
        
        return scroll
    }()
    
    lazy var scrollContent:UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    
    private lazy var generalInfoTitle:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.text = "Общие данные"
        return label
    }()
    
    lazy var generalInfoStack:UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalCentering
        stack.backgroundColor = .clear
        
        stack.spacing = 10
        return stack
    }()
    
    lazy var tourTitle:TitleWithTextFieldTourItem = {
        let view = TitleWithTextFieldTourItem()
        view.title.text = "Название экскурсии"
        view.textField.placeholder = "Не выбрано"
        view.nextPageImage.isHidden = true
        
        view.textField.restorationIdentifier = "tourTitle"
        return view
    }()
    
    lazy var tourRoute:TitleWithTextFieldTourItem = {
        let view = TitleWithTextFieldTourItem()
        view.title.text = "Маршрут"
        view.textField.placeholder = "Не выбрано"
        view.isUserInteractionEnabled = true
        view.textField.isUserInteractionEnabled = false
        return view
    }()
    
    lazy var dateAndTime:TitleWithTextFieldTourItem = {
        let view = TitleWithTextFieldTourItem()
        view.title.text = "Дата и время"
        view.textField.placeholder = self.formatDateToString(Date.now)
        
        view.nextPageImage.isHidden = true
        
        let datePicker = UIDatePicker(frame: .zero)
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .dateAndTime
        view.textField.inputView = datePicker
        view.textField.addDoneCancelToolbar()
        
        datePicker.addAction(UIAction(handler: { _ in
            self.delegate.didSelectDate?(date: datePicker.date)
            view.textField.text = self.formatDateToString(datePicker.date)
        }), for: .valueChanged)
        
        return view
    }()
    
    lazy var tourNumOfPeople:TitleWithTextFieldTourItem = {
        let view = TitleWithTextFieldTourItem()
        view.title.text = "Количество человек"
        view.textField.placeholder = "0"
        
        view.nextPageImage.isHidden = true
        
        view.textField.restorationIdentifier = "tourNumOfPeople"
        return view
    }()
    
    lazy var notesForGuides:TitleWithSwitchTourItem = {
        let view = TitleWithSwitchTourItem()
        view.title.text = "Заметки для гидов"
        return view
    }()
    
    lazy var tourNotes:TitleWithTextFieldTourItem = {
        let view = TitleWithTextFieldTourItem()
        view.title.text = "Заметки"
        
        view.textField.placeholder = "Отсутствуют"
        view.textField.isUserInteractionEnabled = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    
    private lazy var customerInfoTitle:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.text = "Заказчик"
        return label
    }()
    
    lazy var customerInfoStack:UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalCentering
        stack.backgroundColor = .clear
        
        stack.spacing = 10
        
        return stack
    }()
    
    lazy var customerCompanyName:TitleWithTextFieldTourItem = {
        let view = TitleWithTextFieldTourItem()
        view.title.text = "Название компании"
        
        view.textField.placeholder = "Не выбрано"
        view.textField.isUserInteractionEnabled = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var customerGuide:TitleWithTextFieldTourItem = {
        let view = TitleWithTextFieldTourItem()
        view.title.text = "Сопровождающий"
        
        view.textField.placeholder = "Не выбрано"
        view.textField.isUserInteractionEnabled = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var customerGuideContact:TitleWithTextFieldTourItem = {
        let view = TitleWithTextFieldTourItem()
        view.title.text = "Контакт"
        
        view.textField.placeholder = "Не выбрано"
        
        view.nextPageImage.setImage(UIImage(systemName: "phone.fill"), for: .normal)
        view.nextPageImage.addAction(UIAction(handler: { _ in
            let general = GeneralLogic()
            general.callNumber(phoneNumber: view.textField.text ?? "")
        }), for: .touchUpInside)
        view.textField.restorationIdentifier = "customerGuideContact"
        return view
    }()
    
    private lazy var paymentTitle:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.text = "Оплата"
        return label
    }()
    
    lazy var paymentStackView:UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalCentering
        stack.backgroundColor = .clear
        
        stack.spacing = 10
        return stack
    }()
    
    lazy var isPayed:TitleWithSwitchTourItem = {
        let view = TitleWithSwitchTourItem()
        view.title.text = "Оплачено"
        return view
    }()
    
    lazy var paymentMethod:TitleWithTextFieldTourItem = {
        let view = TitleWithTextFieldTourItem()
        view.title.text = "Способ оплаты"
        
        view.textField.placeholder = "Не выбрано"
        view.textField.isUserInteractionEnabled = false
        view.isUserInteractionEnabled = true
        
        return view
    }()
    
    lazy var paymentAmount:TitleWithTextFieldTourItem = {
        let view = TitleWithTextFieldTourItem()
        view.title.text = "Сумма оплаты"
        
        view.textField.placeholder = "0"
        
        view.nextPageImage.isHidden = true
        view.textField.restorationIdentifier = "paymentAmount"
        return view
    }()
    
    
    private lazy var guidesTitle:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.text = "Экскурсоводы"
        return label
    }()
    
    lazy var guidesStack:UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalCentering
        stack.backgroundColor = .clear
        
        stack.spacing = 10
        return stack
    }()
    
    lazy var addGuides:UIView = {
        let view = UIView()
        var title:UILabel = {
            let label = UILabel()

            label.font = .systemFont(ofSize: 18,weight: .bold)
            
            label.text = "Выбрать гидов"
            return label
        }()
        
        var nextPageImage:UIButton = {
            var conf = UIButton.Configuration.plain()
            conf.buttonSize = .mini
            
            let button = UIButton(configuration: conf)
            button.tintColor = .gray
            button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
            return button
        }()
        
        view.addSubview(title)
        view.addSubview(nextPageImage)
        
        nextPageImage.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(50)
        }
        
        title.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview().inset(5)
            make.trailing.equalTo(nextPageImage.snp.leading).inset(5)
        }
        
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var deleteTour:UIButton = {
        let button = UIButton()
        button.setTitle(title: "Удалить экскурсию", size: 16, style: .regular)
        button.setTitleColor(.systemRed, for: .normal)
        return button
    }()
    
    init(isGuide:Bool, canWrite:Bool = true){
        super.init(frame: .zero)
        self.isGuide = isGuide
        self.canWrite = canWrite
        commonInit()
    }
    
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit(){
        
        self.backgroundColor = UIColor(resource: .background)
                
        self.addSubview(scrollView)
        self.scrollView.addSubview(scrollContent)
        
        self.scrollContent.addSubview(generalInfoTitle)
        self.scrollContent.addSubview(generalInfoStack)
        
        self.scrollContent.addSubview(customerInfoTitle)
        self.scrollContent.addSubview(customerInfoStack)
        
        self.scrollContent.addSubview(paymentTitle)
        self.scrollContent.addSubview(paymentStackView)
        
        self.scrollContent.addSubview(guidesTitle)
        self.scrollContent.addSubview(guidesStack)
        
        if !isGuide && canWrite{
            self.scrollContent.addSubview(deleteTour)
        }
        
        configureGeneralStack()
        configureCustomerStack()
        configurePaymentStack()
        configureGuidesStack()
        
        layoutSubviews()
        
        if !canWrite{
            self.tourRoute.nextPageImage.isHidden = true
            self.customerCompanyName.nextPageImage.isHidden = true
            self.customerGuide.nextPageImage.isHidden = true
            self.paymentMethod.nextPageImage.isHidden = true
            
            self.tourTitle.isUserInteractionEnabled = false
            self.tourRoute.isUserInteractionEnabled = false
            self.dateAndTime.isUserInteractionEnabled = false
            self.tourNumOfPeople.isUserInteractionEnabled = false
            self.notesForGuides.isUserInteractionEnabled = false
            
            self.customerCompanyName.isUserInteractionEnabled = false
            self.customerGuide.isUserInteractionEnabled = false
            self.customerGuideContact.textField.isUserInteractionEnabled = false
            
            self.paymentStackView.isUserInteractionEnabled = false
        }
    }
    
    private func configureGeneralStack(){
        generalInfoStack.addArrangedSubview(self.tourTitle)
        generalInfoStack.addArrangedSubview(self.tourRoute)
        generalInfoStack.addArrangedSubview(self.dateAndTime)
        
        generalInfoStack.addArrangedSubview(self.tourNumOfPeople)
        
        if !isGuide{
            generalInfoStack.addArrangedSubview(self.notesForGuides)
        }
        
        generalInfoStack.addArrangedSubview(self.tourNotes)
        
    }
    
    private func configureCustomerStack(){
        if !isGuide{
            customerInfoStack.addArrangedSubview(customerCompanyName)
        }
        
        customerInfoStack.addArrangedSubview(customerGuide)
        customerInfoStack.addArrangedSubview(customerGuideContact)
    }
    
    private func configurePaymentStack(){
        paymentStackView.addArrangedSubview(self.isPayed)
        if !isGuide{
            paymentStackView.addArrangedSubview(self.paymentMethod)
        }
        paymentStackView.addArrangedSubview(self.paymentAmount)
    }
    
    private  func configureGuidesStack(){
        if !isGuide && canWrite{
            guidesStack.addArrangedSubview(addGuides)
        }
        
    }
    
    public func fillGuides(guides:[(guideId:String,guideName:String, guideStatus:UIColor, guideImage:UIImage?, isMain:Bool)]){
        for subview in self.guidesStack.subviews{
            subview.removeFromSuperview()
        }
        
        configureGuidesStack()
    
        for guide in guides {
            let guideView = GuideTourItem()
            guideView.guideId = guide.guideId
            guideView.isUserInteractionEnabled = true
            
            let gesture = UITapGestureRecognizer(target: self, action: #selector(guideTapped(_:)))
            guideView.addGestureRecognizer(gesture)
            
            if guide.guideImage != nil{
                guideView.guidePhoto.image = guide.guideImage
            }
            guideView.guideName.text = (guide.isMain == true ? "★ " : "") +  guide.guideName
            guideView.guideStatus.tintColor = guide.guideStatus
            
            self.guidesStack.addArrangedSubview(guideView)
        }
        
        self.layoutSubviews()
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        scrollContent.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        generalInfoTitle.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
        }
        
        generalInfoStack.snp.makeConstraints { make in
            make.top.equalTo(generalInfoTitle.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        customerInfoTitle.snp.makeConstraints { make in
            make.top.equalTo(generalInfoStack.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        customerInfoStack.snp.makeConstraints { make in
            make.top.equalTo(customerInfoTitle.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        paymentTitle.snp.makeConstraints { make in
            make.top.equalTo(customerInfoStack.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        paymentStackView.snp.makeConstraints { make in
            make.top.equalTo(paymentTitle.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        guidesTitle.snp.makeConstraints { make in
            make.top.equalTo(paymentStackView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        guidesStack.snp.makeConstraints { make in
            make.top.equalTo(guidesTitle.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            if isGuide || !canWrite{
                make.bottom.equalToSuperview().inset(50)
            }
           
        }
        
        if !isGuide && canWrite{
            deleteTour.snp.makeConstraints { make in
                make.top.equalTo(guidesStack.snp.bottom).offset(50)
                make.leading.trailing.equalToSuperview().inset(20)
                make.bottom.equalToSuperview().inset(50)
            }
        }

        
    }
    
    private func formatDateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM в HH:mm"
        dateFormatter.locale = Locale(identifier: "ru_RU") // Установка русской локали для названия месяцев и дней недели

        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
    
    public func setDate(date:Date){
        self.dateAndTime.textField.text = formatDateToString(date)
        (self.dateAndTime.textField.inputView as? UIDatePicker)?.date = date
    }
    
    @objc func guideTapped(_ gesture:UITapGestureRecognizer){
        if let view = gesture.view as? GuideTourItem {
            self.delegate.guideTapped(guideId: view.guideId)
        }
        
    }
}

import SwiftUI
#Preview(body: {
    TourDetailView(isGuide: false).showPreview()
})
