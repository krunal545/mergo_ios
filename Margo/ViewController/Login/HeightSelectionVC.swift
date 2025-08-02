//
//  HeightSelectionVC.swift
//  Margo
//
//  Created by Dharmesh A Nagvadia on 18/01/25.
//

import UIKit

class HeightSelectionVC: UIViewController {
    @IBOutlet weak var vwDropShadow: UIView!
    @IBOutlet weak var HeightPicker: UIPickerView!
    @IBOutlet weak var vwHeightPicker: UIView!{
        didSet {
            self.vwHeightPicker.isHidden = true
        }
    }
    @IBOutlet weak var btnSelectYourHeight: UIButton!
    
    
    var height_arr = ["less than 140 cm","141 cm","142 cm","143 cm","144 cm","145 cm","146 cm","147 cm","148 cm","149 cm","150 cm","151 cm","152 cm","153 cm","154 cm","155 cm","156 cm","157 cm","158 cm","159 cm","160 cm","161 cm","162 cm","163 cm","164 cm","165 cm","166 cm","167 cm","168 cm","169 cm","170 cm","171 cm","172 cm","173 cm","174 cm","175 cm","176 cm","177 cm","178 cm","179 cm","180 cm","181 cm","182 cm","183 cm","184 cm","185 cm","186 cm","187 cm","188 cm","189 cm",">190 cm"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vwDropShadow.addBottomShadow()
        HeightPicker.delegate = self
        HeightPicker.dataSource = self
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

    @IBAction func btnHeightAction(_ sender: Any) {
        vwHeightPicker.isHidden = false
    }
    
    @IBAction func btnDonePickerAction(_ sender: Any) {
        vwHeightPicker.isHidden = true
    }
    
    @IBAction func btnNextAction(_ sender: Any) {
        SignUpData.shared.DatingIntension = "0"
        let VC = storyboard?.instantiateViewController(withIdentifier: "PortraitsVC") as! PortraitsVC
        self.navigationController?.pushViewController(VC, animated: true)
//        let VC = storyboard?.instantiateViewController(withIdentifier: "DatingIntensionVC") as! DatingIntensionVC
//        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension HeightSelectionVC :UIPickerViewDelegate , UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Number of rows in the picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return height_arr.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    
        return height_arr[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Outfit-Regular", size: 15)
            pickerLabel?.textAlignment = .center
        }
        pickerLabel?.text = height_arr[row]
     
        return pickerLabel!
    }
    
    // Called when a row is selected
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Handle the selection if needed
        SignUpData.shared.Height = height_arr[row]
        btnSelectYourHeight.setTitle(height_arr[row], for: .normal)
    }
}
