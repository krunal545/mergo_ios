//
//  EmailVC.swift
//  Margo
//
//  Created by Dharmesh A Nagvadia on 18/01/25.
//

import UIKit

class EmailVC: UIViewController {

    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var vwDropShadow: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vwDropShadow.addBottomShadow()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func btnNextAction(_ sender: Any) {
        if tfEmail.text == "" {
            SBUtill.showToastWith("Enter your email.")
        }else {
            SignUpData.shared.Email = tfEmail.text!
            let VC = storyboard?.instantiateViewController(withIdentifier: "PermissionVC") as! PermissionVC
            self.navigationController?.pushViewController(VC, animated: true)
        }
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
