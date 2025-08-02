//
//  Terms_ConditionsVC.swift
//  Margo
//
//  Created by xuser on 10/02/25.
//

import UIKit
import WebKit

class Terms_ConditionsVC: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var lblPrivacyPolicy: UILabel!
    
    var URLString = ""
    var htmlString = ""
    var isFromTermsCondition = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.uiDelegate = self
        webView.navigationDelegate = self
        self.view.isUserInteractionEnabled = false
        
        if isFromTermsCondition{
            lblPrivacyPolicy.text = "Terms of Service"
        }else{
            lblPrivacyPolicy.text = "Privacy Policy"
        }
        
        
        SBUtill.showProgress()
        if !htmlString.isEmpty, let url = URL(string: htmlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        } else {
            webView.loadHTMLString(htmlString, baseURL: nil)
        }
    }
//    MARK: - Action Methods
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}
extension Terms_ConditionsVC : WKUIDelegate ,WKNavigationDelegate{
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
        debugPrint("didCommit")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        self.view.isUserInteractionEnabled = true
        SBUtill.dismissProgress()
        debugPrint("didFinish")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        SBUtill.dismissProgress()
        debugPrint("didFail")
    }
}
