//
//  GenderSelectionVC.swift
//  Margo
//
//  Created by Dharmesh A Nagvadia on 18/01/25.
//

import UIKit

class GenderSelectionVC: UIViewController {

    @IBOutlet weak var vwDropShadow: UIView!
    @IBOutlet weak var btnMale: UIButton!
    @IBOutlet weak var btnFemale: UIButton!
    @IBOutlet weak var vwDatePicker: UIView!{
        didSet{
            self.vwDatePicker.isHidden = true
        }
    }
    
    @IBOutlet weak var btnDate: UIButton!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var btnNext: UIButton!
    var DateOfBrith = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SignUpData.shared.Gender = 0
        vwDropShadow.addBottomShadow()
        datePicker.datePickerMode = .date

        let calendar = Calendar.current
        let currentDate = Date()
        var dateComponents = DateComponents()
//        dateComponents.year = -80
//        if let minDate = calendar.date(byAdding: dateComponents, to: currentDate) {
//            datePicker.minimumDate = minDate
//        }
        dateComponents.year = -18
        if let maxDate = calendar.date(byAdding: dateComponents , to: currentDate) {
            datePicker.maximumDate = maxDate
        }
        // Do any additional setup after loading the view.
        
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.configureFirebasePushNotifications(UIApplication.shared) { granted in
                DispatchQueue.main.async {
                    
                }
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func btnGenderAction(_ sender: UIButton) {
        SignUpData.shared.Gender = sender.tag
        SignUpData.shared.Prefernce = sender.tag == 1 ? 0 : 1
        if sender.tag == 0 {
            btnMale.setTitleColor(UIColor.white, for: .normal)
            btnFemale.setTitleColor(UIColor.black, for: .normal)
            btnMale.setBackgroundImage(UIImage(named: "button_gradient"), for: .normal)
            btnFemale.setBackgroundImage(nil, for: .normal)
        }else{
            btnMale.setTitleColor(UIColor.black, for: .normal)
            btnFemale.setTitleColor(UIColor.white, for: .normal)
            btnMale.setBackgroundImage(nil, for: .normal)
            btnFemale.setBackgroundImage(UIImage(named: "button_gradient"), for: .normal)
        }
    }
    
    @IBAction func btnSelectDateAction(_ sender: Any) {
        vwDatePicker.isHidden = false
    }
    
    @IBAction func dateChangeValue(_ sender: UIDatePicker) {
        let selectedDate = sender.date

        let formattedDate = SBUtill.getStringFromDate1("d MMMM yyyy", date: selectedDate)
        btnDate.setTitle(formattedDate, for: .normal)

        let dobFormatter = DateFormatter()
        dobFormatter.dateFormat = "yyyy-MM-dd"
        dobFormatter.locale = Locale(identifier: "en_US")
        let dobString = dobFormatter.string(from: selectedDate)

        SignUpData.shared.DOB = dobString
        print("Selected Time: \(SignUpData.shared.DOB ?? "")")
    }

    
    @IBAction func btnDateDoneAction(_ sender: Any) {
        self.vwDatePicker.isHidden = true
    }
    
    @IBAction func btnPickerBackAction(_ sender: Any) {
        self.vwDatePicker.isHidden = true
    }
    
    @IBAction func btnNextAction(_ sender: Any) {
        if SignUpData.shared.DOB == "" || SignUpData.shared.DOB == nil{
            SBUtill.showToastWith("Please select your date of birth.")
            return
        }
        
        let VC = storyboard?.instantiateViewController(withIdentifier: "HeightSelectionVC") as! HeightSelectionVC
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
