//
//  FullCalendarView.swift
//  Tour Manager
//
//  Created by SHREDDING on 04.12.2023.
//

import UIKit
import JTAppleCalendar
import SnapKit

protocol FullCalendarViewDelegate{
    func getEventsForDate(date:Date)->[UIColor]
    func loadEvents(startDate:Date, endDate:Date)
    func didSelectDate(date:Date)
}

final class FullCalendarView: UIView {
    var viewDelegate:FullCalendarViewDelegate!
    var selectedDate:Date = Date.now
            
    lazy var calendar:JTACMonthView = {
        let calendar = JTACMonthView()
        calendar.backgroundColor = .clear
        calendar.calendarDataSource = self
        calendar.calendarDelegate = self
        
        calendar.scrollDirection = .vertical
        calendar.showsVerticalScrollIndicator = false
        calendar.scrollingMode = .stopAtEachSection
        calendar.cellSize = 80
       
        calendar.register(CalendarCell.self, forCellWithReuseIdentifier: "CalendarCell")
        
        calendar.register(FullCalendarMonthHeader.self, forSupplementaryViewOfKind: "FullCalendarMonthHeader", withReuseIdentifier: "FullCalendarMonthHeader")
        return calendar
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit(){
        self.backgroundColor = UIColor(resource: .background)
        self.addSubview(calendar)
                
        calendar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(self.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
        
    }
}

extension FullCalendarView:JTACMonthViewDataSource{
    
    func calendarSizeForMonths(_ calendar: JTACMonthView?) -> MonthSize? {
        return MonthSize(defaultSize: 50)
    }
    
    
    func calendar(_ calendar: JTACMonthView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTACMonthReusableView {
        
        let view = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "FullCalendarMonthHeader", for: indexPath) as! FullCalendarMonthHeader
        
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL, YYYY г."
        
        view.title.text = formatter.string(from: range.start)
        
        return view
    }

    
    func configureCalendar(_ calendar: JTAppleCalendar.JTACMonthView) -> JTAppleCalendar.ConfigurationParameters {
        var calendarTime = Calendar.current
        calendarTime.timeZone = .current
        
        let startDate = calendarTime.date(byAdding: .year, value: -1, to: Date.now)!
        let endDate = calendarTime.date(byAdding: .year, value: 1, to: Date.now)!

        return JTAppleCalendar.ConfigurationParameters(
            startDate: startDate,
            endDate: endDate,
            numberOfRows: 6
        )
    }
    
    
}

extension FullCalendarView:JTACMonthViewDelegate{
    func calendar(_ calendar: JTAppleCalendar.JTACMonthView, willDisplay cell: JTAppleCalendar.JTACDayCell, forItemAt date: Date, cellState: JTAppleCalendar.CellState, indexPath: IndexPath) {
        
    }
    
    
    func calendar(_ calendar: JTAppleCalendar.JTACMonthView, cellForItemAt date: Date, cellState: JTAppleCalendar.CellState, indexPath: IndexPath) -> JTAppleCalendar.JTACDayCell {
        
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        cell.configureCell(cellState: cellState)
        
        if cellState.dateBelongsTo == .thisMonth{
            cell.isHidden = false
        }else{
            cell.isHidden = true
        }
        
        cell.configureEvents(viewDelegate.getEventsForDate(date: date))
                
        return cell
    }
    
    func calendar(_ calendar: JTACMonthView, shouldSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) -> Bool {
        
        calendar.deselectAllDates()
        return true
    }
        
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
                        
        if let cell = cell as? CalendarCell{
            cell.select(animated: true)
            self.selectedDate = date
            
            self.viewDelegate.didSelectDate(date: date)
        }
    }
    
    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        let startDate = visibleDates.monthDates.first?.date ?? Date.now
        var endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate) ?? Date.now
        endDate = Calendar.current.date(byAdding: .day, value: -1, to: endDate) ?? Date.now
        
        self.viewDelegate.loadEvents(startDate: startDate, endDate: endDate)
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        if let cell = cell as? CalendarCell{
            cell.deselect(animated: true)
        }
    }
    
}
