//
//  RUUtill.swift
//  RateUs
//
//  Created by Abhijit Soni on 19/03/17.
//  Copyright © 2017 Abhijit Soni. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import SVProgressHUD
import KSToastView
import KeychainSwift
import TTGSnackbar
import FirebaseAuth
import GoogleSignIn


class SBUtill {
    
    @UserDefaultss(.blockedUser, defaultValue: [])
    static var blockedUsers: [Int]?
    
    class func logOut()  {
        var tempblockedUsers: [Int]?
        tempblockedUsers = blockedUsers
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        Global.user = nil
        Global.apiToken = String()
        UserDefaults.standard.synchronize()
        blockedUsers = tempblockedUsers
        do {
                try Auth.auth().signOut()
                GIDSignIn.sharedInstance.signOut()
                print("User signed out.")
            } catch let error {
                print("Sign-out failed: \(error.localizedDescription)")
            }
    }
    
    
    @MainActor class func prepareApplication() {
        UIApplication.shared.statusBarStyle = .lightContent
        Utill.prepareUser()
        //Utill.prepareProgressHUD()
        Utill.setDeviceID()
        IQKeyboardManager.shared.isEnabled = true
    }
    
    class func setDeviceID()  {
        let keyChain = KeychainSwift()
        if let deviceid = keyChain.get("UniqDeviceId") {
            Global.uniqDeviceid = deviceid
        } else {
            let uuid = UIDevice.current.identifierForVendor!.uuidString
            Global.uniqDeviceid = uuid
            keyChain.set(uuid, forKey: "UniqDeviceId")
        }
        Global.uniqDeviceid = (UIDevice.current.identifierForVendor?.uuidString)!
    }
    class func getIPAddress() -> [String] {
        var addresses = [String]()
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return [] }
        guard let firstAddr = ifaddr else { return [] }
        
        // For each interface ...
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            let addr = ptr.pointee.ifa_addr.pointee
            
            // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if (getnameinfo(ptr.pointee.ifa_addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                        let address = String(cString: hostname)
                        if address.components(separatedBy: ".").count == 4 {
                            addresses.append(address)
                        }
                    }
                }
            }
        }
        
        freeifaddrs(ifaddr)
        return addresses
    }


    class func showAlert(message:String,fromVC:UIViewController,title:String)  {
        let alertController =  UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (ACTION :UIAlertAction!)in
            alertController.dismiss(animated: true, completion: nil)
        }))
        fromVC.present(alertController, animated: true, completion: nil)
    }

    @MainActor class func enableDisableIQkeyboard(enable:Bool)  {
        IQKeyboardManager.shared.isEnabled = true
    }
    
    class func prepareProgressHUD()  {
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)

    }
    
    
    class func moveToHome(Status:Bool) {
        if Status {
            let redViewController = UIStoryboard.Home.instantiateViewController(withIdentifier: "HomeTabbar")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = redViewController
            
        }else{
            SBUtill.logOut()
            let logInViewController = UIStoryboard.storyboardMain.instantiateViewController(withIdentifier: "GetStartedNav")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = logInViewController
        }
    }
    
    class func showProgress()  {
        SVProgressHUD.show()
    }
    class func dismissProgress()  {
        SVProgressHUD.dismiss()
    }
    class func showProgressWithText(text:String)  {
        SVProgressHUD.show(withStatus: text)
    }
    
    class func reachable() -> Bool {
        if Reachability.isConnectedToNetwork(){
            return true
        }else{
            return false
        }
    }
    
    class func uuid() -> String {
        let uniqueString: CFUUID = CFUUIDCreate(nil)
        let isString: CFString = CFUUIDCreateString(nil, uniqueString)
        return isString as String
    }
    class func showToastWith(_ message:String) {
        KSToastView.ks_showToast(message, duration: 1.5)
    }
    
    class func showSnack(_ message:String) {
        let snackbar = TTGSnackbar(message: message, duration: .short)
        snackbar.show()
    }

    class func prepareUser() {
        //initialize User object if it is logged In
        
        // Global.user = NSKeyedUnarchiver.unarchiveObject(with: userData) as? SBUserData
        
        if let userData = UserDefault[KeyMessage.UserKey] as! Data? {
            
            if let userData = UserDefault[KeyMessage.UserKey] as! Data? {
              Global.user = NSKeyedUnarchiver.unarchiveObject(with: userData) as? User
            }
            
            if let apiToken = UserDefault[KeyMessage.apiToken] as! String? {
                SBGlobal.global.apiToken = apiToken
            }
            
            SBUtill.moveToHome(Status: true)
        }else{
            SBUtill.moveToHome(Status: false)
        }
        
    }
    
   
    class func prepareUserForLogout(frmoVC:UINavigationController) {
        
        let alertController =  UIAlertController(title: AppName, message: Text.Message.logout, preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: Text.Label.logout, style: UIAlertAction.Style.default, handler: { (ACTION :UIAlertAction!)in
            SBUtill.moveToHome(Status: false)
        }))
        
        alertController.addAction(UIAlertAction(title: Text.Label.cancel, style: UIAlertAction.Style.cancel, handler: { (ACTION :UIAlertAction!)in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        frmoVC.present(alertController, animated: true, completion: nil)
    }
    class func prepareUserForDeleteAccount(frmoVC:UINavigationController) {
        
        let alertController =  UIAlertController(title: AppName, message: Text.Message.delete_Account, preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: Text.Label.delete, style: UIAlertAction.Style.default, handler: { (ACTION :UIAlertAction!)in
            SBUtill.moveToHome(Status: false)
        }))
        
        alertController.addAction(UIAlertAction(title: Text.Label.cancel, style: UIAlertAction.Style.cancel, handler: { (ACTION :UIAlertAction!)in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        frmoVC.present(alertController, animated: true, completion: nil)
    }
    
  
    class func getFlexibleData() -> [String] {
        return ["An hour","Two Hours","Three Hours"]
    }
    
    class func getFlexibleDataValue(flexibale:String) -> String {
        return "\(getFlexibleData().index(of: flexibale)! + 1)"
    }
    
    class func getColour() -> UIColor {
        let dice1 = arc4random_uniform(6)
        
    let arrColour:[UIColor] = [UIColor(red: 224.0/255.0, green: 96.0/255.0, blue: 85.0/255.0, alpha: 1.0),UIColor(red: 246.0/255.0, green: 191.0/255.0, blue: 38.0/255.0, alpha: 1.0),UIColor(red: 79.0/255.0, green: 195.0/255.0, blue: 247.0/255.0, alpha: 1.0),UIColor(red: 186.0/255.0, green: 104.0/255.0, blue: 200.0/255.0, alpha: 1.0),UIColor(red: 121.0/255.0, green: 134.0/255.0, blue: 203.0/255.0, alpha: 1.0),UIColor(red: 77.0/255.0, green: 182.0/255.0, blue: 172.0/255.0, alpha: 1.0)]
        return arrColour[Int(dice1)]
    }
    class func getStringFromDate(_ currentFormat: String, toFormat: String, date: String) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = currentFormat
        formatter.locale = Locale(identifier: "en_US")
        
        guard let currentDate = formatter.date(from: date) else {
            SBUtill.showToastWith("Failed to convert string to date using format: \(currentFormat)")
            print("Failed to convert string to date using format: \(currentFormat) for :\(date)")
            return nil
        }
        
        formatter.dateFormat = toFormat
        return formatter.string(from: currentDate)
    }
    
    class func getStringFromDate1(_ toFormat: String, date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = toFormat
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }

    class func calcAge(birthday: String) -> Int {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy/MM/dd"
        let birthdayDate = dateFormater.date(from: birthday)
        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: .gregorian)
        let now = Date()
        let calcAge = calendar.components(.year, from: birthdayDate!, to: now, options: [])
        let age = calcAge.year
        return age!
    }
    
    class func getStringFromDateWithSydney(_ currentFormat:String,date:Date) -> String! {
        let formatter = DateFormatter()
        formatter.dateFormat = currentFormat
        //        formatter.timeZone = NSTimeZone(abbreviation: "GMT+1100")! as TimeZone
        formatter.locale = Locale(identifier: "en_US")
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: date)
    }
    class func getStringFromDate(_ currentFormat:String,date:Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = currentFormat
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
    class func getDatefromStringWithoutTime(_ currentFormat:String,date:String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = currentFormat
//        formatter.timeZone = NSTimeZone(abbreviation: "GMT+1100")! as TimeZone
        formatter.locale = Locale(identifier: "en_US")
        return formatter.date(from: date)!
    }
    
    class func getDatefromString(_ currentFormat:String,date:String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = currentFormat
        formatter.locale = Locale(identifier: "en_US")
        let ausDate = formatter.date(from: date)
        let dateStr = formatter.string(from: ausDate!)
        return formatter.date(from: dateStr)!
    }
    
    class func GMTToLocalDateFromString(_ currentFormat:String,date:String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = currentFormat
        //formatter.timeZone = NSTimeZone(abbreviation: "GMT")! as TimeZone
        formatter.locale = Locale(identifier: "en_US")
        let getDate = formatter.date(from: date)!
        //formatter.timeZone = NSTimeZone.local
        return getDate
        //return formatter.date(from: formatter.string(from: getDate))!
    }
    class func format(before: Date) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.unitsStyle = .short
        formatter.maximumUnitCount = 1
        formatter.zeroFormattingBehavior = .dropAll
        let timeString = formatter.string(from: before, to: Date())
        return "\(timeString!) ago"
        //return formatter.string(from: duration)!
    }
    class func formatWithoutAgo(before: Date) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.unitsStyle = .short
        formatter.maximumUnitCount = 1
        formatter.zeroFormattingBehavior = .dropAll
        let timeString = formatter.string(from: before, to: Date())
        return "\(timeString!)"
        //return formatter.string(from: duration)!
    }
    class func timeAgoSinceDate(_ date:Date, numericDates:Bool = false) -> String {
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = Date()
        let earliest = now < date ? now : date
        let latest = (earliest == now) ? date : now
        let components = calendar.dateComponents(unitFlags, from: earliest,  to: latest)
        
        if (components.year! >= 2) {
            return "\(components.year!) years ago"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) hours ago"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 hour ago"
            } else {
                return "An hour ago"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) minutes ago"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 minute ago"
            } else {
                return "A minute ago"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) seconds ago"
        } else {
            return "Just now"
        }
        
    }
    
    
    class func isiPhoneX() -> Bool {
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436:
                return true
            default:
                return false
            }
        }
        return false
    }
}



extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.masksToBounds = false
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.masksToBounds = false
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.masksToBounds = false
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}
