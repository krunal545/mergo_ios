//
//  PrefrenceVC.swift
//  Margo
//
//  Created by Lenovo on 21/04/25.
//

import UIKit

class PrefrenceVC: UIViewController {

    @IBOutlet weak var btnBoth: UIButton!
    @IBOutlet weak var btnFemale: UIButton!
    @IBOutlet weak var btnMale: UIButton!
    var preference = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

   
    @IBAction func btnGenderAction(_ sender: UIButton) {
        preference = sender.tag
        if sender.tag == 0 {
            btnMale.setTitleColor(UIColor.white, for: .normal)
            btnFemale.setTitleColor(UIColor.black, for: .normal)
            btnBoth.setTitleColor(UIColor.black, for: .normal)
            btnMale.setBackgroundImage(UIImage(named: "button_gradient"), for: .normal)
            btnFemale.setBackgroundImage(nil, for: .normal)
            btnBoth.setBackgroundImage(nil, for: .normal)
        }else if sender.tag == 1{
            btnMale.setTitleColor(UIColor.black, for: .normal)
            btnBoth.setTitleColor(UIColor.black, for: .normal)
            btnFemale.setTitleColor(UIColor.white, for: .normal)
            btnMale.setBackgroundImage(nil, for: .normal)
            btnFemale.setBackgroundImage(UIImage(named: "button_gradient"), for: .normal)
            btnBoth.setBackgroundImage(nil, for: .normal)
        }else if sender.tag == 2{
            btnMale.setTitleColor(UIColor.black, for: .normal)
            btnFemale.setTitleColor(UIColor.black, for: .normal)
            btnBoth.setTitleColor(UIColor.white, for: .normal)
            btnMale.setBackgroundImage(nil, for: .normal)
            btnBoth.setBackgroundImage(UIImage(named: "button_gradient"), for: .normal)
            btnFemale.setBackgroundImage(nil, for: .normal)
        }
        
    }
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnNextAction(_ sender: Any) {
        
        SignUpData.shared.Prefernce = preference
        let VC = storyboard?.instantiateViewController(withIdentifier: "HeightSelectionVC") as! HeightSelectionVC
        self.navigationController?.pushViewController(VC, animated: true)
    }
}
