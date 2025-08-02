//
//  RUConstant.swift
//  RateUs
//
//  Created by Abhijit Soni on 19/03/17.
//  Copyright © 2017 Abhijit Soni. All rights reserved.
//

import UIKit

typealias Utill        = SBUtill
typealias Text         = SBText



let Application                      = UIApplication.shared.delegate as! AppDelegate

let Global:             SBGlobal     = SBGlobal.global
let UserDefault                      = UserDefaults.standard
let Screen                           = UIScreen.main.bounds.size
let UserKey                          = "UserKey"
let PreFilterKey                     = "PreFilterKey"
let UniqAppId                        = "deviceId"
let SubscriptionTopic                = "/topics/global";
let PushToken                        = "pushToken"
let AppName                          = "Mergo"
let UniqID                           = UIDevice.current.identifierForVendor!.uuidString
let systemVersion                    = UIDevice.current.systemVersion

class KeyMessage {
    
    static let UserKey                          = "UserKey"
    static let apiToken                         = "token"
    static let UniqID                           = UIDevice.current.identifierForVendor!.uuidString
    static let systemVersion                    = UIDevice.current.systemVersion
}


//MARK:- Static Constants
let IPHONE6_WIDTH       = 375.0
let IPHONE6_HEIGHT      = 667.0
let IPHONE6_PLUS_WIDTH  = 414.0

//MARK:- Default Colour
let YELLOW_COLOR = UIColor(red: 229.0/255.0, green: 169.0/255.0, blue: 58.0/255.0, alpha: 1.0)

let GREEN_COLOR = UIColor(red: 0/255.0, green: 157.0/255.0, blue: 53.0/255.0, alpha: 1.0)

let Red_COLOR = UIColor(red: 235, green: 55, blue: 50, alpha: 1.0)


//MARK:- Font name
//["ProximaNova-Light", "ProximaNova-Semibold", "ProximaNova-Bold", "ProximaNova-Regular"]
let ProximaNova_Light = "ProximaNova-Light"
let ProximaNova_Semibold     = "ProximaNova-Semibold"
let ProximaNova_Bold  = "ProximaNova-Bold"
let ProximaNova_Regular   = "ProximaNova-Regular"
let Montserrat_Light    = "Montserrat-Light"


enum MenuAction:Int {
    case Home = 0
    case ManageBook = 1
    case Support = 2
    case AddTraveller = 3
    case paymentOption = 4
    case pnrHistory = 5
   // case Gallery = 4
    case FeedBack = 6
    case Notification = 7
    case Terms = 8
    case CanPolicy = 9
    case Share = 10
    case ContactUs = 11
    case AboutUs = 12
    case Rating = 13
}
