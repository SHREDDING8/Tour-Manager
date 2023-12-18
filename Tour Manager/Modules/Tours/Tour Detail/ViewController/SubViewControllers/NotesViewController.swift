//
//  NotesViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 20.10.2023.
//

import UIKit
import SnapKit

final class NotesViewController: BaseViewController {
    
    var isGuide:Bool = false
    
    public lazy var textView:UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor(resource: .background)
        textView.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textView.isSelectable = true
        textView.isScrollEnabled = true
        textView.dataDetectorTypes = [.phoneNumber]
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
        textView.addDoneCancelToolbar()
        return textView
    }()
    
    
    var doAfterClose: ((String)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureTextView()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isGuide{
            self.textView.becomeFirstResponder()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        doAfterClose?(self.textView.text)
    }
    
    func configureView(){
        self.titleString = "Заметки"
        self.setBackButton()
        self.view.backgroundColor = UIColor(resource: .background)
        
        if !isGuide{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "pencil.tip.crop.circle.badge.minus"), style: .plain, target: self, action: #selector(changeIsEditable))
        }
        
    }
    
    func configureTextView(){
        self.view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.leading.trailing.bottom.top.equalTo(self.view.safeAreaLayoutGuide)
        }
        if isGuide{
            textView.isEditable = false
        }
    }
    
    
    @objc func changeIsEditable(){
        if textView.isEditable{
            self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "pencil.tip.crop.circle.badge.plus")
            self.textView.resignFirstResponder()
            self.textView.isEditable = false
        }else{
            self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "pencil.tip.crop.circle.badge.minus")
            self.textView.isEditable = true
            self.textView.becomeFirstResponder()
        }
    }
    
}

//#if DEBUG
//import SwiftUI
//
//struct NotesViewController_Preview: PreviewProvider {
//    static var previews: some View {
//        NotesViewController().showPreview()
//    }
//}
//#endif
