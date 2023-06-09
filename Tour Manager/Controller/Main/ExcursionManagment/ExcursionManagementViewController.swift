//
//  ExcursionManagementViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 05.06.2023.
//

import UIKit
import FSCalendar

class ExcursionManagementViewController: UIViewController{
    
    
    // MARK: - some varibales
    
    let controllers = Controllers()
    
    let user = AppDelegate.user
    
    let alerts = Alert()
    
    var events:[ResponseGetExcursionsListByRange] = []
    
    // MARK: - Excursions
    
    let excursionsModel = ExcursionsControllerModel()
    
        
    var calendar:FSCalendarSchedule!
    
    // MARK: - Table view Object
    
    let tableViewCalendar:UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .insetGrouped)
        tableView.restorationIdentifier = "tableViewCalendar"
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        
        let labelNotTours = UILabel()
        labelNotTours.font = Font.getFont(name: .americanTypewriter, style: .semiBold, size: 26)
        labelNotTours.textColor = UIColor(resource: .blueText)
        labelNotTours.textAlignment = .center
        labelNotTours.text = "Сегодня экскурсий нет"
        labelNotTours.translatesAutoresizingMaskIntoConstraints = false
        labelNotTours.numberOfLines = 0
        labelNotTours.layer.opacity = 0
        labelNotTours.tag = 1
        
        
        tableView.addSubview(labelNotTours)
        
        NSLayoutConstraint.activate([
            labelNotTours.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            labelNotTours.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
        ])
        
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = UIColor(resource: .blueText)
        activityIndicator.hidesWhenStopped = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.tag = 2
        
        activityIndicator.layer.opacity = 0
        
        tableView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
        ])
        
        let refreshCotroller = UIRefreshControl()
        refreshCotroller.tintColor = UIColor(resource: .blueText)
        refreshCotroller.tag = 3
        
        tableView.refreshControl = refreshCotroller
        
        return tableView
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.addSubviews()
        
        self.configureFSCalendar()
        self.configureTableView()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getExcursions(date: self.calendar.calendar.selectedDate ?? Date.now)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getEventsForDates()
    }
    
    // MARK: - addSubviews
    
    fileprivate func addSubviews(){
        self.view.addSubview(tableViewCalendar)
    }
    
    // MARK: - Configuration View
    
    fileprivate func configureView(){
        self.navigationItem.title = "Управление"
        
        if (self.user?.getAccessLevel(rule: .canWriteTourList) ?? false){
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .add, primaryAction: UIAction(handler: { _ in
                
                let newExcursionController = self.controllers.getControllerMain(.newExcursionTableViewController) as! NewExcursionTableViewController
                
                let newTour = Excursion(dateAndTime: self.calendar.calendar.selectedDate ?? Date.now)
                
                newExcursionController.excursion = newTour
                
                
                self.navigationController?.pushViewController(newExcursionController, animated: true)
            }))
        }
        
        
        
        
        // swipes left and right to change day in calendar
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
    }
    
    // MARK: - Configaration FS Calendar
    
    fileprivate func configureFSCalendar(){
        calendar = FSCalendarSchedule(self, actionTodayButton: UIAction(handler: { _ in
            self.calendarDeselect(date: Date.now)
        }))
        self.view.addSubview(tableViewCalendar)
        
    }
    
    // MARK: - Configuration Table View
    
    fileprivate func configureTableView(){
        self.tableViewCalendar.delegate = self
        self.tableViewCalendar.dataSource = self
        
        let refreshController = tableViewCalendar.viewWithTag(3) as! UIRefreshControl
        
        refreshController.addAction(UIAction(handler: { _ in
            self.getExcursions(date: self.calendar.calendar.selectedDate ?? Date.now)
            
            self.getEventsForDates()
            refreshController.endRefreshing()
        }), for: .primaryActionTriggered)
        
        let cell = UINib(nibName: "TourManadgmentTableViewCell", bundle: nil)
        
        tableViewCalendar.register(cell, forCellReuseIdentifier: "TourManadgmentTableViewCell")
        
        NSLayoutConstraint.activate([
            
            tableViewCalendar.topAnchor.constraint(equalTo:self.calendar.showCloseCalendarButton.bottomAnchor, constant: 10),
            tableViewCalendar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableViewCalendar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableViewCalendar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])

    }
        
    // MARK: - Handle Actions
    
    @objc func swipeAction(gesture:UISwipeGestureRecognizer){
        let date:Date = Date.now
        var nextOrPrevDay:Date?
        var addingDays = 0
        
        
        switch gesture.direction{
        case .right:
            addingDays = -1
        case .left:
            addingDays = 1
        default:
            break
        }
        
        nextOrPrevDay = Calendar.current.date(byAdding: DateComponents(day: addingDays), to: self.calendar.calendar.selectedDate ?? date)
        
        
        self.calendar.calendar.select(nextOrPrevDay, scrollToDate: true)
        _  = self.calendarShouldSelect(self.calendar.calendar, date: nextOrPrevDay ?? date)
        
        reloadData()
    }
    /**
     this function updates the table view
     
     */
    fileprivate func reloadData(isNotTours:Bool = true) {
        UIView.transition(with: self.tableViewCalendar, duration: 0.5,options: .transitionCrossDissolve) {
            self.tableViewCalendar.reloadData()
            print("reloadData")
            
            
            let label = self.tableViewCalendar.viewWithTag(1)
            if self.excursionsModel.excursions.count == 0 && isNotTours{
                label?.layer.opacity = 0.5
            }else{
                label?.layer.opacity = 0
            }
            
        }
        
        
    }
    
    // MARK: - Get excursions
    
    fileprivate func getExcursions(date:Date){
        self.excursionsModel.excursions = []

        self.reloadData(isNotTours: false)
        
        let activityIndicator = self.tableViewCalendar.viewWithTag(2) as! UIActivityIndicatorView
        
        activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.3) {
            activityIndicator.layer.opacity = 1
        }
        
        
        excursionsModel.getExcursionsFromApi(token: self.user?.getToken() ?? "", companyId: self.user?.company.getLocalIDCompany() ?? "" , date: date) { isGetted, error in
                        
            if let err = error{
                if err != .dataNotFound{
                    self.alerts.errorAlert(self, errorExcursionsApi: err)
                }
                else{
                    self.reloadData()
                }
            }
            
                        
            if isGetted{
                UIView.transition(with: self.tableViewCalendar, duration: 0.3, options: .transitionCrossDissolve) {
                    if let selectedDate = self.calendar.calendar.selectedDate{
                        if selectedDate.birthdayToString() == date.birthdayToString(){
                            self.reloadData()
                        }
                    }else if Date.now.birthdayToString() == date.birthdayToString(){
                            self.reloadData()
                        }
                }
            }
            
           
            UIView.animate(withDuration: 0.3) {
                activityIndicator.layer.opacity = 0
            }
            activityIndicator.stopAnimating()
        }
    }
    
    fileprivate func getEventsForDates(){
        let startDate:Date = Calendar.current.date(byAdding: DateComponents(day: -5), to: self.calendar.calendar.currentPage)!
        var endDate:Date = .now
        
        switch self.calendar.calendar.scope{
        case .month:
            endDate = Calendar.current.date(byAdding: DateComponents(day: 35), to: self.calendar.calendar.currentPage)!
        case .week:
            endDate = Calendar.current.date(byAdding: DateComponents(day: 10), to: self.calendar.calendar.currentPage)!
        @unknown default:
            break
        }
        
        excursionsModel.getExcursionsListByRange(token: self.user?.getToken() ?? "", companyId: self.user?.company.getLocalIDCompany() ?? "", startDate: startDate.birthdayToString(), endDate: endDate.birthdayToString()) { isGetted, list, error in
            
            if let err = error{
                self.alerts.errorAlert(self, errorExcursionsApi: err)
            }
            
            if isGetted{
                self.events = list!
                
                self.calendar.calendar.reloadData()
            }
            
        }
        
    }
}



