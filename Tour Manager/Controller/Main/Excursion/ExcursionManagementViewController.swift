//
//  ExcursionManagementViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 05.06.2023.
//

import UIKit
import FSCalendar

class ExcursionManagementViewController: UIViewController{
    
    // MARK: - Excursions
    
    var excursionsArray:[Excursion] = []
    
    
    // MARK: - Calendar Object
    var calendarHeightConstraint:NSLayoutConstraint!
    let calendar:FSCalendar = {
        
        let calendar = FSCalendar()
        
        calendar.firstWeekday = 2
        calendar.scope = .week
        
         // locale
        calendar.appearance.headerMinimumDissolvedAlpha = 0
        calendar.locale = NSLocale(localeIdentifier: "ru") as Locale
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru")
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE dd MMMM YYYY")
        // set template after setting locale
        calendar.appearance.headerDateFormat = dateFormatter.string(from: calendar.currentPage)
        
        
        calendar.translatesAutoresizingMaskIntoConstraints = false
        
        //settings color
        calendar.appearance.headerTitleColor = UIColor(named: "gray")
        calendar.appearance.weekdayTextColor = UIColor(named: "gray")
        calendar.appearance.titleWeekendColor = .systemGray
        calendar.appearance.titlePlaceholderColor = .systemGray3
        
        calendar.appearance.titleDefaultColor = UIColor(named: "black")
        
        calendar.appearance.selectionColor = .systemOrange
        
        calendar.appearance.borderSelectionColor = .systemBlue
        
        calendar.appearance.todayColor = .systemBlue
        
        // settings Font
        calendar.appearance.headerTitleFont = UIFont.systemFont(ofSize: 18)
        calendar.appearance.weekdayFont = UIFont.systemFont(ofSize: 14, weight: .bold)
        calendar.appearance.titleFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
        
    
        return calendar
        
    }()
    
    // MARK: - Table view Object
    
    let tableView:UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    
    // MARK: - Buttons Objects
    
    private var showCloseCalendarButton:UIButton = {
        let button = UIButton()
        button.setTitle("Развернуть", for: .normal)
        button.setTitleColor(UIColor.orange, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    //reset button
    private var todayButton:UIButton = {
        let button = UIButton()
        button.setTitle("⟲", for: .normal)
        button.setTitleColor(UIColor.orange, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = button.titleLabel?.font.withSize(40)
        return button
    }()
    
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.addSubviews()
        
        self.configureFSCalendar()
        self.configureTableView()
        self.configureButtons()
        
        
        for i in 0...10{
            let ex = Excursion(companyName: "exursion \(i)", route:"уи-об-оэз")
            self.excursionsArray.append(ex)
        }
        
        
        
        
        

        // Do any additional setup after loading the view.
    }
    
    // MARK: - addSubviews
    
    fileprivate func addSubviews(){
        self.view.addSubview(calendar)
        self.view.addSubview(tableView)
        
        self.view.addSubview(showCloseCalendarButton)
        self.view.addSubview(todayButton)
    }
    
    // MARK: - Configuration View
    
    fileprivate func configureView(){
        self.navigationItem.title = "Управление"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .add)
        
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
        
        calendarHeightConstraint = NSLayoutConstraint(item: self.calendar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300)
        calendar.addConstraint(calendarHeightConstraint)
       
       NSLayoutConstraint.activate([
        calendar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
        calendar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
        calendar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0)]
       )
        calendar.delegate = self
        calendar.dataSource = self
        
        self.calendar.backgroundColor = .darkGray
        
    }
    
    // MARK: - Configuration Table View
    
