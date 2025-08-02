//
//  MobileNumaberVC.swift
//  Margo
//
//  Created by Lenovo on 10/01/25.
//

import UIKit
import FirebaseAuth
import CountryPickerView
import IQKeyboardManagerSwift

class MobileNumaberVC: UIViewController,UITextFieldDelegate {
 
    @IBOutlet weak var vwDropShadow: UIView!
    @IBOutlet weak var tfMobileNumber: UITextField!
    @IBOutlet weak var vwVerification: UIView!{
        didSet{
            vwVerification.isHidden = true
        }
    }
    @IBOutlet weak var tfVerificationCode: UITextField!
    @IBOutlet weak var vwCountryPicker: CountryPickerView!
    
    @IBOutlet weak var btnSendCode: UIButton!
    var verificationId = ""
    var countryCode = String()
    var user:User?
    override func viewDidLoad() {
        super.viewDidLoad()
        tfMobileNumber.delegate = self
        vwDropShadow.addBottomShadow()
        print("IQKeyboardManager enabled: \(IQKeyboardManager.shared.isEnabled)")
        
        let currentCountry = vwCountryPicker.selectedCountry
        countryCode = currentCountry.phoneCode
        vwCountryPicker.showCountryCodeInView = false
        vwCountryPicker.showPhoneCodeInView = true
        vwCountryPicker.dataSource = self
        vwCountryPicker.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    @IBAction func btnContinueAction(sender: UIButton) {
        SBUtill.showProgress()
        sender.isEnabled = false // prevent double-tap

        if sender.titleLabel?.text == "Send Code" {
            guard let phoneNumber = tfMobileNumber.text, !phoneNumber.isEmpty else {
                SBUtill.dismissProgress()
                SBUtill.showToastWith("Enter a valid phone number")
                sender.isEnabled = true
                return
            }
            
            let countryPhoneNumber = countryCode + phoneNumber
            
            // Test bypass
            if countryPhoneNumber == "+911234567890" {
                SBUtill.dismissProgress()
                self.verificationId = "test_verification_id"
                self.vwVerification.isHidden = false
                sender.setTitle("Verify", for: .normal)
                sender.isEnabled = true
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                PhoneAuthProvider.provider().verifyPhoneNumber(countryPhoneNumber, uiDelegate: nil) { verificationID, error in
                    DispatchQueue.main.async {
                        SBUtill.dismissProgress()
                        sender.isEnabled = true

                        if let error = error as NSError? {
                            let authError = AuthErrorCode(_nsError: error)
                            if authError.code == .webContextCancelled {
                                SBUtill.showToastWith("Verification was cancelled. Please try again.")
                            } else {
                                SBUtill.showToastWith(error.localizedDescription)
                            }
                            return
                        }

                        SBUtill.showToastWith("OTP sent successfully!")
                        self.verificationId = verificationID ?? ""
                        self.vwVerification.isHidden = false
                        sender.setTitle("Verify", for: .normal)
                    }
                }
            }

        } else {
            guard let otpCode = tfVerificationCode.text, !otpCode.isEmpty else {
                SBUtill.dismissProgress()
                SBUtill.showToastWith("Enter a valid OTP.")
                sender.isEnabled = true
                return
            }

            let phoneNumber = countryCode + (tfMobileNumber.text ?? "")

            // Test bypass
            if phoneNumber == "+911234567890" {
                if otpCode == "123456" {
                    print("Test number login successful!")
                    SignUpData.shared.CountryCode = self.countryCode
                    SignUpData.shared.PhoneNumber = self.tfMobileNumber.text
                    self.callSocialLoginApi(apple_ID: "", google_ID: "", phone_number: self.tfMobileNumber.text, email: "")
                    SBUtill.dismissProgress()
                } else {
                    SBUtill.showToastWith("Invalid test OTP")
                }
                sender.isEnabled = true
                return
            }

            let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: otpCode)

            Auth.auth().signIn(with: credential) { authResult, error in
                DispatchQueue.main.async {
                    SBUtill.dismissProgress()
                    sender.isEnabled = true

                    if let error = error {
                        SBUtill.showToastWith(error.localizedDescription)
                        return
                    }

                    print("Phone number login successful!")
                    SignUpData.shared.CountryCode = self.countryCode
                    SignUpData.shared.PhoneNumber = self.tfMobileNumber.text
                    self.callSocialLoginApi(apple_ID: "", google_ID: "", phone_number: self.tfMobileNumber.text, email: "")
                }
            }
        }
    }

    
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
       
    func callSocialLoginApi(apple_ID:String? = "",google_ID:String? = "",phone_number:String? = "",email:String? = ""){
        if SBUtill.reachable() {
            
            let params = ["apple_id" : apple_ID ?? "" ,
                          "google_id" : google_ID ?? "",
                          "phone_no" : phone_number ?? "",
                          "email" : email ?? "",
                          "device_token":SBGlobal.fcm,
                          "platform" : "IOS"] as [String : Any]
            
            ClSApi.GetJsonModelValue(completion: { (data) in
                DispatchQueue.main.async { [self] in
                    SBUtill.dismissProgress()
                    //                    data["success"].boolValue,
                    
                     if data["data"].dictionary != nil {
                        print("test")
                        
                        self.user = User(data["data"])
                        
                        if user?.id == 0 {
                            let UserSelectionVC = self.storyboard?.instantiateViewController(withIdentifier: "FirstNameVC") as! FirstNameVC
                            SignUpData.shared.apple_id = apple_ID
                            SignUpData.shared.google_id = google_ID
                            SignUpData.shared.PhoneNumber = phone_number
                            SignUpData.shared.Email = email
                            self.navigationController?.pushViewController(UserSelectionVC, animated: true)
                        }else{
                            self.user = User(data["data"])
                            if let userData = self.user{
                                userData.saveInUserDefaults()
                            }
                            UserDefault.set(self.user?.apiToken, forKey: DefaultKey.Token)
                            Global.user = self.user
                            Global.apiToken = self.user?.apiToken ?? ""
                        
                            SBUtill.moveToHome(Status: true)
                        }
                    }else {
                        SBUtill.showToastWith(data["message"].stringValue)
                    }
                }
            }, Tag: ClS.API.social_login, Prams: params, Method: ClS.post)
        }else {
            SBUtill.showToastWith(SBText.Message.noInternet)
        }
    }
//    MARK: - TextField Delegate
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        if textField == tfMobileNumber && textField.text != tfMobileNumber.text{
            btnSendCode.setTitle("Send Code", for: .normal)
        }
    }
}

extension MobileNumaberVC: CountryPickerViewDelegate, CountryPickerViewDataSource{
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        // Only countryPickerInternal has it's delegate set
        _ = "Selected Country"
        countryCode = country.phoneCode
       // SBUtill.showToastWith("\(title) \(message)")
    }
    
    private func countryPickerView(_ countryPickerView: CountryPickerView, willShow viewController: CountryPickerView) {
        let countryVc = CountryPickerViewController(style: .grouped)
        let navigationVC = UINavigationController(rootViewController: countryVc)
        self.present(navigationVC, animated: true)
    }
    
    func navigationTitle(in countryPickerView: CountryPickerView) -> String? {
        return "Select a Country"
    }
}
