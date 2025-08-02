//
//  TermsConditionVC.swift
//  Margo
//
//  Created by Lenovo on 17/06/25.
//

import UIKit

class TermsConditionVC: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var btnChekcBox: UIButton!
    @IBOutlet weak var btnAceept: UIButton!
    
    let htmlString  = """
<h2>App Name: Mergo</h2>
<p>By using Mergo, you agree to the following terms regarding user-generated content. These terms are intended to maintain a safe, respectful, and welcoming environment for all users.</p> 
 
<h3>1. Prohibited Content</h3>
<ul>
<li>Contains hate speech, harassment, or threats</li>
<li>Promotes violence, abuse, or discrimination</li>
<li>Is sexually explicit or pornographic</li>
<li>Includes spam, scams, or misleading information</li>
<li>Infringes on copyrights, trademarks, or any other legal rights</li>
<li>Violates any laws or regulations</li>
</ul>
 
<h3>2. User Agreement</h3>
<ul>
<li>You are solely responsible for the content you submit or share.</li>
<li>You will not post objectionable content or engage in abusive behavior.</li>
<li>Mergo enforces a zero-tolerance policy toward objectionable or harmful content.</li>
<li>Violations may result in content removal and account termination without notice.</li>
</ul>
 
<h3>3. Moderation and Reporting</h3>
<ul>
<li><strong>Content Filtering:</strong> We use automated and manual review to detect and filter objectionable material.</li>
<li><strong>Reporting Mechanism:</strong> Users can flag inappropriate content directly within the app.</li>
<li><strong>Action on Reports:</strong> Our moderation team reviews all flagged content within 24 hours. If the content violates our guidelines, it will be removed, and appropriate action will be taken against the user who submitted it.</li>
</ul>
 
<h3>4. Account Enforcement</h3>
<ul>
<li>Immediately remove content that violates these terms</li>
<li>Suspend or ban accounts involved in repeated or severe violations</li>
<li>Notify authorities if unlawful activity is detected</li>
</ul>
 
<h3>5. Changes to This Policy</h3>
<p>We may update these Terms and Conditions at any time. Continued use of Mergo implies acceptance of any changes.</p>
 
<h3>Contact Us</h3>
<p>To report a concern or ask a question, please contact us at:<br>
📞 +91 94826 40277<br>
📞 +91 81057 06840</p>
"""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let data = htmlString.data(using: .utf8) {
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]
            
            if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
                textView.attributedText = attributedString
            }
            
            btnChekcBox.setImage(UIImage(systemName: "square"), for: .normal)
            btnChekcBox.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        }
        
    }
    @IBAction func btnAcceptAction(_ sender: UIButton) {
         if btnChekcBox.isSelected == false{
            SBUtill.showToastWith("You must agree to the terms in order to proceed.")
         }else{
//             self.dismiss(animated: true)
             SBUtill.moveToHome(Status: true)

         }
    }
    
    
    @IBAction func btnCheckBoxAction(_ sender: UIButton) {
        btnChekcBox.isSelected.toggle()

    }
    
    @IBAction func btnCloseAction(_ sender: UIButton) {
        self.dismiss(animated: true)
        
    }
    
}
