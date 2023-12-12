//
//  GuideToursViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 05.12.2023.
//

import UIKit

final class GuideToursViewController: ToursBaseViewController {
    var presenter:ExcursionsGuideCalendarPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isGuide = true

        self.dataSource = self
        self.delegate = self
        
        self.titleString = "Мои экскурсии"
    }
    
}

extension GuideToursViewController:ToursBaseViewControllerDataSource{
    func numberOfTours(inDate: Date) -> Int {
        return self.presenter.tours[inDate.birthdayToString()]?.count ?? 0
    }
    
    func loadTours(inDate: Date) {
        presenter.loadTours(date: inDate)
    }
    
    func loadEventsForDates(startDate: Date, endDate: Date) {
        self.presenter.getExcursionsListByRangeFromServer(startDate: startDate, endDate: endDate)
    }
    
    
}
                                        
extension GuideToursViewController:ToursBaseViewControllerDelegate{
    
    func tourCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, inDate: Date) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TourTableViewCell", for: indexPath) as! TourTableViewCell
        
        if let tour = presenter.tours[inDate.birthdayToString()]?[indexPath.row]{
            
            var guides = ""
            var status:UIColor = .systemBlue
            
            for guide in tour.guides{
                guides += guide.firstName + " " + guide.lastName + ", "
                
                let keychain = KeychainService()
                if guide.id == keychain.getLocalId(){
                    status = guide.status.getColor()
                }
                
            }
            
            if guides.count > 2{
                guides.removeLast()
                guides.removeLast()
                
            }else{
                status = .systemBlue
            }
            
            cell.configure(
                time: tour.dateAndTime.timeToString(),
                title: tour.tourTitle,
                route: tour.route,
                guides: guides,
                numOfPeople: tour.numberOfPeople,
                customer: tour.customerCompanyName,
                statusColor: status,
                isGuide: true
            )
            
            
            if tour.dateAndTime < Date.now{
                cell.contentView.layer.opacity = 0.5
            }else{
                cell.contentView.layer.opacity = 1
            }
        }
        
        
        return cell
    }
    
    func tourDidSelect(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, inDate: Date) {
        if let tour = presenter.tours[inDate.birthdayToString()]?[indexPath.row]{
            
            let destination = TourManadmentAssembly.createTourForGuideViewController(tour: tour)
            self.navigationController?.pushViewController(destination, animated: true)
        }
    }
    
    
    func tourContextMenu(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint, inDate: Date) -> UIContextMenuConfiguration? {
        return nil
    }
    
    func getEventsColorsForDate(date: Date) -> [UIColor] {
        var eventsColors:[UIColor] = []
        
        if let event = presenter.getEvent(tourDate: date){
            if event.waiting{
                eventsColors.append(.systemYellow)
            }
            if event.cancel{
                eventsColors.append(.systemRed)
            }
            
            if event.accept{
                eventsColors.append(.systemGreen)
            }
        }
        
        return eventsColors
    }
    
    
}

extension GuideToursViewController:ExcursionsGuideCalendarViewProtocol{
    func updateTours(date: Date) {
        self.reloadTours(inDate: date)
    }
    
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