// MARK: - FSCalendarDelegate
extension ExcursionManagementViewController:FSCalendarDelegate, FSCalendarDataSource,FSCalendarDelegateAppearance{
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendar.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return self.calendarShouldSelect(calendar, date: date)
    }
    
    fileprivate func calendarShouldSelect(_ calendar:FSCalendar, date:Date)->Bool{
        self.calendar.onOffResetButton(date)
        if date == calendar.today{
            if let selectedDate = calendar.selectedDate{
               
                self.calendarDeselect(date:selectedDate)
            }
            return false
        }
        self.getExcursions(date: date)
        return true
    }
    
    
fileprivate func calendarDeselect(date:Date){
    self.calendar.calendar.deselect(date)
    self.getExcursions(date: Date.now)
    self.calendar.onOffResetButton(Date.now)
}
    
    
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        // change the month
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru")
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM YYYY")
        
        calendar.appearance.headerDateFormat = dateFormatter.string(from: calendar.currentPage)
        
        self.getEventsForDates()
                
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        for event in events{
            if event.tourDate == date.birthdayToString(){
                var result = event.cancel.toInt() + event.emptyGuide.toInt() + event.waiting.toInt()
                if result == 0{
                    result += event.accept.toInt()
                }
                return result
            }
        }
        return 0
    }
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        
        var eventsColors:[UIColor] = []
        
        for event in events{
            if event.tourDate == date.birthdayToString(){
                if event.waiting{
                    eventsColors.append(.systemYellow)
                }
                if event.cancel{
                    eventsColors.append(.systemRed)
                }
                if event.emptyGuide{
                    eventsColors.append(.systemBlue)
                }
                if event.accept{
                    eventsColors.append(.systemGreen)
                }
            }
            
        }
        
        return eventsColors
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        
        var eventsColors:[UIColor] = []
        
        for event in events{
            if event.tourDate == date.birthdayToString(){
                if event.waiting{
                    eventsColors.append(.systemYellow)
                }
                if event.cancel{
                    eventsColors.append(.systemRed)
                }
                if event.emptyGuide{
                    eventsColors.append(.systemBlue)
                }
                if event.accept{
                    eventsColors.append(.systemGreen)
                }
            }
            
        }
        
        return eventsColors
        
    }
}


