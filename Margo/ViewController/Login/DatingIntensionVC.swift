//
//  DatingIntensionVC.swift
//  Margo
//
//  Created by Lenovo on 09/01/25.
//

import UIKit
import GDCheckbox

class DatingIntensionVC: UIViewController {

    @IBOutlet weak var tblIntension: UITableView!
    @IBOutlet weak var vwDropShadow: UIView!
    @IBOutlet weak var vwCheckBox: GDCheckbox!
    
    var selectedIndex: Int?
    var selInt: String?
    var datInt = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        vwDropShadow.addBottomShadow()
        datInt = SBText.Other.datingIntensions
        SignUpData.shared.DatingIntentionsVisible = 0
        tblIntension.delegate = self
        tblIntension.dataSource = self
        tblIntension.register(cellType: DatingIntensionCell.self)
        tblIntension.reloadData()
    }
    @IBAction func btnContinueAction(_ sender: UIButton) {
        SignUpData.shared.DatingIntension = selInt ?? ""
        let VC = storyboard?.instantiateViewController(withIdentifier: "PortraitsVC") as! PortraitsVC
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func onCheckBoxPress(_ sender: GDCheckbox) {
        SignUpData.shared.DatingIntentionsVisible = sender.isOn ? 1 : 0
        // Trigger action
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension DatingIntensionVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datInt.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let cell = tblIntension.dequeueReusableCell(with: DatingIntensionCell.self, for: indexPath)
        cell.selectionStyle = .none
        cell.lblIntension.text = datInt[indexPath.row]
        cell.vwRadio.isOn = (indexPath.row == selectedIndex)
        cell.radioButtonClick = { [weak self] in
            self?.updateSelectedIndex(indexPath: indexPath, tableView: tableView)
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          selectedIndex = indexPath.row
        selInt = datInt[indexPath.row]
          tableView.reloadData()
      }
    
    private func updateSelectedIndex(indexPath: IndexPath, tableView: UITableView) {
        selectedIndex = indexPath.row
        selInt = datInt[indexPath.row]
        tableView.reloadData()
    }
}
