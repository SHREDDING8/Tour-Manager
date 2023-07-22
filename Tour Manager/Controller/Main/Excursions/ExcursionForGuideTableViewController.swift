//
//  ExcursionForGuideTableViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 19.06.2023.
//

import UIKit
import EventKit

class ExcursionForGuideTableViewController: UITableViewController {
    
    var excursion = Excursion()
    
    let alerts = Alert()
    
    let excursionModel = ExcursionsControllerModel()
    
    let user = AppDelegate.user
    
    let generalLogic = GeneralLogic()
    
    let controllers = Controllers()
    
    let eventStore : EKEventStore = EKEventStore()
    
    
    let localNotifications = LocalNotifications()
    
    // MARK: - Outlets
    
    @IBOutlet weak var excursionNameLabel: UILabel!
    
    @IBOutlet weak var routeLabel: UILabel!
    
    @IBOutlet weak var numberOfPeopleLabel: UILabel!
    
    @IBOutlet weak var notesTextView: UITextView!
    
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
        
        configureValues()
        
        self.tabBarController?.tabBar.backgroundColor = UIColor(resource: .background)
        
        self.navigationItem.title = excursion.excursionName
        self.navigationController?.navigationBar.backgroundColor = UIColor(resource: .background)
        
        if self.excursion.dateAndTime > Date.now{
            self.navigationItem.rightBarButtonItems = [
                UIBarButtonItem(image: UIImage(systemName: "star.fill"), style: .plain, target: self, action: #selector(showAcceptAlert))
            ]
        
            for guide in self.excursion.selfGuides{
                
                if guide.guideInfo == self.user{
                    self.navigationItem.rightBarButtonItems![0].tintColor = guide.statusColor
                    break
                }
            }
        }
        
        self.navigationItem.largeTitleDisplayMode = .always
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.excursion.dateAndTime > Date.now{
            for guide in excursion.selfGuides{
                if guide.guideInfo == self.user && guide.status == .waiting{
                    self.showAcceptAlert()
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.animate(withDuration: 0.3) {
            self.tabBarController?.tabBar.layer.opacity = 1
        }
    }
    
    
    @IBAction func copyCustomerGuideNumber(_ sender: UIButton) {
        
            UIPasteboard.general.string = self.excursion.companyGuidePhone
            
            let alert = UIAlertController(title: "Id компании был скопирован", message: nil, preferredStyle: .alert)
            let actionOk = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(actionOk)
            self.present(alert, animated: true)
    }
    

    // MARK: - configureValues
    
    fileprivate func configureValues(){
        self.excursionNameLabel.text = excursion.excursionName
        
        // route
        if self.excursion.route == ""{
            self.routeLabel.text = "Нет"
        }else{
            self.routeLabel.text = excursion.route
        }
        
        self.numberOfPeopleLabel.text = String(excursion.numberOfPeople)
        
        self.datePicker.date = excursion.dateAndTime
        
        self.notesTextView.text = excursion.additionalInfromation
        
       
        
        // customerGuideName
        if self.excursion.customerGuideName == ""{
            self.customerGuideName.text = "Нет"
        }else{
            self.customerGuideName.text = excursion.customerGuideName
        }
        
        // customerGuideContact
        if self.excursion.companyGuidePhone == ""{
            self.copyCustomerGuidePhone.layer.opacity = 0
            self.customerGuideContact.text = "Нет"
        }else{
            self.customerGuideContact.text = excursion.companyGuidePhone
        }
       
        self.isPaidSwitch.isOn = excursion.isPaid
        self.paymentAmountLabel.text = String(excursion.paymentAmount)
        
        
        
    }
    
    
    @objc private func showAcceptAlert(){
        
        let acceptAlert = UIAlertController(title: "Подтверждение экскурсии", message: "Экскурсия '\(self.excursion.excursionName)' \(self.excursion.dateAndTime.birthdayToString()) в \(self.excursion.dateAndTime.timeToString())", preferredStyle: .alert)
        
        let acceptAction = UIAlertAction(title: "Принять", style: .default) { _ in
            self.excursionModel.setGuideTourStatus(token: self.user?.getToken() ?? "", uid: self.user?.getToken() ?? "", companyId: self.user?.company.getLocalIDCompany() ?? "" , tourDate: self.excursion.dateAndTime.birthdayToString(), tourId: self.excursion.localId ?? "", guideStatus: .accepted) { isSetted, error in
                
                if let err = error{
                    self.alerts.errorAlert(self, errorExcursionsApi: err)
                }
                
                if isSetted{
                    
                    self.addReminderToCalendar()
                    
                    for guideIndex in 0..<self.excursion.selfGuides.count{
                        
                        if self.excursion.selfGuides[guideIndex].guideInfo == self.user{
                            self.excursion.selfGuides[guideIndex].status = .accepted
                            self.navigationItem.rightBarButtonItems![0].tintColor = self.excursion.selfGuides[guideIndex].statusColor
                            break
                        }
                    }
                    
                    self.guidesCollectionView.reloadData()
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Отклонить", style: .destructive) { _ in
            self.excursionModel.setGuideTourStatus(token: self.user?.getToken() ?? "", uid: self.user?.getToken() ?? "", companyId: self.user?.company.getLocalIDCompany() ?? "" , tourDate: self.excursion.dateAndTime.birthdayToString(), tourId: self.excursion.localId ?? "", guideStatus: .cancel) { isSetted, error in
                
                if let err = error{
                    self.alerts.errorAlert(self, errorExcursionsApi: err)
                }
                
                
                if isSetted{
                    
                    for guideIndex in 0..<self.excursion.selfGuides.count{
                        
                        if self.excursion.selfGuides[guideIndex].guideInfo == self.user{
                            self.excursion.selfGuides[guideIndex].status = .cancel
                            self.navigationItem.rightBarButtonItems![0].tintColor = self.excursion.selfGuides[guideIndex].statusColor
                            break
                        }
                    }
                    
                    self.guidesCollectionView.reloadData()
                    
                }
            }
        }
        
        
        
        
        let noChoiceAction = UIAlertAction(title: "Отменить", style: .cancel)
        
        for guide in self.excursion.selfGuides{
            
            if guide.guideInfo == self.user{
                if guide.status == .cancel || guide.status == .waiting{
                    acceptAlert.addAction(acceptAction)
                }
                
                if guide.status == .accepted || guide.status == .waiting {
                    acceptAlert.addAction(cancelAction)
                }
                
                acceptAlert.addAction(noChoiceAction)
                break
            }
        }
        
        
        
        self.present(acceptAlert, animated: true)
    }
    
    private func addReminderToCalendar(){
        
        let alert = UIAlertController(title: "Добавить событие в календарь?", message: "Экскурсия '\(self.excursion.excursionName)' \(self.excursion.dateAndTime.birthdayToString()) в \(self.excursion.dateAndTime.timeToString())", preferredStyle: .alert)
        
        let actionCancel = UIAlertAction(title: "Отменить", style: .cancel)
        
        if #available(iOS 17.0, *) {
            self.eventStore.requestWriteOnlyAccessToEvents { granted, error in
                if (granted) && (error == nil) {
                    
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
        } else {
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
    }
    
    private func configureAndSaveCalendarEvent(){
        let event:EKEvent = EKEvent(eventStore: self.eventStore)
        event.title = self.excursion.excursionName
        event.startDate = self.excursion.dateAndTime
        event.endDate = Calendar.current.date(byAdding: .init(minute: 90), to: self.excursion.dateAndTime)
        
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        let remiderDate = Calendar.current.date(byAdding: .init(minute: -30), to: self.excursion.dateAndTime)
        event.addAlarm(EKAlarm(absoluteDate: remiderDate ?? self.excursion.dateAndTime))
        
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
        case 0: return  self.excursion.guideAccessNotes ? 5 : 4
        case 1: return 2
        case 2: return excursion.isPaid ? 1 : 2
        case 3: return 1
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 && indexPath.row == 1{
            if self.excursion.companyGuidePhone != ""{
                generalLogic.callNumber(phoneNumber: self.excursion.companyGuidePhone)
            }
        }
    }

}

extension ExcursionForGuideTableViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.excursion.selfGuides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let nib = UINib(nibName: "GuideCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "GuideCollectionViewCell")
                
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GuideCollectionViewCell", for: indexPath) as! GuideCollectionViewCell
        
        cell.fullName.text = self.excursion.selfGuides[indexPath.row].guideInfo.getFullName()
        if self.excursion.selfGuides[indexPath.row].isMain{
            cell.isMainGuide.isHidden = false
        }else{
            cell.isMainGuide.isHidden = true
        }
        
        cell.status.tintColor = self.excursion.selfGuides[indexPath.row].status.getColor()
        
        self.user?.downloadProfilePhoto(localId: self.excursion.selfGuides[indexPath.row].guideInfo.getLocalID() ?? "", completion: { data, error in
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
        
        guideController.employee = self.excursion.selfGuides[indexPath.row].guideInfo
        guideController.isShowAccessLevels = false
        
        self.navigationController?.pushViewController(guideController, animated: true)
        
        
    }

    
    
}
