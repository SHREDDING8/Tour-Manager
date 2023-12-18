//
//  ToursView.swift
//  Tour Manager
//
//  Created by SHREDDING on 27.11.2023.
//

import UIKit
import JTAppleCalendar
import SnapKit

protocol ToursViewDelegate{
    func getEventsForDate(date:Date)->[UIColor]
    func loadEvents(startDate:Date, endDate:Date)
}

final class ToursView: UIView {
    
    var viewDelegate:ToursViewDelegate!
    
    var indexPathAndDates:[IndexPath:Date] = [:]
    var datesIndexPath:[Date:IndexPath] = [:]
    
    var isFirstLoad:Bool = true
    
    var selectedDate:Date = Date.now{
        didSet{
            UIView.transition(with: self.selectedDayLabel, duration: 0.3, options: .transitionCrossDissolve) {
                self.selectedDayLabel.text = self.formatDateToString(self.selectedDate)
            }
        }
    }
    
    var startDate:Date = Date.now
    var endDate:Date = Date.now
    
    public var didSelectDate:((IndexPath, Date)->Void)?

    lazy var selectedDayStackView:UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.backgroundColor = .clear
        stackView.spacing = 8
        return stackView
    }()

    lazy var selectedDayLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.text = "9 сентября, воскресенье"
        return label
    }()
    
    lazy var calendar:JTACMonthView = {
        let calendar = JTACMonthView()
        calendar.backgroundColor = .clear
        calendar.calendarDataSource = self
        calendar.calendarDelegate = self
        
        calendar.scrollDirection = .horizontal
        calendar.showsHorizontalScrollIndicator = false
        calendar.scrollingMode = .stopAtEachCalendarFrame
       
        calendar.register(CalendarCell.self, forCellWithReuseIdentifier: "CalendarCell")
        
        calendar.allowsDateCellStretching = true
        return calendar
    }()
    
    lazy var collectionViewTours:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.isPagingEnabled = true
        
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .clear
        view.register(ToursCollectionViewCell.self, forCellWithReuseIdentifier: "ToursCollectionViewCell")
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit(){
        self.backgroundColor = UIColor(resource: .background)
        
        self.addSubview(selectedDayStackView)
        self.addSubview(calendar)
        self.addSubview(collectionViewTours)
        
        selectedDayStackView.addArrangedSubview(selectedDayLabel)
        
        self.calendar.scrollToDate(Date.now, animateScroll: false)
        self.calendar.selectDates([Date.now])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        selectedDayStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(self.safeAreaLayoutGuide).offset(16)
        }
                
        calendar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(selectedDayStackView.snp.bottom).offset(20)
            make.height.equalTo(90)
        }
        
        collectionViewTours.snp.makeConstraints { make in
            make.top.equalTo(calendar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide)
        }
        
    }
    
    private func formatDateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM, YYYY г. EEEE"
        dateFormatter.locale = Locale(identifier: "ru_RU") // Установка русской локали для названия месяцев и дней недели

        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }

}

extension ToursView:JTACMonthViewDataSource{
    func configureCalendar(_ calendar: JTAppleCalendar.JTACMonthView) -> JTAppleCalendar.ConfigurationParameters {
        
        var calendarTime = Calendar.current
        calendarTime.timeZone = .current
        
        let startDate = calendarTime.date(byAdding: .year, value: -1, to: Date.now)!
        let endDate = calendarTime.date(byAdding: .year, value: 1, to: Date.now)!
                
        self.startDate = startDate
        self.endDate = endDate
                                
        return JTAppleCalendar.ConfigurationParameters(
            startDate: startDate,
            endDate: endDate,
            numberOfRows: 1,
            calendar: calendarTime,
            generateInDates: .forFirstMonthOnly,
            generateOutDates: .off,
            firstDayOfWeek: .monday,
            hasStrictBoundaries: false
        )
        
    }
    
}

extension ToursView:JTACMonthViewDelegate{
    
    func calendar(_ calendar: JTAppleCalendar.JTACMonthView, willDisplay cell: JTAppleCalendar.JTACDayCell, forItemAt date: Date, cellState: JTAppleCalendar.CellState, indexPath: IndexPath) {
        
    }
        
    func calendar(_ calendar: JTAppleCalendar.JTACMonthView, cellForItemAt date: Date, cellState: JTAppleCalendar.CellState, indexPath: IndexPath) -> JTAppleCalendar.JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        cell.configureCell(cellState: cellState)
        
        cell.configureEvents(viewDelegate.getEventsForDate(date: date))
        
        self.collectionViewTours.reloadItems(at: [indexPath])
        
        return cell
    }
    
    func calendar(_ calendar: JTACMonthView, shouldSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) -> Bool {
                
        if cellState.isSelected {
            calendar.deselectAllDates()
            self.calendar.scrollToDate(Date.now,animateScroll: true)
            self.selectedDate = Date.now
            calendar.selectDates([Date.now], triggerSelectionDelegate: true)
            
            return false
        }
        calendar.deselectAllDates()
        return true
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        didSelectDate?(indexPath, date)
        
        if let cell = cell as? CalendarCell{
            cell.select(animated: true)
            self.selectedDate = date
            
            if self.isFirstLoad{
                self.isFirstLoad = false
                let numOfSections = self.calendar.numberOfSections
                
                // more
                var currentCalendar = Calendar.current
                currentCalendar.timeZone = .current
                                
                var addedDate = currentCalendar.date(byAdding: .day, value: -indexPath.row, to: date) ?? Date.now
                                
                for section in indexPath.section..<numOfSections{
                    var newIndexPath = IndexPath(row: 0, section: section)
                    let numOfItems = calendar.numberOfItems(inSection: section)
                    for row in 0..<numOfItems{
                        newIndexPath.row = row
                        
                        self.indexPathAndDates[newIndexPath] = addedDate
                        self.datesIndexPath[addedDate] = newIndexPath
                        addedDate = currentCalendar.date(byAdding: .day, value: 1, to: addedDate) ?? Date.now
                    }
                }
                
                // less
                addedDate = currentCalendar.date(byAdding: .day, value: -indexPath.row - 1, to: date) ?? Date.now

                let range = 0...(indexPath.section - 1)
                let reversedRange = range.reversed()
                for section in reversedRange{
                    var newIndexPath = IndexPath(row: 0, section: section)
                    
                    let rangeInside = 0..<calendar.numberOfItems(inSection: section)
                    let reversedRangeInside = rangeInside.reversed()
                    
                    for row in reversedRangeInside{
                        newIndexPath.row = row
                        
                        self.indexPathAndDates[newIndexPath] = addedDate
                        self.datesIndexPath[addedDate] = newIndexPath
                        addedDate = currentCalendar.date(byAdding: .day, value: -1, to: addedDate) ?? Date.now
                        
                    }
                }
                
            }
            
        }
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        if let cell = cell as? CalendarCell{
            cell.deselect(animated: true)
        }
    }
    
    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        let startDate = visibleDates.monthDates.first?.date ?? Date.now
        let endDate = visibleDates.monthDates.last?.date ?? Date.now
        self.viewDelegate.loadEvents(startDate: startDate, endDate: endDate)
    }
    
        
}

import SwiftUI
#Preview(body: {
    ToursView().showPreview()
})
