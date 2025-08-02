//
//  FirstNameVC.swift
//  Margo
//
//  Created by Dharmesh A Nagvadia on 18/01/25.
//

import UIKit

class FirstNameVC: UIViewController {

    @IBOutlet weak var tfFirstname: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var vwDropShadow: UIView!
    
    var isFromAppleLogin = false
    var fname = ""
    var sname = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        vwDropShadow.addBottomShadow()
        
//        let vc = storyboard?.instantiateViewController(withIdentifier: "TermsConditionVC") as! TermsConditionVC
//        vc.modalTransitionStyle = .crossDissolve
//        vc.modalPresentationStyle = .overFullScreen
//        self.present(vc, animated: true)
        
        if isFromAppleLogin{
            tfFirstname.text = fname
            tfLastName.text = sname
        }
        
        
    }
    

  
    @IBAction func btnNextAction(_ sender: Any) {
        if tfFirstname.text == "" {
            SBUtill.showToastWith("Enter your first name")
        }else {
            SignUpData.shared.Name = tfFirstname.text!
            SignUpData.shared.LastName = tfLastName.text!
            let VC = storyboard?.instantiateViewController(withIdentifier: "NotificationPermissionVC") as! NotificationPermissionVC
            self.navigationController?.pushViewController(VC, animated: true)
        }
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
