//
//  ReportVC.swift
//  Margo
//
//  Created by Lenovo on 18/06/25.
//

import UIKit

protocol ReportVCDelegate: AnyObject {
    func didTapReport(userID: Int)
}

class ReportVC: UIViewController {
    
    var otherUserID = Int()
    weak var delegate: ReportVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnReportClick(_ sender: UIButton) {
        self.dismiss(animated: true)
        delegate?.didTapReport(userID: otherUserID)
    }
    
   
    
}