    fileprivate func configureTableView(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let cell = UINib(nibName: "ExcursionTableViewCell", bundle: nil)
        
        tableView.register(cell, forCellReuseIdentifier: "ExcursionTableViewCell")
        
        NSLayoutConstraint.activate([
            
            tableView.topAnchor.constraint(equalTo:self.showCloseCalendarButton.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])

        
    }
    
    // MARK: - Configuration Buttons for Calendar
    fileprivate func configureButtons(){
        
        NSLayoutConstraint.activate([
            showCloseCalendarButton.topAnchor.constraint(equalTo: self.calendar.bottomAnchor, constant: 10),
            showCloseCalendarButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            showCloseCalendarButton.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        NSLayoutConstraint.activate([
            todayButton.topAnchor.constraint(equalTo: self.calendar.bottomAnchor, constant: 5),
            todayButton.heightAnchor.constraint(equalToConstant: 20),
            todayButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
        ])
        
        showCloseCalendarButton.addTarget(nil, action: #selector(buttonShowCloseTapped), for: .touchUpInside)
        todayButton.addTarget(self, action: #selector(returnToToday), for: .touchUpInside)
        todayButton.isHidden = true
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
        
        nextOrPrevDay = Calendar.current.date(byAdding: DateComponents(day: addingDays), to: self.calendar.selectedDate ?? Date.now)
        
        self.calendar.select(nextOrPrevDay, scrollToDate: true)
        
        reloadData()
        
        onOffResetButton(date)
    }
    
    @objc private func returnToToday(){
        
        if let today =  self.calendar.today{
                if self.calendar.scope == .month{
                    buttonShowCloseTapped()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
                    if let selected = self.calendar.selectedDate{
                        self.calendar.deselect(selected)
                    }
                    self.calendar.setCurrentPage(today, animated: true)
//                    self.getCurrentClasses(date: .now)
                    self.reloadData()
                })
                todayButton.isHidden = true
            }
        }
    
    
    @objc private func buttonShowCloseTapped(){
        if self.calendar.scope == .week{
            // change the scope
            self.calendar.setScope(.month, animated: true)
            
            // change the text of button
            UIView.transition(with: showCloseCalendarButton , duration: 0.5, options: .transitionFlipFromTop, animations: {
                self.showCloseCalendarButton.setTitle( "Скрыть", for: .normal)
            }, completion: nil)
        }else{
            self.calendar.setScope(.week, animated: true)
            UIView.transition(with: showCloseCalendarButton , duration: 0.5, options: .transitionFlipFromTop, animations: {
                self.showCloseCalendarButton.setTitle( "Развернуть", for: .normal)
            }, completion: nil)
            
//                if let today =  self.calendar.today{
//                self.calendar.setScope(.week, animated: true)
//                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
//                        if let selected = self.calendar.selectedDate{
//                            self.calendar.deselect(selected)
//                        }
//                        self.calendar.setCurrentPage(today, animated: true)
////                        self.getCurrentClasses(date: .now)
//                        self.reloadData()
//                    })
//                    todayButton.isHidden = true
//                }
        }
        
    }
    
    
    fileprivate func onOffResetButton(_ date: Date) {
        todayButton.isHidden = false
        if date == self.calendar.today{
            todayButton.isHidden = true
            self.calendar.deselect(date)
        }
    }
    
    /**
     this function updates the table view
     
     */
    fileprivate func reloadData() {
        UIView.transition(with: self.tableView, duration: 0.5,options: .transitionCrossDissolve) {
            self.tableView.reloadData()
        }
    }
    


}

// MARK: - FSCalendarDelegate
extension ExcursionManagementViewController:FSCalendarDelegate, FSCalendarDataSource{
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if self.calendar.scope == .week{
            buttonShowCloseTapped()
        }
//        self.getCurrentClasses(date: date)
        self.reloadData()
        
        self.onOffResetButton(date)
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        // change the month
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru")
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM YYYY")
        
        calendar.appearance.headerDateFormat = dateFormatter.string(from: calendar.currentPage)
    }
    
}


// MARK: - UITableViewDelegate
extension ExcursionManagementViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.excursionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExcursionTableViewCell", for: indexPath) as! ExcursionTableViewCell
        
        cell.nameLabel.text = self.excursionsArray[indexPath.row].companyName
        cell.routeLabel.text = self.excursionsArray[indexPath.row].route
        
        return cell
    }
    
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableView{
            if self.calendar.scope == .month{
                buttonShowCloseTapped()
            }
        }
    }
    
    
}
