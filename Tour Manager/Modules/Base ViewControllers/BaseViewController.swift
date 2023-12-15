//
//  BaseViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 11.12.2023.
//

import UIKit
import SnapKit
import AlertKit

import Network
import os

protocol BaseViewControllerProtocol{
    func setUpdating()
    func stopUpdating()
    
    func setLoading()
    func stopLoading()
    
    func setSaving()
    func stopSaving()
    
    func showLoadingView()
    func stopLoadingView()
    
    func showError(error:NetworkServiceHelper.NetworkError)
}

class BaseViewController: UIViewController {
    enum TitleStates{
        case normal
        case noConnection
        case updating
        case loading
        case saving
    }
    
    private var monitor:NWPathMonitor?
    private static var isNoConnectionAlertShowed = false
    private var titleState:TitleStates = .normal
    
    var keyboardIsShowed:Bool = false

    
    internal var titleString:String = ""{
        didSet{
            if titleState == .normal{
                self.titleViewLabel.text = self.titleString
                self.activity.stopAnimating()
            }
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
    
    private lazy var loadingView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(resource: .background)
        view.layer.opacity = 0
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        
        activityIndicator.style = .medium
        
        view.addSubview(activityIndicator)
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        return view
    }()

    internal func navigationController() -> BaseNavigationViewController?{
        return self.navigationController as? BaseNavigationViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(loadingView)
        
        loadingView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        self.titleViewStack.addArrangedSubview(titleViewLabel)
        self.titleViewStack.addArrangedSubview(activity)
        
        self.navigationItem.titleView = titleViewStack

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.listenConnection()
        self.addKeyboardObservers()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopListenConnection()
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc fileprivate func keyboardWillShow(notification: NSNotification){
        if keyboardIsShowed { return }
        if let activeTextField = UIResponder.currentFirstResponder as? UITextField, let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            // Теперь у вас есть ссылка на активное поле ввода
            let textFieldFrame = activeTextField.convert(activeTextField.bounds, to: self.view)
            print(textFieldFrame.maxY, keyboardSize.origin.y)
            if textFieldFrame.maxY + 50 > keyboardSize.origin.y{
                keyboardIsShowed = true
                self.navigationController?.navigationBar.layer.opacity = 0
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                view.frame.origin.y -= (textFieldFrame.maxY + 50 - keyboardSize.origin.y)
            }
        }
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if keyboardIsShowed{
            view.frame.origin.y = 0
            self.navigationController?.navigationBar.layer.opacity = 1
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            keyboardIsShowed = false
        }
        
    }
    
    public func setBackButton(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButtonView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(popView))
        self.navigationItem.leftBarButtonItem?.customView?.addGestureRecognizer(tapGesture)
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
    }
    
    
    @objc internal dynamic func popView(){
        self.navigationController()?.popViewController(animated: true)
    }
    
}

extension BaseViewController:UIGestureRecognizerDelegate{
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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
                    os_log(.debug, log: .default, "connect")
                    
                    BaseViewController.isNoConnectionAlertShowed = false
                    self.titleViewLabel.text = self.titleString
                    self.activity.stopAnimating()
                    self.titleState = .normal
                }
                
            } else {
                DispatchQueue.main.sync {
                    os_log(.error, log: .default, "disconnect")
                    
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
    
    func setLoading(){
        if self.titleState != .noConnection{
            self.titleViewLabel.text = "Загрузка"
            self.activity.startAnimating()
            self.titleState = .loading
        }
    }
    func stopLoading(){
        if self.titleState == .loading{
            self.titleViewLabel.text = self.titleString
            self.activity.stopAnimating()
            self.titleState = .normal
        }
    }
    
    func setSaving(){
        if self.titleState != .noConnection{
            self.titleViewLabel.text = "Сохранение"
            self.activity.startAnimating()
            self.titleState = .saving
        }
    }
    func stopSaving(){
        if self.titleState == .saving{
            self.titleViewLabel.text = self.titleString
            self.activity.stopAnimating()
            self.titleState = .normal
        }
    }
    
    func showLoadingView(){
        let indicator = self.loadingView.subviews[0] as? UIActivityIndicatorView
        indicator?.startAnimating()
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
        
        self.view.bringSubviewToFront(loadingView)
        UIView.animate(withDuration: 0.3) {
            self.loadingView.layer.opacity = 0.7
        }
    }
    
    func stopLoadingView(){
        let indicator = self.loadingView.subviews[0] as? UIActivityIndicatorView
        indicator?.stopAnimating()
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        self.tabBarController?.tabBar.isUserInteractionEnabled = true
        
        self.view.sendSubviewToBack(loadingView)
        UIView.animate(withDuration: 0.3) {
            self.loadingView.layer.opacity = 0
        }
    }
    
    func showError(error:NetworkServiceHelper.NetworkError){
        DispatchQueue.main.async {
            
            let errorBody = error.getAlertBody()
            
            if error == .tokenExpired ||
                error == .invalidFirebaseIdToken ||
                error == .TOKEN_EXPIRED ||
                error == .USER_DISABLED ||
                error == .USER_NOT_FOUND ||
                error == .INVALID_REFRESH_TOKEN{
                
                let alert = UIAlertController(
                    title: errorBody.title,
                    message: errorBody.msg,
                    preferredStyle: .alert
                )
                let logOut = UIAlertAction(title: "Выйти", style: .destructive) { _ in
                    MainAssembly.goToLoginPage(view: self.view)
                }
                
                alert.addAction(logOut)
                self.present(alert, animated: true)
                return
            }
            
            if error == .noConnection{
                if BaseViewController.isNoConnectionAlertShowed{
                    return
                }
                BaseViewController.isNoConnectionAlertShowed = true
            }
            
            AlertKitAPI.present(
                title: errorBody.title,
                subtitle: errorBody.msg,
                icon: .error,
                style: .iOS17AppleMusic,
                haptic: .error
            )
        }
    }
}


