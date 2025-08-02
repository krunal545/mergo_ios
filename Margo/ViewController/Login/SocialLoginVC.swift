//
//  SocialLoginVC.swift
//  Margo
//
//  Created by Lenovo on 10/01/25.
//

import UIKit
import GoogleSignIn
import AuthenticationServices
import FirebaseAuth
import FirebaseCore

class SignUpData {
    static let shared = SignUpData()
    var Name:String?
    var LastName: String?
    var Email: String?
    var apple_id: String?
    var google_id: String?
    var Password: String?
    var CountryCode:String?
    var PhoneNumber:String?
    var Gender:Int?
    var Height:String?
    var DOB:String?
    var Lat:String?
    var Long:String?
    var City:String?
    var State:String?
    var Address:String?
    var DatingIntension:String?
    var DatingIntentionsVisible: Int?
    var Education:String?
    var Zodiac:String?
    var Profession:String?
    var Looking_For:Int?
    var Profile_Images: [UIImage] = []
    var SchoolName:String?
    var CompanyName:String?
    var Lang:String?
    var Prefernce:Int?
    var notification:String?
    var termsAndCondition: String?
    private init() {}
}

class SocialLoginVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var txtViewIntro: UITextView!
    @IBOutlet weak var lblIntro: UILabel!
    var user:User?
    var fname = ""
    var sname = ""
    let termsAndConditionsURL =  "action://terms";
     let privacyURL = "http://www.example.com/privacy";
    override func viewDidLoad() {
        super.viewDidLoad()
        txtViewIntro.delegate = self
        setupLabel()
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
    }
//    MARK: - Methods
    func setupLabel() {
        let str = "By using this app you agree to our Terms and Conditions and Privacy Policy"
        let attributedString = NSMutableAttributedString(string: str)

        let fullFont = UIFont(name: "Futura-Medium", size: 15.0) ?? UIFont.systemFont(ofSize: 15)
        let boldFont = UIFont(name: "Futura-Bold", size: 15.0) ?? UIFont.boldSystemFont(ofSize: 15)
        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: str.count))
        attributedString.addAttribute(.font, value: fullFont, range: NSRange(location: 0, length: str.count))

        let termsRange = (str as NSString).range(of: "Terms and Conditions")
        attributedString.addAttribute(.link, value: "action://terms", range: termsRange)
        attributedString.addAttribute(.font, value: boldFont, range: termsRange)
        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: termsRange)
        let privacyRange = (str as NSString).range(of: "Privacy Policy")
        attributedString.addAttribute(.link, value: "action://privacy", range: privacyRange)
        attributedString.addAttribute(.font, value: boldFont, range: privacyRange)
        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: privacyRange)

        txtViewIntro.attributedText = attributedString

        txtViewIntro.linkTextAttributes = [
            .foregroundColor: UIColor.white,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]

        txtViewIntro.isEditable = false
        txtViewIntro.isScrollEnabled = false
        txtViewIntro.dataDetectorTypes = []
        txtViewIntro.backgroundColor = .clear
        txtViewIntro.textAlignment = .center
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let termsStoryboard = UIStoryboard(name: "TabBar", bundle: nil)
        let vc = termsStoryboard.instantiateViewController(withIdentifier: "Terms_ConditionsVC") as! Terms_ConditionsVC

        if URL.absoluteString == "action://terms" {
            vc.htmlString = SignUpData.shared.termsAndCondition ?? ""
            vc.isFromTermsCondition = true
        } else if URL.absoluteString == "action://privacy" {
            vc.htmlString = Global.terms_and_conditions
            vc.isFromTermsCondition = false
        }

        self.navigationController?.pushViewController(vc, animated: true)
        return false
    }
    