// MARK: - UITableViewDelegate
extension ExcursionManagementViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.excursionsModel.excursions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TourManadgmentTableViewCell", for: indexPath) as! TourManadgmentTableViewCell
        
        cell.nameLabel.text = self.excursionsModel.excursions[indexPath.row].excursionName
        cell.routeLabel.text = self.excursionsModel.excursions[indexPath.row].route
        
        cell.startTimeLabel.text = self.excursionsModel.excursions[indexPath.row].dateAndTime.timeToString()
        
        cell.numberOfPeople.text = self.excursionsModel.excursions[indexPath.row].numberOfPeople
        
        cell.customerCompanyName.text = self.excursionsModel.excursions[indexPath.row].customerCompanyName
        
        var guides = ""
        
        var statuses:[Status] = []
        
        for guide in self.excursionsModel.excursions[indexPath.row].selfGuides{
            guides += guide.guideInfo.getFirstName() + ", "
            
            statuses.append(guide.status)
            
        }
        if guides.count > 2{
            guides.removeLast()
            guides.removeLast()
            
            if statuses.contains(.cancel){
                cell.statusView.backgroundColor = .systemRed
            } else if statuses.contains(.waiting){
                cell.statusView.backgroundColor = .systemYellow
            } else if  statuses.contains(.accepted){
                cell.statusView.backgroundColor = .systemGreen
            }
            
        }else{
            cell.statusView.backgroundColor = .systemBlue
        }
        
        cell.guidesLabel.text = guides
        
        if self.excursionsModel.excursions[indexPath.row].dateAndTime < Date.now{
            cell.contentView.layer.opacity = 0.5
        }else{
            cell.contentView.layer.opacity = 1
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableViewCalendar.deselectRow(at: indexPath, animated: true)
        
        let destination = self.controllers.getControllerMain(.newExcursionTableViewController) as! NewExcursionTableViewController
        
        destination.excursion = excursionsModel.excursions[indexPath.row]
        destination.isUpdate = true
        
        self.navigationController?.pushViewController(destination, animated: true)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableViewCalendar{
            if self.calendar.calendar.scope == .month{
                self.calendar.buttonShowCloseTapped()
            }
        }
    }
}
