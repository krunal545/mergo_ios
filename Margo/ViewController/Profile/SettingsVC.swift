//
//  SettingsVC.swift
//  Margo
//
//  Created by Dharmesh A Nagvadia on 27/01/25.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class SettingsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
//    MARK: - Methods
    func callLogoutAPI(){
        if SBUtill.reachable() {
            SBUtill.showProgress()
            
            ClSApi.GetJsonModelValue(completion: { data in
                DispatchQueue.main.async {
                    SBUtill.dismissProgress()
                    if (data["data"].dictionary != nil){
                        print("test")
                        SBUtill.logOut()
                        SBUtill.moveToHome(Status: false)
                    }else {
                        SBUtill.showToastWith(data["message"].stringValue)
                    }
                }
                
            }, Tag: ClS.API.logout, Prams: nil, Method: ClS.post)
        }
    }
    
    func callDeleteAccountAPI(){
        if SBUtill.reachable() {
            SBUtill.showProgress()
            
            ClSApi.GetJsonModelValue(completion: { data in
                DispatchQueue.main.async {
                    SBUtill.dismissProgress()
                    if (data["data"].dictionary != nil){
                        SBUtill.logOut()
                        SBUtill.moveToHome(Status: false)
                    }else {
                        SBUtill.showToastWith(data["message"].stringValue)
                    }
                }
                
            }, Tag: ClS.API.delete_account, Prams: nil, Method: ClS.post)
        }
    }
    
//  MARK: - Action Methods
    
    @IBAction func btnNotificationAction(_ sender: Any) {
        let NotificationVC = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        self.navigationController?.pushViewController(NotificationVC, animated: true)
    }
    @IBAction func btnContactUsAction(_ sender: Any) {
        let ContactUsVC = self.storyboard?.instantiateViewController(withIdentifier: "ContactUsVC") as! ContactUsVC
        self.navigationController?.pushViewController(ContactUsVC, animated: true)
    }
    @IBAction func btnTermsConditionsAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Terms_ConditionsVC") as! Terms_ConditionsVC
        vc.htmlString = SignUpData.shared.termsAndCondition ?? ""
        vc.isFromTermsCondition = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnPrivacyAction(_ sender: UIButton) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "Terms_ConditionsVC") as! Terms_ConditionsVC
        VC.htmlString = Global.terms_and_conditions
        self.navigationController?.pushViewController(VC, animated: true)
    }
    @IBAction func btnLogoutAction(_ sender: Any) {
        let alertController =  UIAlertController(title: AppName, message: Text.Message.logout, preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: Text.Label.logout, style: UIAlertAction.Style.default, handler: { (ACTION :UIAlertAction!)in
            self.callLogoutAPI()
        }))
        
        alertController.addAction(UIAlertAction(title: Text.Label.cancel, style: UIAlertAction.Style.cancel, handler: { (ACTION :UIAlertAction!)in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func btnDeleteAccountAction(_ sender: Any) {
        let alertController =  UIAlertController(title: AppName, message: Text.Message.delete_Account, preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: Text.Label.delete, style: UIAlertAction.Style.default, handler: { (ACTION :UIAlertAction!)in
            self.callDeleteAccountAPI()
        }))
        
        alertController.addAction(UIAlertAction(title: Text.Label.cancel, style: UIAlertAction.Style.cancel, handler: { (ACTION :UIAlertAction!)in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
