//
//  ViewController.swift
//  Margo
//
//  Created by Lenovo on 09/01/25.
//

import UIKit


class SplashVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.callSettingAPI()
        })
    }

    func callSettingAPI(){
        if SBUtill.reachable() {
            SBUtill.showProgress()
            let param = ["": ""] as [String : Any]
            ClSApi.GetJsonModelValue(completion: { data in
                SBUtill.dismissProgress()
                DispatchQueue.main.async {
                 
                    if let versionData = data["data"].dictionary {
                        let uploadedVersion = versionData["user_ios_version"]?.stringValue ?? "1000"
                        let uploadedBuildVersion = versionData["ios_build_number"]?.stringValue ?? "1"
                        let appLocalVersion = Bundle.main.releaseVersionNumber
                        let buildVersion = Bundle.main.buildVersionNumber
                        
//                         terms_and_conditions = versionData["terms_and_conditions"]?.stringValue ?? ""
                        SignUpData.shared.termsAndCondition =  versionData["terms_and_conditions"]?.stringValue ?? ""
                        #if DEBUG
                        print(uploadedVersion)
                        print(uploadedBuildVersion)
                        print(appLocalVersion as Any)
                        print(buildVersion as Any) #endif
                        let uploadVersion = Double(uploadedVersion)
                        let uploadBuildNumber = Double(uploadedBuildVersion)
                        let appVersion = Double(appLocalVersion ?? "0")
                        let appBuildVersion = Double(buildVersion ?? "0")
                        
                        if appVersion! <= uploadVersion! {
                            if appBuildVersion! < uploadBuildNumber! || (appVersion! < uploadVersion! && uploadBuildNumber! == appBuildVersion!) {
//                                let Vc = self.storyboard?.instantiateViewController(withIdentifier: "VersionUpdatePopUp") as! VersionUpdatePopUp
//                                Vc.modalPresentationStyle = .custom
//                                Vc.IsFromSetting = true
//                                Vc.transitioningDelegate = self.bottomUpTransitioningDelegate
//                                self.present(Vc, animated: true)
                            }else{
                                SBUtill.prepareApplication()
                            }
                        }else{
                            SBUtill.prepareApplication()
                        }
                    }else {
                        SBUtill.showToastWith(data["message"].stringValue)
                    }
                }
            }, Tag: ClS.API.setting, Prams: param, Method: ClS.get)
        }else{
            SBUtill.showToastWith(SBText.Message.NoInternetSnack)
        }
    }
}

