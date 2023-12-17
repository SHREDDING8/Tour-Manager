//
//  TourDetailForGuideViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 10.12.2023.
//

import UIKit
import EventKit
import AlertKit

class TourDetailForGuideViewController: BaseViewController {

    private func view() -> TourDetailView{
        return view as! TourDetailView
    }
    
    var presenter:OneGuideExcursionPresenterProtocol!
    
    let keychain = KeychainService()
    let eventStore : EKEventStore = EKEventStore()
    
    override func loadView() {
        super.loadView()
        self.view = TourDetailView(isGuide: true, canWrite: false)
        self.view().delegate = self
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTargets()
        self.titleString = presenter.tour.tourTitle
        self.setBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fillFields()
    
        if presenter.tour.dateAndTime > Date.now{
            self.navigationItem.rightBarButtonItems = [
                UIBarButtonItem(image: UIImage(systemName: "star.fill"), style: .plain, target: self, action: #selector(showAcceptAlert))
            ]
            
            for guide in presenter.tour.guides{
                
                if guide.id == keychain.getLocalId(){
                    self.navigationItem.rightBarButtonItems![0].tintColor = guide.status.getColor()
                    break
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if presenter.tour.dateAndTime > Date.now{
            for guide in presenter.tour.guides{
                if guide.id == keychain.getLocalId() && guide.status == .waiting{
                    self.showAcceptAlert()
                }
            }
        }
    }
    
    func addTargets(){
        let notesTapGesture = UITapGestureRecognizer(target: self, action: #selector(notesTapped))
        self.view().tourNotes.addGestureRecognizer(notesTapGesture)
        
        let refresh = UIRefreshControl(frame: .zero, primaryAction: UIAction(handler: { _ in
            self.presenter.loadTourFromServer()
        }))
        
        self.view().scrollView.refreshControl = refresh
    }
    
    @objc func notesTapped(){
        let notesVC = NotesViewController()
        
        notesVC.isGuide = true
        
        notesVC.textView.text = self.presenter.tour.notes
        notesVC.doAfterClose = { notes in
            self.presenter.tour.notes = notes
        }
        
        self.navigationController?.pushViewController(notesVC, animated: true)
    }
    
    @objc private func showAcceptAlert(){
        
        let acceptAlert = UIAlertController(title: "Подтверждение экскурсии", message: "Экскурсия '\(presenter.tour.tourTitle)' \(presenter.tour.dateAndTime.birthdayToString()) в \(presenter.tour.dateAndTime.timeToString())", preferredStyle: .alert)
        
        let acceptAction = UIAlertAction(title: "Принять", style: .default) { _ in
            
            self.presenter.setGuideTourStatus(guideStatus: .accepted)
            
        }
        
        let cancelAction = UIAlertAction(title: "Отклонить", style: .destructive) { _ in
            
            self.presenter.setGuideTourStatus(guideStatus: .cancel)
            
        }
        
        let noChoiceAction = UIAlertAction(title: "Отменить", style: .cancel)
        
        let keyChain = KeychainService()
        for guide in presenter.tour.guides{
            
            if guide.id == keyChain.getLocalId(){
                if guide.status == .cancel || guide.status == .waiting{
                    acceptAlert.addAction(acceptAction)
                }
                
                if guide.status == .accept || guide.status == .waiting {
                    acceptAlert.addAction(cancelAction)
                }
                
                acceptAlert.addAction(noChoiceAction)
                break
            }
        }
        
        
        
        self.present(acceptAlert, animated: true)
    }
    
    private func addReminderToCalendar(){
        
        let alert = UIAlertController(title: "Добавить событие в календарь?", message: "Экскурсия '\(presenter.tour.tourTitle)' \(presenter.tour.dateAndTime.birthdayToString()) в \(presenter.tour.dateAndTime.timeToString())", preferredStyle: .alert)
        
        let actionCancel = UIAlertAction(title: "Отменить", style: .cancel)
        
        self.eventStore.requestAccess(to: .event) { granted, error in
            let actionOk = UIAlertAction(title: "Добавить", style: .default){
                _ in
                self.configureAndSaveCalendarEvent()
            }
            
            DispatchQueue.main.async {
                alert.addAction(actionOk)
                alert.addAction(actionCancel)
                
                self.present(alert, animated: true)
            }
        }
    }
    
    private func configureAndSaveCalendarEvent(){
        let event:EKEvent = EKEvent(eventStore: self.eventStore)
        event.title = presenter.tour.tourTitle
        event.startDate = presenter.tour.dateAndTime
        event.endDate = Calendar.current.date(byAdding: .init(minute: 90), to: presenter.tour.dateAndTime)
        
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        let remiderDate = Calendar.current.date(byAdding: .init(minute: -30), to: presenter.tour.dateAndTime)
        event.addAlarm(EKAlarm(absoluteDate: remiderDate ?? presenter.tour.dateAndTime))
        
        do {
            try self.eventStore.save(event, span: .thisEvent)
        } catch _ as NSError {
            
        }
    }
}

extension TourDetailForGuideViewController: OneGuideExcursionViewProtocol{
    func endRefreshing() {
        self.view().scrollView.refreshControl?.endRefreshing()
    }
    
    func refreshSuccess() {
        self.fillFields()
    }
    
    func updateGuideStatus(guideStatus: Status) {
        if guideStatus == .accepted || guideStatus == .cancel{
            AlertKitAPI.present(
                title: "Экскурсия \(guideStatus == .accepted ? "принята" : "отклонена")",
                subtitle: nil,
                icon: guideStatus == .accepted ? .heart : .custom(UIImage(resource: .sadSmile)),
                style: .iOS17AppleMusic,
                haptic: guideStatus == .accepted ? .success : .error
            )
        }
        
        if guideStatus == .accepted{
            self.addReminderToCalendar()
        }
        for guideIndex in 0..<self.presenter.tour.guides.count{
            
            if self.presenter.tour.guides[guideIndex].id == keychain.getLocalId(){
                self.presenter.tour.guides[guideIndex].status = guideStatus == .accepted ? .accept : .cancel
                self.navigationItem.rightBarButtonItems![0].tintColor = self.presenter.tour.guides[guideIndex].status.getColor()
                self.fillGuides()
                break
            }
        }
        
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
        
        self.view().generalInfoStack.subviews.last?.isHidden = !self.presenter.tour.guideCanSeeNotes
        
        self.view().paymentStackView.subviews.last?.isHidden = self.presenter.tour.isPaid
        
        fillGuides()
    }
    
    func fillGuides(){
        
        for guide in presenter.tour.guides{
            
            if guide.id == keychain.getLocalId(){
                self.navigationItem.rightBarButtonItems?[0].tintColor = guide.status.getColor()
                break
            }
        }
        
        self.view().fillGuides(guides: self.presenter.getGuides())
    }
    
    
}

extension TourDetailForGuideViewController:TourDetailViewDelegate{
    func guideTapped(guideId: String) {
        if let user = self.presenter.getUser(by: guideId){
            let employeeVc = EmployeeAseembly.EmployeeDetailController(user: user)
            self.navigationController?.pushViewController(employeeVc, animated: true)
        }
    }
    
    
}
