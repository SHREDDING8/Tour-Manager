//
//  TourManadgmentViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 01.12.2023.
//

import UIKit
import AlertKit

final class TourManadgmentViewController: ToursBaseViewController {
    
    var presenter:ExcursionManadmentPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        self.delegate = self
        
        self.configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.loadTours(date: self.view().selectedDate)
    }
    
    private func configureView(){
        self.titleString = "Менеджмент"
        
        if self.presenter.isAccessLevel(key: .canWriteTourList){
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .add, primaryAction: UIAction(handler: { _ in
                
                let newExcursionController = TourManadmentAssembly.createNewTourController(isUpdate: false, dateTime: self.view().selectedDate)
                
                self.navigationController?.pushViewController(newExcursionController, animated: true)
            }))
        }
    }
    
}


// MARK: - BASEVIEW DATASOURCE

extension TourManadgmentViewController:ToursBaseViewControllerDataSource{
    func loadEventsForDates(startDate: Date, endDate: Date) {
        self.presenter.getExcursionsListByRangeFromServer(startDate: startDate, endDate: endDate)
    }
    
    func numberOfTours(inDate: Date) -> Int {
        
        return self.presenter.tours[inDate.birthdayToString()]?.count ?? 0
    }
    
    func loadTours(inDate: Date) {
        presenter.loadTours(date: inDate)
    }
    
}

extension TourManadgmentViewController:ToursBaseViewControllerDelegate{
    
    func tourCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, inDate: Date) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TourTableViewCell", for: indexPath) as! TourTableViewCell
        
        if let tour = presenter.tours[inDate.birthdayToString()]?[indexPath.row]{
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
            
            var statusColor:UIColor
            if statuses.contains(.cancel){
                statusColor = .systemRed
            } else if statuses.contains(.waiting){
                statusColor = .systemYellow
            } else if statuses.contains(.accept){
                statusColor = .systemGreen
            } else {
                statusColor = .systemBlue
            }
            
            cell.configure(
                time:tour.dateAndTime.timeToString(),
                title: tour.tourTitle,
                route: tour.route,
                guides: guides,
                numOfPeople: tour.numberOfPeople,
                customer: tour.customerCompanyName,
                statusColor: statusColor
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
            let newTourVC = TourManadmentAssembly.createNewTourController(isUpdate: true, model: tour)
            
            self.navigationController?.pushViewController(newTourVC, animated: true)
        }
    }
    
    func tourContextMenu(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint, inDate: Date) -> UIContextMenuConfiguration? {
        
        if let tour = presenter.tours[inDate.birthdayToString()]?[indexPath.row]{
            
            let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: {
                let newTourVC = TourManadmentAssembly.createNewTourController(isUpdate: true, model: tour)
                return newTourVC
            }) { elements in
                let delete = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                    
                    let alert = UIAlertController(title: "Вы уверены что хотите удалить экскурсию?", message: nil, preferredStyle: .actionSheet)
                    
                    let deleteButton = UIAlertAction(title: "Удалить", style: .destructive) { _ in
                        self.presenter.deleteTour(date: tour.dateAndTime, excursionId: tour.tourId)
                    }
                    
                    let cancel = UIAlertAction(title: "Отменить", style: .cancel)
                    
                    alert.addAction(deleteButton)
                    alert.addAction(cancel)
                    self.present(alert, animated: true)
                    
                }
                
                return UIMenu(options: .displayInline, children: [delete])
            }
            
            return configuration
            
        }
        
        return nil
        
    }
    
    func getEventsColorsForDate(date: Date) -> [UIColor]{
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
    
    
}

extension TourManadgmentViewController:ExcursionManadmentViewProtocol{
    func tourDeleted() {
        AlertKitAPI.present(
            title: "Экскурсия удалена",
            subtitle: nil,
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
    }
    

    func updateTours(date:Date) {
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
