//
//  FullCalendarViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 04.12.2023.
//

import UIKit

class FullCalendarViewController: UIViewController {
    
    var presenter:FullCalendarPresenterProtocol!
    
    var startDate:Date = Date.now
    var doAfterSelecting:((Date)->Void)?
    
    private func view() -> FullCalendarView{
        return view as! FullCalendarView
    }

    override func loadView() {
        super.loadView()
        self.view = FullCalendarView()
        self.view().viewDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTargets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view().calendar.scrollToDate(startDate, animateScroll: false)
        self.view().calendar.selectDates([startDate], triggerSelectionDelegate: true)
        self.view().selectedDate = startDate
    }
    
    private func addTargets(){
        self.view().closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        self.view().refreshButton.addTarget(self, action: #selector(refreshDates), for: .touchUpInside)
    }
    
    
    // MARK: - Actions
    
    @objc private func closeTapped(){
        self.dismiss(animated: true)
    }
    @objc private func refreshDates(){
        self.view().calendar(self.view().calendar, didScrollToDateSegmentWith: self.view().calendar.visibleDates())
    }
    
    // MARK: - Helpers
    
    public func reloadDates(_ dates: [Date]){
        for date in dates {
            if let indexPath = self.view().datesIndexPath[date]{
                if let cell = self.view().calendar.cellForItem(at: indexPath) as? CalendarCell{
                    
                    cell.configureEvents(self.view().viewDelegate.getEventsForDate(date: date))
                }
            }
        }
    }
    
}

extension FullCalendarViewController:FullCalendarViewProtocol{
    func updateEvents(startDate: Date, endDate: Date) {
        var dates: [Date] = []
        var currentDate = startDate

        let calendar = Calendar.current

        while currentDate <= endDate {
            dates.append(currentDate)
            if let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                currentDate = nextDate
            } else {
                break
            }
        }
        
        self.reloadDates(dates)
    }
    
    
}

extension FullCalendarViewController:FullCalendarViewDelegate{
    func getEventsForDate(date: Date) -> [UIColor] {
        var res:[UIColor] = []
        if let eventModel = self.presenter.getEvent(tourDate: date){
            
            if eventModel.waiting{
                res.append(.systemYellow)
            }
            if eventModel.cancel{
                res.append(.systemRed)
            }
            if eventModel.emptyGuide{
                res.append(.systemBlue)
            }
            if eventModel.accept{
                res.append(.green)
            }
        }
        
        return res
    }
    
    func loadEvents(startDate: Date, endDate: Date) {
        self.presenter.getTourDates(startDate: startDate, endDate: endDate)
    }
    
    func didSelectDate(date: Date) {
        self.dismiss(animated: true) {
            self.doAfterSelecting?(date)
        }
    }
    
    
}
