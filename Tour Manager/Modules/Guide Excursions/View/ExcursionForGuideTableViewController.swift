//
//  ExcursionForGuideTableViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 19.06.2023.
//

import UIKit
import EventKit

class ExcursionForGuideTableViewController: UITableViewController, OneGuideExcursionViewProtocol {
    
    var presenter:OneGuideExcursionPresenterProtocol!
        
    let alerts = Alert()
    
    let generalLogic = GeneralLogic()
    
    let controllers = Controllers()
    
    let eventStore : EKEventStore = EKEventStore()
    
    // MARK: - Outlets
    
    @IBOutlet weak var excursionNameLabel: UILabel!
    
    @IBOutlet weak var routeLabel: UILabel!
    
    @IBOutlet weak var numberOfPeopleLabel: UILabel!
    
    @IBOutlet weak var notesLabel:UILabel!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var customerGuideName: UILabel!
    
    @IBOutlet weak var customerGuideContact: UILabel!
    
    @IBOutlet weak var isPaidSwitch: UISwitch!
    
    @IBOutlet weak var paymentAmountLabel: UILabel!
    
    
    @IBOutlet weak var copyCustomerGuidePhone: UIButton!
    
    
    @IBOutlet weak var guidesCollectionView: UICollectionView!
    
    
    var heightConstaint:NSLayoutConstraint!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.tabBarController?.tabBar.backgroundColor = UIColor(named: "background")
        
        self.navigationController?.navigationBar.backgroundColor = UIColor(named: "background")
                
        self.navigationItem.largeTitleDisplayMode = .always
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = presenter.tour.tourTitle
        
        if presenter.tour.dateAndTime > Date.now{
            self.navigationItem.rightBarButtonItems = [
                UIBarButtonItem(image: UIImage(systemName: "star.fill"), style: .plain, target: self, action: #selector(showAcceptAlert))
            ]
            
            let keychain = KeychainService()
            for guide in presenter.tour.guides{
                
                if guide.id == keychain.getLocalId(){
                    self.navigationItem.rightBarButtonItems![0].tintColor = guide.status.getColor()
                    break
                }
            }
        }
        
        configureValues()
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let keychain = KeychainService()
        
        if presenter.tour.dateAndTime > Date.now{
            for guide in presenter.tour.guides{
                if guide.id == keychain.getLocalId() && guide.status == .waiting{
                    self.showAcceptAlert()
                }
            }
        }
    }
    

