//
//  ExcursionForGuideTableViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 19.06.2023.
//

import UIKit

class ExcursionForGuideTableViewController: UITableViewController {
    
    var excursion = Excursion()
    
    // MARK: - Outlets
    
    @IBOutlet weak var excursionNameLabel: UILabel!
    
    @IBOutlet weak var routeLabel: UILabel!
    
    @IBOutlet weak var numberOfPeopleLabel: UILabel!
    
    @IBOutlet weak var notesTextView: UITextView!
    
    
    @IBOutlet weak var customerGuideName: UILabel!
    
    @IBOutlet weak var customerGuideContact: UILabel!
    
    @IBOutlet weak var isPaidSwitch: UISwitch!
    
    @IBOutlet weak var paymentAmountLabel: UILabel!
    
    
    @IBOutlet weak var guidesCollectionView: UICollectionView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureValues()

    }
    
    
    // MARK: - configureValues
    
    fileprivate func configureValues(){
        self.excursionNameLabel.text = excursion.excursionName
        self.routeLabel.text = excursion.route
        self.numberOfPeopleLabel.text = String(excursion.numberOfPeople)
        self.notesTextView.text = excursion.additionalInfromation
        self.customerGuideName.text = excursion.customerCompanyName
        self.customerGuideContact.text = excursion.companyGuidePhone
        self.isPaidSwitch.isOn = excursion.isPaid
        self.paymentAmountLabel.text = String(excursion.paymentAmount)
        
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section{
        case 0: return 5 
        case 1: return 2
        case 2: return excursion.isPaid ? 1 : 2
        case 3: return 1
        default: return 0
        }
    }

}

extension ExcursionForGuideTableViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.excursion.selfGuides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "guiedCollectionViewCell", for: indexPath)
        
        let fullName = cell.viewWithTag(1) as! UILabel
        
        fullName.text =  self.excursion.selfGuides[indexPath.row].guideInfo.getFullName()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        
        return 0
    }
    
    
}
