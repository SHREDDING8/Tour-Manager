//
//  ExcursionManagementViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 05.06.2023.
//

import UIKit
import FSCalendar

class ExcursionManagementViewController: UIViewController{
    
    var presenter:ExcursionManadmentPresenterProtocol!
    
    // MARK: - some varibales
    
    let controllers = Controllers()
        
    let alerts = Alert()
        
    // MARK: - Excursions
    
    var calendar:FSCalendarSchedule!
    
    // MARK: - Table view Object
    
    let tableViewCalendar:UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .insetGrouped)
        tableView.restorationIdentifier = "tableViewCalendar"
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        
        let labelNotTours = UILabel()
        labelNotTours.font = Font.getFont(name: .americanTypewriter, style: .semiBold, size: 26)
        labelNotTours.textColor = UIColor(named: "blueText")
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
        activityIndicator.color = UIColor(named: "blueText")
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
        refreshCotroller.tintColor = UIColor(named: "blueText")
        refreshCotroller.tag = 3
        
        tableView.refreshControl = refreshCotroller
        
        return tableView
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = ExcursionManadmentPresenter(view: self)
        
        self.configureView()
        self.addSubviews()
        
        self.configureFSCalendar()
        self.configureTableView()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.loadTours(date: self.calendar.calendar.selectedDate ?? Date.now)
        self.getEventsForDates()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // MARK: - addSubviews
    
    fileprivate func addSubviews(){
        self.view.addSubview(tableViewCalendar)
    }
    
    // MARK: - Configuration View
    
    fileprivate func configureView(){
        self.navigationItem.title = "Управление"
        
        if self.presenter.isAccessLevel(key: .canWriteTourList){
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .add, primaryAction: UIAction(handler: { _ in
                
                let newExcursionController = TourManadmentAssembly.createNewTourController(isUpdate: false)
                
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
            self.presenter.loadTours(date: self.calendar.calendar.selectedDate ?? Date.now)
            
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
        
    }
    /**
     this function updates the table view
     
     */
    
    // MARK: - Get excursions
        
    fileprivate func getEventsForDates(){
        var startDate:Date = .now
        var endDate:Date = .now
        
        switch self.calendar.calendar.scope{
        case .month:
            endDate = Calendar.current.date(byAdding: DateComponents(day: 35), to: self.calendar.calendar.currentPage)!
            startDate = Calendar.current.date(byAdding: DateComponents(day: -35), to: self.calendar.calendar.currentPage)!
        case .week:
            endDate = Calendar.current.date(byAdding: DateComponents(day: 10), to: self.calendar.calendar.currentPage)!
            
            startDate = Calendar.current.date(byAdding: DateComponents(day: -10), to: self.calendar.calendar.currentPage)!
            
        @unknown default:
            break
        }
        
        DispatchQueue.main.async {
            self.presenter.getExcursionsListByRangeFromServer(startDate: startDate, endDate: endDate)
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
        self.presenter.loadTours(date: date)
        return true
    }
    
    
fileprivate func calendarDeselect(date:Date){
    self.calendar.calendar.deselect(date)
    self.presenter.loadTours(date: Date.now)
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
        if let event = presenter.getEvent(tourDate: date){
            
            var result = event.cancel.toInt() + event.emptyGuide.toInt() + event.waiting.toInt()
            if result == 0{
                result += event.accept.toInt()
            }
            return result
            
        }
        
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        
        var eventsColors:[UIColor] = []
        
        if let event = presenter.getEvent(tourDate: date){
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
        
        return eventsColors
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        
        var eventsColors:[UIColor] = []
        
        if let event = presenter.getEvent(tourDate: date){
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
        
        return eventsColors
        
    }
}


// MARK: - UITableViewDelegate
extension ExcursionManagementViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.presenter.tours[(self.calendar.calendar.selectedDate ?? Date.now).birthdayToString()]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TourManadgmentTableViewCell", for: indexPath) as! TourManadgmentTableViewCell
        
        if let tour = presenter.tours[calendar.calendar.selectedDate?.birthdayToString() ?? Date.now.birthdayToString()]?[indexPath.row]{
           
            cell.nameLabel.text = tour.tourTitle
            cell.routeLabel.text = tour.route
            
            cell.startTimeLabel.text = tour.dateAndTime.timeToString()
            
            cell.numberOfPeople.text = tour.numberOfPeople
            
            cell.customerCompanyName.text = tour.customerCompanyName
            
            var guides = ""
            var statuses:[ExcrusionModel.GuideStatus] = []
            
            for guide in tour.guides{
                guides += guide.firstName + " " + guide.lastName + ", "
                
                statuses.append(guide.status)
            }
            if guides.count > 0{
                guides.removeLast()
                guides.removeLast()
            }
            
            if statuses.contains(.cancel){
                cell.statusView.backgroundColor = .systemRed
            } else if statuses.contains(.waiting){
                cell.statusView.backgroundColor = .systemYellow
            } else if statuses.contains(.accept){
                cell.statusView.backgroundColor = .systemGreen
            } else {
                cell.statusView.backgroundColor = .systemBlue
            }
            
            cell.guidesLabel.text = guides
            
            if tour.dateAndTime < Date.now{
                cell.contentView.layer.opacity = 0.5
            }else{
                cell.contentView.layer.opacity = 1
            }
        }
                        
        return cell
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        if let tour = presenter.tours[calendar.calendar.selectedDate?.birthdayToString() ?? Date.now.birthdayToString()]?[indexPath.row]{
            
            let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: {
                let newTourVC = TourManadmentAssembly.createNewTourController(isUpdate: true, model: tour)
                return newTourVC
            }) { elements in
                let delete = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                    
                    self.alerts.deleteAlert(self, title: "Вы уверены что хотите удалить экскурсию?", buttonTitle: "Удалить") {
                        self.presenter.deleteTour(date: tour.dateAndTime, excursionId: tour.tourId)
                        
                    }
                    
                }
                
                return UIMenu(options: .displayInline, children: [delete])
            }
            
            return configuration
            
        }
        
        return nil
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableViewCalendar.deselectRow(at: indexPath, animated: true)
                
        if let tour = presenter.tours[calendar.calendar.selectedDate?.birthdayToString() ?? Date.now.birthdayToString()]?[indexPath.row]{
            let newTourVC = TourManadmentAssembly.createNewTourController(isUpdate: true, model: tour)
            
            self.navigationController?.pushViewController(newTourVC, animated: true)
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableViewCalendar{
            if self.calendar.calendar.scope == .month{
                self.calendar.buttonShowCloseTapped()
            }
        }
    }
}

extension ExcursionManagementViewController:ExcursionManadmentViewProtocol{
    
    func updateTours() {
        self.tableViewCalendar.reloadData()
    }
    
    func updateEvents(){
        print("updateEvents")
        self.calendar.calendar.reloadData()
    }
    
}
