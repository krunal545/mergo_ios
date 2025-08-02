//
//  RUGlobal.swift
//  RateUs
//
//  Created by Abhijit Soni on 19/03/17.
//  Copyright © 2017 Abhijit Soni. All rights reserved.
//

import UIKit

class SBGlobal {
    static let global: SBGlobal = SBGlobal()
    var navigationController:   UINavigationController?
    static var fcm = ""
    var apiToken = ""
    var uniqDeviceid:String = ""
    var user : User?
    var terms_and_conditions = "https://www.mergo.in/blank-2"
    @UserDefaultss(.saveQRCode, defaultValue: "")
    var saveQRCode: String?

}


 
@propertyWrapper
struct UserDefaultss<T: Codable> {
    let key: String
    let defaultValue: T
    let userDefaults: UserDefaults
 
    init(_ key: UserDefaultsKey, defaultValue: T, userDefaults: UserDefaults = .standard) {
        self.key = key.rawValue
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults
    }
 
    var wrappedValue: T {
        get {
            guard let data = userDefaults.data(forKey: key) else { return defaultValue }
            let decodedValue = try? JSONDecoder().decode(T.self, from: data)
            return decodedValue ?? defaultValue
        }
        set {
            let encodedData = try? JSONEncoder().encode(newValue)
            userDefaults.set(encodedData, forKey: key)
        }
    }
}
 
enum UserDefaultsKey: String {
    case saveQRCode
    case blockedUser
}
 