    @IBAction func copyCustomerGuideNumber(_ sender: UIButton) {
        
        UIPasteboard.general.string = presenter.tour.companyGuidePhone
        
        let alert = UIAlertController(title: "Id компании был скопирован", message: nil, preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(actionOk)
        self.present(alert, animated: true)
    }
    

    // MARK: - configureValues
    
    fileprivate func configureValues(){
        self.excursionNameLabel.text = presenter.tour.tourTitle
        
        // route
        if presenter.tour.route == ""{
            self.routeLabel.text = "Нет"
        }else{
            self.routeLabel.text = presenter.tour.route
        }
        
        self.numberOfPeopleLabel.text = presenter.tour.numberOfPeople
        
        self.datePicker.date = presenter.tour.dateAndTime
        
        self.notesLabel.text = presenter.tour.notes
        
        // customerGuideName
        if presenter.tour.customerGuideName == ""{
            self.customerGuideName.text = "Нет"
        }else{
            self.customerGuideName.text = presenter.tour.customerGuideName
        }
        
        // customerGuideContact
        if presenter.tour.companyGuidePhone == ""{
            self.copyCustomerGuidePhone.layer.opacity = 0
            self.customerGuideContact.text = "Нет"
        }else{
            self.customerGuideContact.text = presenter.tour.companyGuidePhone
        }
       
        self.isPaidSwitch.isOn = presenter.tour.isPaid
        self.paymentAmountLabel.text = presenter.tour.paymentAmount
        
    }
    
    
    @objc private func showAcceptAlert(){
        
        let acceptAlert = UIAlertController(title: "Подтверждение экскурсии", message: "Экскурсия '\(presenter.tour.tourTitle)' \(presenter.tour.dateAndTime.birthdayToString()) в \(presenter.tour.dateAndTime.timeToString())", preferredStyle: .alert)
        
        let acceptAction = UIAlertAction(title: "Принять", style: .default) { _ in
            self.presenter.setGuideTourStatus(tourDate: self.presenter.tour.dateAndTime.birthdayToString(), tourId: self.presenter.tour.tourId , guideStatus: .accepted) { isSetted, error in
                
                if let err = error{
                    self.alerts.errorAlert(self, errorExcursionsApi: err)
                }
                
                if isSetted{
                    
                    self.addReminderToCalendar()
                    let keychain = KeychainService()
                    for guideIndex in 0..<self.presenter.tour.guides.count{
                        
                        if self.presenter.tour.guides[guideIndex].id == keychain.getLocalId(){
                            self.presenter.tour.guides[guideIndex].status = .accept
                            self.navigationItem.rightBarButtonItems![0].tintColor = self.presenter.tour.guides[guideIndex].status.getColor()
                            break
                        }
                    }
                    
                    self.guidesCollectionView.reloadData()
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Отклонить", style: .destructive) { _ in
            self.presenter.setGuideTourStatus(tourDate: self.presenter.tour.dateAndTime.birthdayToString(), tourId: self.presenter.tour.tourId , guideStatus: .cancel) { isSetted, error in
                
                if let err = error{
                    self.alerts.errorAlert(self, errorExcursionsApi: err)
                }
                
                
                if isSetted{
                    
                    let keychain = KeychainService()
                    for guideIndex in 0..<self.presenter.tour.guides.count{
                        
                        if self.presenter.tour.guides[guideIndex].id == keychain.getLocalId(){
                            self.presenter.tour.guides[guideIndex].status = .cancel
                            self.navigationItem.rightBarButtonItems![0].tintColor = self.presenter.tour.guides[guideIndex].status.getColor()
                            break
                        }
                    }
                    
                    self.guidesCollectionView.reloadData()
                    
                }
            }
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
        
//        if #available(iOS 17.0, *) {
//            self.eventStore.requestWriteOnlyAccessToEvents { granted, error in
//                if (granted) && (error == nil) {
//                    
//                    let actionOk = UIAlertAction(title: "Добавить", style: .default){
//                        _ in
//                        self.configureAndSaveCalendarEvent()
//                    }
//                    
//                    DispatchQueue.main.async {
//                        alert.addAction(actionOk)
//                        alert.addAction(actionCancel)
//                        
//                        self.present(alert, animated: true)
//                    }
//                    
//                }
//            }
//        } else {
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
//        }
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
        } catch let error as NSError {
//            print("failed to save event with error : \(error)")
        }
//        print("Saved Event")
        
        
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section{
        case 0: return  presenter.tour.guideCanSeeNotes ? 5 : 4
        case 1: return 2
        case 2: return presenter.tour.isPaid ? 1 : 2
        case 3: return 1
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 && indexPath.row == 1{
            if presenter.tour.companyGuidePhone != ""{
                generalLogic.callNumber(phoneNumber: presenter.tour.companyGuidePhone)
            }
        }else if indexPath.section == 0 && indexPath.row == 4{
            let notesVC = NotesViewController()
            notesVC.isGuide = true
            notesVC.textView.text = self.presenter.tour.notes
            
            self.navigationController?.pushViewController(notesVC, animated: true)
        }
    }

}

extension ExcursionForGuideTableViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.tour.guides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let nib = UINib(nibName: "GuideCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "GuideCollectionViewCell")
                
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GuideCollectionViewCell", for: indexPath) as! GuideCollectionViewCell
        
        let guide = presenter.tour.guides[indexPath.row]
        cell.fullName.text = guide.firstName + " " + guide.lastName
        if guide.isMain{
            cell.isMainGuide.isHidden = false
        }else{
            cell.isMainGuide.isHidden = true
        }
        
        cell.status.tintColor = guide.status.getColor()
        
        self.presenter.downloadProfilePhoto(localId: guide.id, completion: { data, error in
            if data != nil{
                UIView.transition(with: cell.profilePhoto, duration: 0.3, options: .transitionCrossDissolve) {
                    cell.profilePhoto.image = UIImage(data: data!)!
                }
            }
        })
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let guideController = self.controllers.getControllerMain(.employeeViewController) as! EmploeeViewController
                
        self.navigationController?.pushViewController(guideController, animated: true)
        
    }

    
    
}
