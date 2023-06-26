//
//  ExcursionForGuideTableViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 19.06.2023.
//

import UIKit

class ExcursionForGuideTableViewController: UITableViewController {
    
    var excursion = Excursion()
    
    let alerts = Alert()
    
    let excursionModel = ExcursionsControllerModel()
    
    let user = AppDelegate.user
    
    // MARK: - Outlets
    
    @IBOutlet weak var excursionNameLabel: UILabel!
    
    @IBOutlet weak var routeLabel: UILabel!
    
    @IBOutlet weak var numberOfPeopleLabel: UILabel!
    
    @IBOutlet weak var notesTextView: UITextView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var customerGuideName: UILabel!
    
    @IBOutlet weak var customerGuideContact: UILabel!
    
    @IBOutlet weak var isPaidSwitch: UISwitch!
    
    @IBOutlet weak var paymentAmountLabel: UILabel!
    
    
    @IBOutlet weak var guidesCollectionView: UICollectionView!
    
    
    let acceptUIView = {
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        
        let blur = UIBlurEffect(style: .systemChromeMaterialDark)
        var blurView = UIVisualEffectView(effect: blur)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(blurView)
        
        
        NSLayoutConstraint.activate([
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
        
                
        let aceptButton = UIButton()
        aceptButton.setTitle("Принять", for: .normal)
        aceptButton.tag = 1
        aceptButton.translatesAutoresizingMaskIntoConstraints = false
        aceptButton.backgroundColor = .clear
        aceptButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        aceptButton.configuration = .filled()
        aceptButton.tintColor = .white
        aceptButton.configuration?.imagePlacement = .trailing
        aceptButton.configuration?.cornerStyle = .large
        aceptButton.configuration?.baseBackgroundColor = .systemGreen
        view.addSubview(aceptButton)
        
        
        let cancelButton = UIButton()
        cancelButton.setTitle("Отклонить", for: .normal)
        cancelButton.tag = 2
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.backgroundColor = .clear
        cancelButton.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        cancelButton.configuration = .filled()
        cancelButton.tintColor = .white
        cancelButton.configuration?.imagePlacement = .trailing
        cancelButton.configuration?.cornerStyle = .large
        cancelButton.configuration?.baseBackgroundColor = .systemRed
        view.addSubview(cancelButton)
        
        return view
    }()
    
    var heightConstaint:NSLayoutConstraint!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureValues()
        
        self.tabBarController?.tabBar.backgroundColor = .white
        
        self.navigationItem.title = excursion.excursionName
        self.navigationController?.navigationBar.backgroundColor = .white
        
        self.navigationItem.largeTitleDisplayMode = .always
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // 3.
        configureAcceptView()
        
        for guide in excursion.selfGuides{
            if guide.guideInfo == self.user && guide.status == .waiting{
                UIView.animate(withDuration: 0.3) {
                    self.tabBarController?.tabBar.layer.opacity = 0
                    self.acceptUIView.layer.opacity = 1
                }
                UIView.transition(with: self.acceptUIView, duration: 0.3) {
                    self.heightConstaint.constant = self.view.frame.height / 4
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.view.bringSubviewToFront(acceptUIView)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.animate(withDuration: 0.3) {
            self.tabBarController?.tabBar.layer.opacity = 1
        }
    }
    
    
    fileprivate func configureAcceptView(){
        self.view.superview!.addSubview(self.acceptUIView)
        let acceptButton = self.acceptUIView.viewWithTag(1)! as! UIButton
        let cancelButton = self.acceptUIView.viewWithTag(2)! as! UIButton
        self.acceptUIView.layer.opacity = 0
        
        acceptButton.addAction(UIAction(handler: { _ in
            self.excursionModel.setGuideTourStatus(token: self.user?.getToken() ?? "", uid: self.user?.getToken() ?? "", companyId: self.user?.company.getLocalIDCompany() ?? "" , tourDate: self.excursion.dateAndTime.birthdayToString(), tourId: self.excursion.localId ?? "", guideStatus: .accepted) { isSetted, error in
                
                if let err = error{
                    self.alerts.errorAlert(self, errorExcursionsApi: err)
                }
                
                if isSetted{
                    UIView.animate(withDuration: 0.3) {
                        self.tabBarController?.tabBar.layer.opacity = 1
                        self.acceptUIView.layer.opacity = 0
                    }
                    UIView.transition(with: self.acceptUIView, duration: 0.3) {
                        self.heightConstaint.constant = 0
                        self.view.layoutIfNeeded()
                    }
                }
            }
        }), for: .touchUpInside)
        
        cancelButton.addAction(UIAction(handler: { _ in
            self.excursionModel.setGuideTourStatus(token: self.user?.getToken() ?? "", uid: self.user?.getToken() ?? "", companyId: self.user?.company.getLocalIDCompany() ?? "" , tourDate: self.excursion.dateAndTime.birthdayToString(), tourId: self.excursion.localId ?? "", guideStatus: .cancel) { isSetted, error in
                
                if let err = error{
                    self.alerts.errorAlert(self, errorExcursionsApi: err)
                }
                
                
                if isSetted{
                    UIView.animate(withDuration: 0.3) {
                        self.tabBarController?.tabBar.layer.opacity = 1
                        self.acceptUIView.layer.opacity = 0
                    }
                    UIView.transition(with: self.acceptUIView, duration: 0.3) {
                        self.heightConstaint.constant = 0
                        self.view.layoutIfNeeded()
                    }
                }
            }
        }), for: .touchUpInside)
        
        heightConstaint = NSLayoutConstraint(item: self.acceptUIView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        self.acceptUIView.addConstraint(heightConstaint)
        NSLayoutConstraint.activate([
            self.acceptUIView.bottomAnchor.constraint(equalTo: self.view.superview!.bottomAnchor,constant: 0),
            self.acceptUIView.leadingAnchor.constraint(equalTo: self.view.superview!.leadingAnchor),
            self.acceptUIView.trailingAnchor.constraint(equalTo: self.view.superview!.trailingAnchor),
        ])
        
        
        NSLayoutConstraint.activate([
            acceptButton.centerYAnchor.constraint(equalTo: acceptUIView.centerYAnchor),
            acceptButton.leadingAnchor.constraint(equalTo: acceptUIView.leadingAnchor, constant: 30),
            acceptButton.widthAnchor.constraint(equalToConstant: self.view.frame.width / 2 - 35),
            acceptButton.heightAnchor.constraint(equalToConstant: 50)
            
        ])
        
        NSLayoutConstraint.activate([
            cancelButton.centerYAnchor.constraint(equalTo: acceptUIView.centerYAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: acceptUIView.trailingAnchor, constant: -30),
            cancelButton.widthAnchor.constraint(equalToConstant: self.view.frame.width / 2 - 35),
            cancelButton.heightAnchor.constraint(equalToConstant: 50)
            
        ])
    }
    

    // MARK: - configureValues
    
    fileprivate func configureValues(){
        self.excursionNameLabel.text = excursion.excursionName
        self.routeLabel.text = excursion.route
        self.numberOfPeopleLabel.text = String(excursion.numberOfPeople)
        self.datePicker.date = excursion.dateAndTime
        self.notesTextView.text = excursion.additionalInfromation
        self.customerGuideName.text = excursion.customerGuideName
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
        
        let nib = UINib(nibName: "GuideCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "GuideCollectionViewCell")
                
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GuideCollectionViewCell", for: indexPath) as! GuideCollectionViewCell
        
        cell.fullName.text = self.excursion.selfGuides[indexPath.row].guideInfo.getFullName()
        if self.excursion.selfGuides[indexPath.row].isMain{
            cell.isMainGuide.isHidden = false
        }else{
            cell.isMainGuide.isHidden = true
        }
        
        cell.status.tintColor = self.excursion.selfGuides[indexPath.row].status.getColor()
        
        self.user?.downloadProfilePhoto(localId: self.excursion.selfGuides[indexPath.row].guideInfo.getLocalID() ?? "", completion: { data, error in
            if data != nil{
                UIView.transition(with: cell.profilePhoto, duration: 0.3, options: .transitionCrossDissolve) {
                    cell.profilePhoto.image = UIImage(data: data!)!
                }
            }
        })
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        
        return 0
    }
    
    
}
