//
//  BaseViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 11.12.2023.
//

import UIKit
import SnapKit

import Network

protocol BaseViewControllerProtocol{
    func setUpdating()
    func stopUpdating()
}

class BaseViewController: UIViewController {
    enum TitleStates{
        case normal
        case noConnection
        case updating
    }
    
    var monitor:NWPathMonitor?
    var titleState:TitleStates = .normal

    
    internal var titleString:String = ""{
        didSet{
            
        }
    }
    
    private lazy var backButtonView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(resource: .background)
        view.clipsToBounds = true
        view.layer.cornerRadius = 15
        
        let image = UIImageView(image: UIImage(systemName: "chevron.left"))
        image.tintColor = UIColor(resource: .blueText)
        image.contentMode = .scaleAspectFit
        
        view.addSubview(image)
        
        view.snp.makeConstraints { make in
            make.width.height.equalTo(30)
        }
        
        image.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        return view
    }()
    
    private var titleViewStack:UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalCentering
        stack.spacing = 10
        
        return stack
    }()
    
    private var titleViewLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.text = "test"
        
        return label
    }()
    
    private var activity:UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()

    internal func navigationController() -> BaseNavigationViewController?{
        return self.navigationController as? BaseNavigationViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
       
        
        self.titleViewStack.addArrangedSubview(titleViewLabel)
        self.titleViewStack.addArrangedSubview(activity)
        
        self.navigationItem.titleView = titleViewStack

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.listenConnection()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopListenConnection()
    }
    
    public func setBackButton(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButtonView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(popView))
        self.navigationItem.leftBarButtonItem?.customView?.addGestureRecognizer(tapGesture)
    }
    
    
    @objc private func popView(){
        self.navigationController()?.popViewController(animated: true)
    }
    
}

// MARK: - Check connection
extension BaseViewController{
    private func listenConnection(){
        monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "Monitor \(Int.random(in: Int.min...Int.max))")
        monitor?.start(queue: queue)

        monitor?.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.sync {
                    
                    self.titleViewLabel.text = self.titleString
                    self.activity.stopAnimating()
                    self.titleState = .normal
                }
                
            } else {
                DispatchQueue.main.sync {
                    self.titleViewLabel.text = "Соединение"
                    self.activity.startAnimating()
                    self.titleState = .noConnection
                }
            }

        }
    }
    
    private func stopListenConnection(){
        monitor?.cancel()
    }

}

extension BaseViewController:BaseViewControllerProtocol{
    func setUpdating() {
        if self.titleState != .noConnection{
            self.titleViewLabel.text = "Обновление"
            self.activity.startAnimating()
            self.titleState = .updating
        }
    }
    
    func stopUpdating() {
        if self.titleState == .updating{
            self.titleViewLabel.text = self.titleString
            self.activity.stopAnimating()
            self.titleState = .normal
        }
    }
    
    
}


