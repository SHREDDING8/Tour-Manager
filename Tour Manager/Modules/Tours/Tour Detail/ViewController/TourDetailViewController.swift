//
//  TourDetailViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 09.12.2023.
//

import UIKit
import AlertKit

final class TourDetailViewController: BaseViewController {
    
    var presenter:NewExcursionPresenterProtocol!

    private func view() -> TourDetailView{
        return view as! TourDetailView
    }
    
    override func loadView() {
        super.loadView()
        self.view = TourDetailView(isGuide: false,canWrite: presenter.isAccessLevel(key: .canWriteTourList))
        self.view().delegate = self
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addDelegates()
        addTargets()
        
        if self.presenter.tour.tourId.isEmpty{
            self.titleString = "Новая экскурсия"
        }else{
            self.titleString = "Редактирование"
        }
        self.setBackButton()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController()?.interactivePopGestureRecognizer?.delegate = self
                
        
        fillFields()
        
        if presenter.isAccessLevel(key: .canWriteTourList){
            self.navigationItem.rightBarButtonItem =  UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonClick))
        }
    }
    
    func addDelegates(){
        self.view().tourTitle.textField.delegate = self
        self.view().tourNumOfPeople.textField.delegate = self
        self.view().customerGuideContact.textField.delegate = self
        
        self.view().paymentAmount.textField.delegate = self
    }
    
    func addTargets(){
        let routeTapGesture = UITapGestureRecognizer(target: self, action: #selector(routeTapped))
        self.view().tourRoute.addGestureRecognizer(routeTapGesture)
        
        let notesTapGesture = UITapGestureRecognizer(target: self, action: #selector(notesTapped))
        self.view().tourNotes.addGestureRecognizer(notesTapGesture)
        
        let customerCompanyNameTapGesture = UITapGestureRecognizer(target: self, action: #selector(customerCompanyNameTapped))
        self.view().customerCompanyName.addGestureRecognizer(customerCompanyNameTapGesture)
        
        let customerGuideTapGesture = UITapGestureRecognizer(target: self, action: #selector(customerGuideTapped))
        self.view().customerGuide.addGestureRecognizer(customerGuideTapGesture)
        
        let paymentMethodTapGesture = UITapGestureRecognizer(target: self, action: #selector(paymentMethodTapped))
        self.view().paymentMethod.addGestureRecognizer(paymentMethodTapGesture)
        
        let addGuidesTapGesture = UITapGestureRecognizer(target: self, action: #selector(addGuidesTapped))
        self.view().addGuides.addGestureRecognizer(addGuidesTapGesture)
        
        
        self.view().notesForGuides.switchControll.addTarget(self, action: #selector(notesForGuidesChanged), for: .valueChanged)
        
        self.view().isPayed.switchControll.addTarget(self, action: #selector(isPaidChanged), for: .valueChanged)
        self.view().deleteTour.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dateTapped))
        self.view().dateAndTime.isUserInteractionEnabled = true
        self.view().dateAndTime.addGestureRecognizer(gesture)
        
        if !presenter.tour.tourId.isEmpty{
            let refresh = UIRefreshControl(frame: .zero, primaryAction: UIAction(handler: { _ in
                self.presenter.loadTourFromServer()
            }))
            
            self.view().scrollView.refreshControl = refresh
        }
    }
    
    @objc func dateTapped(){
        let vc = TourManadmentAssembly.createTourDetailDatePicker(date: self.presenter.tour.dateAndTime) { date in
            self.presenter.tour.dateAndTime = date
            self.view().dateAndTime.textField.text = self.formatDateToString(date)
        }
        self.present(vc, animated: true)
    }
    private func formatDateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM в HH:mm"
        dateFormatter.locale = Locale(identifier: "ru_RU") // Установка русской локали для названия месяцев и дней недели

        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
    
    @objc func routeTapped(){
        let newComponentVC = TourManadmentAssembly.createAutoFillComponentsController(type: .route, baseValue: self.presenter.tour.route) as! AddingNewComponentViewController
        
        newComponentVC.doAfterClose = { value in
            self.presenter.tour.route = value
            self.view().tourRoute.textField.text = value
        }
        
        self.navigationController?.pushViewController(newComponentVC, animated: true)
    }
    
    @objc func notesTapped(){
        let notesVC = NotesViewController()
        
        if !self.presenter.isAccessLevel(key: .canWriteTourList){
            notesVC.isGuide = true
        }
        
        notesVC.textView.text = self.presenter.tour.notes
        notesVC.doAfterClose = { notes in
            self.presenter.tour.notes = notes
        }
        
        self.navigationController?.pushViewController(notesVC, animated: true)
    }
    
    @objc func customerCompanyNameTapped(){
        let newComponentVC = TourManadmentAssembly.createAutoFillComponentsController(type: .customerCompanyName, baseValue: self.presenter.tour.customerCompanyName) as! AddingNewComponentViewController
        
        newComponentVC.doAfterClose = { value in
            self.presenter.tour.customerCompanyName = value
        }

        self.navigationController?.pushViewController(newComponentVC, animated: true)
    }
    
    @objc func customerGuideTapped(){
        let newComponentVC = TourManadmentAssembly.createAutoFillComponentsController(type: .customerGuiedName, baseValue: self.presenter.tour.customerGuideName) as! AddingNewComponentViewController
        
        newComponentVC.doAfterClose = { value in
            self.presenter.tour.customerGuideName = value
        }

        self.navigationController?.pushViewController(newComponentVC, animated: true)
    }
    
    @objc func paymentMethodTapped(){
        let newComponentVC = TourManadmentAssembly.createAutoFillComponentsController(type: .excursionPaymentMethod, baseValue: self.presenter.tour.paymentMethod) as! AddingNewComponentViewController
        
        newComponentVC.doAfterClose = { value in
            self.presenter.tour.paymentMethod = value
        }
        
        self.navigationController?.pushViewController(newComponentVC, animated: true)
    }
    
    @objc func notesForGuidesChanged(){
        self.presenter.tour.guideCanSeeNotes = self.view().notesForGuides.switchControll.isOn
    }
    
    @objc func isPaidChanged(){
        self.presenter.tour.isPaid = self.view().isPayed.switchControll.isOn
    }
    
    @objc func addGuidesTapped(){
        let selectGuidesVC = TourManadmentAssembly.createAddGuideController(selectedGuides: self.presenter.tour.guides) as! AddGuideViewController
        
        selectGuidesVC.doAfterClose = {guides in
            self.presenter.tour.guides = guides
        }

        self.navigationController?.pushViewController(selectGuidesVC, animated: true)
    }
    
    @objc func deleteTapped(){
        let alert = UIAlertController(title: "Вы уверены что вы хотите удалить экскурсию?", message: nil, preferredStyle: .actionSheet)
        
        let delete = UIAlertAction(title: "Удалить", style: .destructive) { _ in
            self.presenter.deleteTour()
        }
        
        let cancel = UIAlertAction(title: "Отменить", style: .cancel)
        alert.addAction(delete)
        alert.addAction(cancel)
        self.present(alert, animated: true)
    }
        
    @objc fileprivate func saveButtonClick(){        
        presenter.saveButtonClick()
    }
    
}
extension TourDetailViewController:NewExcursionViewProtocol{
    func endRefreshing() {
        self.view().scrollView.refreshControl?.endRefreshing()
    }
    
    func deleteSuccessful() {
        AlertKitAPI.present(
            title: "Экскурсия удалена",
            subtitle: nil,
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
        self.navigationController?.popViewController(animated: true)
    }
    
    func addedSuccessful() {
        AlertKitAPI.present(
            title: "Экскурсия добавлена",
            subtitle: nil,
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
        self.navigationController?.popViewController(animated: true)
    }
    
    func updatedSuccessful() {
        AlertKitAPI.present(
            title: "Экскурсия обновлена",
            subtitle: nil,
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
        self.navigationController?.popViewController(animated: true)
    }
    
    func refreshSuccess() {
        self.fillFields()
    }
    
    func validationError(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(ok)
        
        self.present(alert, animated: true)
    }
        
    func fillFields(){
        self.view().tourTitle.textField.text = self.presenter.tour.tourTitle
        
        self.view().tourRoute.textField.text = self.presenter.tour.route
        
        self.view().tourNotes.textField.text = self.presenter.tour.notes
        
        self.view().notesForGuides.switchControll.isOn = self.presenter.tour.guideCanSeeNotes
        
        self.view().tourNumOfPeople.textField.text = self.presenter.tour.numberOfPeople == "0" ? "" : self.presenter.tour.numberOfPeople
        
        self.view().customerCompanyName.textField.text = self.presenter.tour.customerCompanyName
        
        self.view().customerGuide.textField.text = self.presenter.tour.customerGuideName
        
        self.view().customerGuideContact.textField.text = self.presenter.tour.companyGuidePhone
        
        self.view().isPayed.switchControll.isOn = self.presenter.tour.isPaid
        self.view().paymentMethod.textField.text = self.presenter.tour.paymentMethod
        
        self.view().paymentAmount.textField.text = self.presenter.tour.paymentAmount == "0" ? "" : self.presenter.tour.paymentAmount
        
        self.view().setDate(date: self.presenter.tour.dateAndTime)
        
        if self.presenter.tour.tourId.isEmpty{
            self.view().deleteTour.isHidden = true
        }
        
        fillGuides()
    }
    
    func fillGuides(){
        
        self.view().fillGuides(guides: self.presenter.getGuides())
    }
    
    
}

extension TourDetailViewController: TourDetailViewDelegate{
    func guideTapped(guideId: String) {
        if let user = self.presenter.getUser(by: guideId){
            let employeeVc = EmployeeAseembly.EmployeeDetailController(user: user)
            self.navigationController?.pushViewController(employeeVc, animated: true)
        }
        
    }
    
    
    func didSelectDate(date: Date) {
        self.presenter.tour.dateAndTime = date
    }
    
}

extension TourDetailViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.restorationIdentifier == "tourTitle"{
            self.presenter.tour.tourTitle = textField.text ?? ""
            
        }else if textField.restorationIdentifier == "tourNumOfPeople"{
            
            let newNumberOfPeople = (textField.text ?? "0").replacingOccurrences(of: " ", with: "")
                        
            self.presenter.tour.numberOfPeople = newNumberOfPeople
            textField.text = newNumberOfPeople
            
        }else if textField.restorationIdentifier == "paymentAmount"{
            
            
            let newAmount = (textField.text ?? "0").replacingOccurrences(of: " ", with: "")
            
            self.presenter.tour.paymentAmount = newAmount
            textField.text = newAmount
            
        }else if textField.restorationIdentifier == "customerGuideContact"{
            
            self.presenter.tour.companyGuidePhone = textField.text ?? ""
            
        }
    }
}

extension TourDetailViewController{
    
    fileprivate func warningAlertDuringExit(){
        
        let alert = UIAlertController(title: "Возможно у вас есть несохраненные данные", message: "Вы уверены что хотите выйти?", preferredStyle: .alert)
        let exit = UIAlertAction(title: "Выйти", style: .destructive) { _ in
            self.navigationController()?.popViewController(animated: true)
        }
        
        let cancel = UIAlertAction(title: "Отменить", style: .cancel)
        
        alert.addAction(exit)
        alert.addAction(cancel)
        
        self.present(alert, animated: true)
        
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if self.navigationController()?.visibleViewController == self{
            if !self.presenter.isEqualTours(){
                warningAlertDuringExit()
                return false
            }
            
        }
        
        return true
    }
    
    override func popView() {
        if self.navigationController?.visibleViewController == self{
            
            if !self.presenter.isEqualTours(){
                self.warningAlertDuringExit()
                return
            }
            
        }
        
        self.navigationController()?.popViewController(animated: true)
    }
    
}