//    MARK: - Action Methods

    
    @IBAction func btnAppleLoginAction(_ sender: UIButton) {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    
    
    @IBAction func btnGoogleLoginAction(_ sender: UIButton) {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {return}
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {return}
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { [self] result, error in
                if error == nil {
                    print(result as Any)
                    print("Google Login User Name :-\(result?.user.email ?? "")")
                    // result?.user.
                    let userInfo = result?.user
                    self.fname = userInfo?.displayName ?? ""
                    self.sname = ""
                    callSocialLoginApi(google_ID: userInfo?.uid, email: userInfo?.email)
                }else{
                    print(error?.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func btnMobileNoLogin(_ sender: UIButton) {
        let VC = storyboard?.instantiateViewController(withIdentifier: "MobileNumaberVC") as! MobileNumaberVC
        self.navigationController?.pushViewController(VC, animated: true)
        
    }
    
   
    
    func callSocialLoginApi(apple_ID:String? = "",google_ID:String? = "",phone_number:String? = "",email:String? = ""){
        if SBUtill.reachable() {
            SBUtill.showProgress()
            
            let params = ["apple_id" : apple_ID ?? "" ,
                          "google_id" : google_ID ?? "",
                          "phone_no" : phone_number ?? "",
                          "email" : email ?? "",
                          "device_token":SBGlobal.fcm,
                          "platform" : "IOS"] as [String : Any]
            
            ClSApi.GetJsonModelValue(completion: { (data) in
                DispatchQueue.main.async { [self] in
                    SBUtill.dismissProgress()
                    
                     if data["data"].dictionary != nil {
                        print("test")
                        
                        self.user = User(data["data"])
                        
                        if user?.id == 0 {
                            let UserSelectionVC = self.storyboard?.instantiateViewController(withIdentifier: "FirstNameVC") as! FirstNameVC
                            SignUpData.shared.apple_id = apple_ID
                            SignUpData.shared.google_id = google_ID
                            SignUpData.shared.PhoneNumber = phone_number
                            UserSelectionVC.sname = sname
                            UserSelectionVC.fname = fname
                            UserSelectionVC.isFromAppleLogin = true
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
}

extension SocialLoginVC:ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
            // case let appleIDCredential as ASAuthorizationAppleIDCredential:
            // User signed in with Apple successfully
        case let credential as ASAuthorizationAppleIDCredential:
            var userIdentifier = ""
            var email = ""
            
            
            if KeychainStruct.userid == credential.user {
                userIdentifier = credential.user
                let fullName = (credential.fullName?.givenName ?? "") + " " + (credential.fullName?.familyName ?? "")
                print(fullName)
                let firstName =  KeychainStruct.firstName ?? ""
                let lastName = KeychainStruct.lastName ?? ""
                let Name = "\(firstName) \(lastName)"
                email = KeychainStruct.email ?? ""
                print("else useer info\(Name)")
                
                self.fname = firstName
                self.sname = lastName
                self.callSocialLoginApi(apple_ID:userIdentifier,email: email)
            }else {
                userIdentifier = credential.user
                let userName = (credential.fullName?.givenName ?? "") + " " + (credential.fullName?.familyName ?? "")
                print("else useer info\(userName)")
                
                let firstName = credential.fullName?.givenName ?? KeychainStruct.firstName ?? ""
                let lastName = credential.fullName?.familyName ?? KeychainStruct.lastName ?? ""
                let email =  credential.email ?? KeychainStruct.email ?? ""
            
                self.fname = firstName
                self.sname = lastName
                
                KeychainStruct.userid = credential.user
                KeychainStruct.firstName = credential.fullName?.givenName ?? KeychainStruct.firstName ?? ""
                KeychainStruct.lastName = credential.fullName?.familyName ?? KeychainStruct.lastName ?? ""
                KeychainStruct.email = credential.email ?? KeychainStruct.email ?? ""
                
                self.callSocialLoginApi(apple_ID:userIdentifier,email: email)
            }
            
            
            // This will give you the user's email
            // You can now use the 'userIdentifier' and 'email' as needed.
            // Example: Printing the user's email
            print("User's email: \(email )")
            
        default:
            break
        }
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}
