//
//  FullCalendarViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 04.12.2023.
//

import UIKit

final class FullCalendarViewController: BaseViewController {
    
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
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise.circle"), style: .plain, target: self, action: #selector(refreshDates))
         
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image:     UIImage(systemName: "xmark.circle"), style: .plain, target: self, action: #selector(closeTapped))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view().calendar.scrollToDate(startDate, animateScroll: false)
        self.view().calendar.selectDates([startDate], triggerSelectionDelegate: true)
        self.view().selectedDate = startDate
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
            if let cell = self.view().calendar.cellStatus(for: date)?.cell() as? CalendarCell{
                cell.configureEvents(self.view().viewDelegate.getEventsForDate(date: date))
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
        
        if presenter.isGuide{
            if let eventModel = self.presenter.getGuideEvent(tourDate: date){
                
                if eventModel.waiting{
                    res.append(.systemYellow)
                }
                if eventModel.cancel{
                    res.append(.systemRed)
                }
                if eventModel.accept{
                    res.append(.green)
                }
            }
            
        }else{
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
