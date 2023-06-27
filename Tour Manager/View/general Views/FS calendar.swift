//
//  FS calendar.swift
//  Tour Manager
//
//  Created by SHREDDING on 21.06.2023.
//

import Foundation
import UIKit
import FSCalendar

class FSCalendarSchedule{
    var viewController:UIViewController
    var calendarHeightConstraint:NSLayoutConstraint!
    
    public let calendar:FSCalendar = {
        
        let calendar = FSCalendar()
        
        calendar.firstWeekday = 2
        calendar.scope = .week
        
         // locale
        calendar.appearance.headerMinimumDissolvedAlpha = 0
        calendar.locale = NSLocale(localeIdentifier: "ru") as Locale
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru")
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM YYYY")
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
    
    public var showCloseCalendarButton:UIButton = {
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
        
        button.isHidden = true
        return button
    }()
    
    init(_ viewController:UIViewController, actionTodayButton:UIAction){
        self.viewController = viewController
        
        self.calendar.delegate = viewController as? any FSCalendarDelegate
        self.calendar.dataSource = viewController as? any FSCalendarDataSource
        
        self.viewController.view.addSubview(calendar)
        self.viewController.view.addSubview(todayButton)
        self.viewController.view.addSubview(showCloseCalendarButton)
        self.configureFSCalendar(actionTodayButton: actionTodayButton)
        
    }
    
    
    
    // MARK: - Configaration FS Calendar
    
    fileprivate func configureFSCalendar(actionTodayButton:UIAction){
        
        calendarHeightConstraint = NSLayoutConstraint(item: self.calendar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300)
        calendar.addConstraint(calendarHeightConstraint)
       
       NSLayoutConstraint.activate([
        calendar.topAnchor.constraint(equalTo: self.viewController.view.safeAreaLayoutGuide.topAnchor, constant: 0),
        calendar.leadingAnchor.constraint(equalTo: self.viewController.view.leadingAnchor, constant: 0),
        calendar.trailingAnchor.constraint(equalTo: self.viewController.view.trailingAnchor, constant: 0)]
       )

        NSLayoutConstraint.activate([
            showCloseCalendarButton.topAnchor.constraint(equalTo: self.calendar.bottomAnchor, constant: 10),
            showCloseCalendarButton.trailingAnchor.constraint(equalTo: self.viewController.view.trailingAnchor, constant: -20),
            showCloseCalendarButton.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        NSLayoutConstraint.activate([
            todayButton.topAnchor.constraint(equalTo: self.calendar.bottomAnchor, constant: 5),
            todayButton.heightAnchor.constraint(equalToConstant: 20),
            todayButton.leadingAnchor.constraint(equalTo: self.viewController.view.leadingAnchor, constant: 20),
        ])
        
        showCloseCalendarButton.addTarget(self, action: #selector(buttonShowCloseTapped), for: .touchUpInside)
        
        todayButton.addTarget(self, action: #selector(returnToToday), for: .touchUpInside)
        todayButton.addAction(actionTodayButton, for: .touchUpInside)
        todayButton.isHidden = true
        
    }
    
    public func setCalendarHeightConstraint(_ height: Double){
        calendarHeightConstraint.constant = height
    }
    
    
    @objc private func returnToToday(){
        if let today =  self.calendar.today{
            self.calendar.setCurrentPage(today, animated: true)
            
            if let selected = self.calendar.selectedDate{
                self.calendar.deselect(selected)
            }
            
        }
    }
    
    @objc public func buttonShowCloseTapped(){
        switch self.calendar.scope{
        case .week:
            self.calendar.setScope(.month, animated: true)
            UIView.transition(with: self.showCloseCalendarButton, duration: 0.3, options: .transitionFlipFromTop) {
                self.showCloseCalendarButton.setTitle( "Скрыть", for: .normal)
            }
        case .month:
            self.calendar.setScope(.week, animated: true)
            UIView.transition(with: showCloseCalendarButton , duration: 0.5, options: .transitionFlipFromTop){
                self.showCloseCalendarButton.setTitle( "Развернуть", for: .normal)
            }
        @unknown default:
            break
        }
    }
    
    
    public func onOffResetButton(_ date: Date) {
        todayButton.isHidden = false
        if date.birthdayToString() == self.calendar.today?.birthdayToString(){
            todayButton.isHidden = true
        }else{
            todayButton.isHidden = false
        }
    }
    
    
}
