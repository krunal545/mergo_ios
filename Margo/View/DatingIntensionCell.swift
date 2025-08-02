//
//  DatingIntensionCell.swift
//  Margo
//
//  Created by Lenovo on 09/01/25.
//

import UIKit
import GDCheckbox

class DatingIntensionCell: UITableViewCell {

    @IBOutlet weak var lblIntension: UILabel!
    @IBOutlet weak var vwRadio: GDCheckbox!
    var radioButtonClick: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        vwRadio.isMultipleTouchEnabled = false
        vwRadio.isRadioButton = true

    }

    @IBAction func btnRadioButton(_ sender: GDCheckbox) {
        radioButtonClick?()
    }
    
}
