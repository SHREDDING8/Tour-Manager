//
//  ToursManadgmentViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 28.11.2023.
//

import UIKit

protocol ToursBaseViewControllerDataSource{
    func numberOfTours(inDate:Date) -> Int
    func loadTours(inDate:Date)
    func updateTours(inDate: Date)
    func loadEventsForDates(startDate:Date, endDate:Date)
}

protocol ToursBaseViewControllerDelegate{
    func tourCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, inDate:Date) -> UITableViewCell
    func tourDidSelect(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, inDate:Date)
    
    func tourContextMenu(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint, inDate:Date) -> UIContextMenuConfiguration?
    
    func getEventsColorsForDate(date: Date) -> [UIColor]
}

class ToursBaseViewController: BaseViewController {
    
    public var dataSource:ToursBaseViewControllerDataSource!
    public var delegate:ToursBaseViewControllerDelegate!
    
    public var isGuide:Bool = false
    
    private var isEndDeselerating:Bool = true
    private var beginScrollIndex:Int = 0
    private var currentPage:Int = 0
    
    internal func view() -> ToursView{
        return view as! ToursView
    }
    
    override func loadView() {
        super.loadView()
        self.view = ToursView()
        self.view().viewDelegate = self
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view().calendar(self.view().calendar, didScrollToDateSegmentWith: self.view().calendar.visibleDates())
                
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        addDelegates()
        self.view().collectionViewTours.reloadData()
        
        if let indexPath = self.view().calendar.selectedCells.first?.indexPath{
            self.view().collectionViewTours.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
        
        
        view().didSelectDate = { indexPath, date in
            self.view().collectionViewTours.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            self.dataSource.loadTours(inDate: date)
            self.isEndDeselerating = true
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "calendar"), style: .plain, target: self, action: #selector(showFullCalendar))
        
    }
        
    
    private func addDelegates(){
        self.view().collectionViewTours.delegate = self
        self.view().collectionViewTours.dataSource = self
    }
    
    public func reloadTours(inDate:Date){
        if let indexPath = self.view().datesIndexPath[inDate], let cell = self.view().collectionViewTours.cellForItem(at: indexPath) as? ToursCollectionViewCell{
            cell.tableView.refreshControl?.endRefreshing()
            cell.tableView.reloadSections([0], with: .none)
        }
    }
    
    public func endRefreshing(inDate:Date){
        if let indexPath = self.view().datesIndexPath[inDate], let cell = self.view().collectionViewTours.cellForItem(at: indexPath) as? ToursCollectionViewCell{
            cell.tableView.refreshControl?.endRefreshing()
        }
    }
    
    public func reloadDates(_ dates: [Date]){
        for date in dates {
            if let indexPath = self.view().datesIndexPath[date]{
                if let cell = self.view().calendar.cellForItem(at: indexPath) as? CalendarCell{
                    
                    cell.configureEvents(self.view().viewDelegate.getEventsForDate(date: date))
                }
            }
        }
    }
    
    @objc private func showFullCalendar(){
        if let navVc = (TourManadmentAssembly.createFullCalendarViewController(isGuide: isGuide) as? BaseNavigationViewController), let vc = navVc.viewControllers[0] as? FullCalendarViewController{
            vc.doAfterSelecting = { date in
                self.view().calendar.scrollToDate(date, animateScroll: true)
                self.view().selectedDate = date
                self.view().calendar.selectDates([date])
            }
            vc.startDate = self.view().selectedDate
            
            self.present(navVc, animated: true)
        }
        
    }
        
}

extension ToursBaseViewController:UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
                
        return self.view().calendar.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.view().calendar.numberOfItems(inSection: section)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ToursCollectionViewCell", for: indexPath) as! ToursCollectionViewCell
        cell.date = self.view().indexPathAndDates[indexPath] ?? Date.now
        
        cell.tableView.delegate = self
        cell.tableView.dataSource = self
        
        cell.tableView.refreshControl = UIRefreshControl(frame: .zero, primaryAction: UIAction(handler: { _ in
            self.refreshTableView(cell: cell)
            self.view().calendar.scrollToDate(cell.date)
        }))
        
        dataSource.loadTours(inDate: cell.date)
        cell.tableView.reloadSections([0], with: .none)
                
        return cell
    }
    
    func refreshTableView(cell:ToursCollectionViewCell){
        dataSource.updateTours(inDate: cell.date)
    }
}

extension ToursBaseViewController: UICollectionViewDelegate, UIScrollViewDelegate{
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == self.view().collectionViewTours {
            if isEndDeselerating{
                self.beginScrollIndex = Int((scrollView.contentOffset.x / scrollView.frame.width).rounded())
                isEndDeselerating = false
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.view().collectionViewTours {
            self.currentPage = Int((scrollView.contentOffset.x / scrollView.frame.width).rounded())
            let calendar = Calendar.current
            if currentPage != self.beginScrollIndex{
                if let modifiedDate = calendar.date(byAdding: .day, value: currentPage - self.beginScrollIndex, to: self.view().selectedDate){
                    
                    self.view().selectedDate = modifiedDate
                    self.view().calendar.selectDates([modifiedDate])
                    self.view().calendar.scrollToDate(modifiedDate, animateScroll: true)
                }
            }
            
            isEndDeselerating = true
        }
    }
    
}

extension ToursBaseViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}



extension ToursBaseViewController:UITableViewDataSource{
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let date = (tableView.superview?.superview as! ToursCollectionViewCell).date
        let number = self.dataSource.numberOfTours(inDate: date)
        let cell = (tableView.superview?.superview as! ToursCollectionViewCell)
        
        cell.placeHolder.layer.opacity = number == 0 ? 1 : 0
        return number

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = (tableView.superview?.superview as! ToursCollectionViewCell)
                
        return self.delegate.tourCell(tableView, cellForRowAt: indexPath, inDate: cell.date)
    }

    
}

extension ToursBaseViewController:UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.delegate.tourDidSelect(tableView, cellForRowAt: indexPath, inDate: (tableView.superview?.superview as! ToursCollectionViewCell).date)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return self.delegate.tourContextMenu(tableView, contextMenuConfigurationForRowAt: indexPath, point: point, inDate: (tableView.superview?.superview as! ToursCollectionViewCell).date)
    }
}

extension ToursBaseViewController:ToursViewDelegate{
    func loadEvents(startDate: Date, endDate: Date) {
        self.dataSource.loadEventsForDates(startDate: startDate, endDate: endDate)
    }
    
    func getEventsForDate(date: Date) -> [UIColor] {
        self.delegate.getEventsColorsForDate(date: date)
    }
}


