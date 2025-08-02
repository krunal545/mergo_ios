//
//  ContactUsVC.swift
//  Margo
//
//  Created by xuser on 10/02/25.
//

import UIKit

class ContactUsVC: UIViewController {

    @IBOutlet weak var lblMail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleEmailTap))
        lblMail.addGestureRecognizer(tapGesture)
        
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
   
    @objc func handleEmailTap() {
        let email = lblMail.text
        let subject = ""
        
        if let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: "mailto:\(email ?? "")?subject=\(encodedSubject)") {
            UIApplication.shared.open(url)
        }
    }
}
