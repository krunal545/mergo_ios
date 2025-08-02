//
//  AppDelegate.swift
//  Margo
//
//  Created by Lenovo on 09/01/25.
//

import UIKit
import IQKeyboardManagerSwift
import FirebaseAuth
import Firebase
import FirebaseCore
import FirebaseMessaging



@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        Messaging.messaging().isAutoInitEnabled = true
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        //        SBUtill.prepareApplication()
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
                // Manually call your delegate function
                self.messaging(Messaging.messaging(), didReceiveRegistrationToken: token)
            }
        }

        configureFirebasePushNotifications(application, completion:{_ in })
        
        return true
    }
   
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        #if DEBUG
                Auth.auth().setAPNSToken(deviceToken, type: .sandbox)
        #else
                Auth.auth().setAPNSToken(deviceToken, type: .prod)
        #endif
        
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }

//    func application(_ application: UIApplication,
//                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//#if DEBUG
//        Auth.auth().setAPNSToken(deviceToken, type: .sandbox)
//#else
//        Auth.auth().setAPNSToken(deviceToken, type: .prod)
//#endif
//        
//    }
}


