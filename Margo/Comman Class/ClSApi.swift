//
//  ClSApi.swift
//  Fit Finder
//
//  Created by Krunal Nagvadia on 25/05/22.
//

import Foundation
import Alamofire
import SwiftyJSON

class ClS {
    
    public static var post = "POST"
    public static var get = "GET"
    public static var Content_Type = "application/json"
    public static var Accept = "application/json"
    
    public static let api_key = "MERGO"
    public static let platform = "IOS"
    public static let app_storeUrl = ""
    public static var baseUrl = "https://api.mergo.in/api"
//    "https://techavtra.com/projects/mergo/api"
//http://3.149.228.167/meekle/api
    class API {
        public static var social_login = "/user/social_login"
        public static var signup = "/user/signup"
        public static var qr_Code_User_List = "/qr-code/user-list"
        public static var swipe_create = "/swipe/create"
        public static var matches = "/swipe/get_matches"
        public static var get_restaurant = "/restaurant/get"
        public static var profile_image_update = "/user/profile_image_update"
        public static var setting = "/setting"
        public static var qr_code_scan = "/qr-code/scan"
        public static var logout = "/user/logout"
        public static var delete_account = "/user/delete_account"
        public static var notification_update = "/user/notification-update"
        
        
        
        public static var resendEmail = "/user/resend-varification-email"
        public static var contactUs = "/contact_us/store"
        public static var location = "/location/get"
        public static var restuarant_Reception = "/reception/get"
        public static var create_post = "/post/create"
        public static var get_profile = "/user/get_profile"
        public static var get_post = "/post/my-post"
        public static var post_details = "/post/detail"
        public static var post_swipe = "/post/mach"
        public static var other_post_apply = "/post/apply-post"
        public static var change_password = "/user/change_password"
        public static var forgot_password = "/user/forgot_password"
        public static var get_user_current_plan = "/transactions/get_user_current_plan"
        public static var complete_payment = "/transactions/complete-payment"
        public static var complete_profile = "/user/complete_profile"
        public static var privacy_policy = "https://meekle.app/privacy-policy/"
        public static var terms_condition = "https://meekle.app/terms-and-conditions"
        public static var cancel_applied = "/post/cancel-applied"
     
        public static var host_spotlight = "/post/spot-light"
        public static var notifications_get = "/notifications/get"
        public static var notifications_clear_all = "/notifications/clear-all"
        public static var notifications_clear = "/notifications/clear"
        public static var host_cancel_post = "/post/cancel-post"
        public static var post_detail_by_post_id = "/post/post-detail-by-post-id"
        public static var post_report_post = "/user/report"
        public static var create_message_post = "/message_post/create"
        public static var get_message = "/message_post/get"
        public static var message_post_like = "/message_post/like"
        public static var message_post_liked_users = "/message_post/liked_users"
        public static var chat_notification_send = "/notifications/send-notification"
        public static var delete_message = "/message_post/delete_message"
        public static var message_post_swipe = "/message_post/swipe"
        public static var unmatch = "/swipe/unmatch"
    }
}

class DefaultKey {
    static let Token = "token"
    
}
class ClSApi {
    // Json To Pojo Convarter, Created by Yash Shekahda 20-10-2019
    public static func JsonModelValue<T: Decodable>( completion: @escaping (T) -> (),Tag:String, Prams: [String:Any],Method :String) {
        
        let url = URL(string: ClS.baseUrl+Tag)!
        var request = URLRequest(url: url)
        let params = Prams
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = Method
        
        request.httpBody = params.percentEscaped().data(using: .utf8)
        
        if let data = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted),
           let str = String(data: data, encoding: .utf8) {
            print(str)
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("Error: No data to decode")
                SBUtill.dismissProgress()
                return
            }
            print("Responce string \(String(data: data, encoding: String.Encoding.utf8) as String?)")
            
            guard let blog = try? JSONDecoder().decode(T.self, from: data) else {
                print("Errors: Couldn't decode data into Blog")
                SBUtill.dismissProgress()
                return
            }
            completion(blog)
        }
        task.resume()
    }
    
    //WIthoutParaComman
    public static func GetModelWithOutComman<T:Decodable>(completion: @escaping (T) -> (),Tag:String, Prams: [String:Any],Method :String){
        let url = URL(string: ClS.baseUrl+Tag)!
        var request = URLRequest(url: url)
        let params = Prams
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = Method
        
        request.httpBody = params.percentEscaped().data(using: .utf8)
        
        if let data = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted),
           let str = String(data: data, encoding: .utf8) {
            print(str)
        }
        print("SendPanicCallMessage Url string  \(params.percentEscaped())")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("Error: No data to decode")
                SBUtill.dismissProgress()
                return
            }
            guard let blog = try? JSONDecoder().decode(T.self, from: data) else {
                print("Errors: Couldn't decode data into Blog")
                SBUtill.dismissProgress()
                return
            }
            completion(blog)
        }
        task.resume()
    }
    
    // Json To Pojo Convarter With T Class by Lability Url, Created by Yash Shekahda 20-10-2019
    public static func GetModelValue<T: Decodable>( completion: @escaping (T) -> (),Tag:String,param:[String:Any]) {
        
        let url = URL(string: ClS.baseUrl+Tag)!
        var request = URLRequest(url: url)
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        request.httpBody = param.percentEscaped().data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("Error: No data to decode")
                SBUtill.dismissProgress()
                return
            }
            guard let blog = try? JSONDecoder().decode(T.self, from: data) else {
                print("Errors: Couldn't decode data into Blog")
                SBUtill.dismissProgress()
                return
            }
            completion(blog)
        }
        task.resume()
    }
}

// ======================================Alamofire
extension ClSApi {
    public static func GetJsonModelValue(completion: @escaping (JSON) -> (),Tag:String, Prams: [String:Any]?,Method :String) {
        if SBUtill.reachable() {
            let url = URL(string: ClS.baseUrl+Tag)!
            _ = URLRequest(url: url)
            var params = Prams
            
            var headers = ["Content-Type": ClS.Content_Type,
                           "Accept": ClS.Content_Type,
                           "api-key":ClS.api_key,
                           "platform":ClS.platform]
            
            if ("/user/socil_login" == Tag) || ("/user/signup" == Tag) {
                print("No token in headers")
            }else{
                headers["Authorization"] = "Bearer \(Global.apiToken)"
            }
            if Method == "GET"{
                params = nil
            }else{
                if params != nil{
                    if let data = try? JSONSerialization.data(withJSONObject: params!, options: .prettyPrinted),
                       let str = String(data: data, encoding: .utf8) {
                        print(str)
                    }
                }
            }
            
            Alamofire.request(url, method: HTTPMethod(rawValue: Method)!, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) -> Void in
                print(url)
                print("Result",response.result)   // result of response serialization
                //print("parameters = \(params)")
                if response.result.value != nil {
                    print(JSON(response.result.value ?? ""))
                }
                SBUtill.dismissProgress()
                switch response.result {
                case .success(_):
                    
                    if response.response?.statusCode == 200 || response.response?.statusCode == 201 {
                        guard response.data != nil else {
                            print("Error: No data to decode")
                            return
                        }
                        let json = JSON(response.result.value ?? "")
                        completion(json)
                    }else if response.response?.statusCode == 422{
                        if let responseMesssage = response.result.value as? [String:AnyObject]{
                            SBUtill.showToastWith(responseMesssage["message"] as? String ?? "")
                        }else{
                            SBUtill.showToastWith(SBText.Message.somethingWrong)
                        }
                    }else if response.response?.statusCode == 401{
                        let domain = Bundle.main.bundleIdentifier!
                        UserDefaults.standard.removePersistentDomain(forName: domain)
                        UserDefaults.standard.synchronize()
                        print(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)
                        
                        SBUtill.moveToHome(Status: false)
                        if let responseMesssage = response.result.value as? [String:AnyObject]{
                            SBUtill.showToastWith(responseMesssage["message"] as? String ?? SBText.Message.somethingWrong)
                        }else{
                            SBUtill.showToastWith(SBText.Message.somethingWrong)
                        }
                    } else if response.response?.statusCode == 404 {
                        guard response.data != nil else {
                            print("Error: No data to decode")
                            return
                        }
                        let json = JSON(response.result.value ?? "")
                        completion(json)
                    }else if response.response?.statusCode == 204 && Tag == "/message_post/liked_users" {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            NotificationCenter.default.post(name: Notification.Name("MessgaeIsNotCreated"), object: nil)
                        }
                        guard response.data != nil else {
                            print("Error: No data to decode")
                            return
                        }
                        let json = JSON(response.response?.statusCode ?? "No Data")
                        completion(json)
                    }
                    else{
                        SBUtill.showToastWith(SBText.Message.somethingWrong)
                    }
                case .failure(let error):
                    debugPrint("getEvents error: \(error)")
                    SBUtill.showToastWith(SBText.Message.somethingWrong)
                }
            }
        }else {
            SBUtill.showToastWith(SBText.Message.NoInternetSnack)
        }
        
    }
    
    public static func  uploadImageRequest(completion: @escaping (JSON) -> (),Tag:String, Prams: [String:Any], image : UIImage?, imageType:String,imgKey:String, imageName:String,view:UIViewController) {
        if SBUtill.reachable() {
            let url = URL(string: ClS.baseUrl+Tag)!
            _ = URLRequest(url: url)
            print(Prams)
            var params = Prams
            
            var headers = ["Content-Type": ClS.Content_Type,
                           "Accept": ClS.Content_Type,
                           "api-key":ClS.api_key,
                           "platform":ClS.platform]
            
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                for (key, value) in params {
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                }
                
                if let data = image?.jpegData(compressionQuality: 0.15) {
                    print(data.count.byteSize)
                    multipartFormData.append(data, withName: imgKey, fileName: imageName, mimeType: imageType)
                    
                }
                print(multipartFormData)
            },to: url,method: .post,headers: headers) { result in
                switch result {
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (Progress) in
                        print("Upload Progress: \(Progress.fractionCompleted)")
                        let progress = Progress.fractionCompleted
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UploadProgress"), object: Double(progress))
                    })
                    
                    upload.responseJSON { response in
                        print("Result",response.result)
                        print("data = \(String(describing: response.result.value))")
                        
                        if response.result.value != nil {
                            print(JSON(response.result.value ?? ""))
                        }
                        SBUtill.dismissProgress()
                        switch response.result {
                        case .success(_):
                            if response.response?.statusCode == 200 || response.response?.statusCode == 201 {
                                guard response.data != nil else {
                                    print("Error: No data to decode")
                                    return
                                }
                                let json = JSON(response.result.value ?? "")
                                completion(json)
                            }else if response.response?.statusCode == 422{
                                if let responseMesssage = response.result.value as? [String:AnyObject]{
                                    SBUtill.showToastWith(responseMesssage["message"] as? String ?? SBText.Message.somethingWrong)
                                }else{
                                    SBUtill.showToastWith(SBText.Message.somethingWrong)
                                }
                            }else if response.response?.statusCode == 401{
                                let domain = Bundle.main.bundleIdentifier!
                                UserDefaults.standard.removePersistentDomain(forName: domain)
                                UserDefaults.standard.synchronize()
                                print(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)
                                
                                SBUtill.moveToHome(Status: false)
                                if let responseMesssage = response.result.value as? [String:AnyObject]{
                                    SBUtill.showToastWith(responseMesssage["message"] as? String ?? SBText.Message.somethingWrong)
                                }else{
                                    SBUtill.showToastWith(SBText.Message.somethingWrong)
                                }
                            }
                            else{
                                SBUtill.showToastWith(SBText.Message.somethingWrong)
                            }
                        case .failure(let error):
                            debugPrint("getEvents error: \(error)")
                            SBUtill.showToastWith(SBText.Message.somethingWrong)
                        }
                    }
                case .failure(let error):
                    print("Error in upload: \(error.localizedDescription)")
                    SBUtill.dismissProgress()
                    SBUtill.showToastWith(SBText.Message.somethingWrong)
                }
            }
        }else{
            SBUtill.showToastWith(SBText.Message.NoInternetSnack)
        }
    }
    
    public static func uploadArrImgRequest(completion: @escaping (JSON) -> (),Tag:String, Prams: [String:Any], images : [UIImage],view:UIViewController,isFromEdit:Bool?) {
        if SBUtill.reachable() {
            let url = URL(string: ClS.baseUrl+Tag)!
            _ = URLRequest(url: url)
            print(url)
//            let headers = ["Content-type": "multipart/form-data","X-Requested-With":"XMLHttpRequest","Upgrade":"h2,h2c","api-key":"MEEKLE","platform":"IOS"]
            var headers = ["Content-Type": ClS.Content_Type,
                           "Accept": ClS.Content_Type,
                           "api-key":ClS.api_key,
                           "platform":ClS.platform]
            headers["Authorization"] = "Bearer \(Global.apiToken)"
            print(Prams)
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                var i = 0
                for img in images {
                    var imageKey = ""
                    if isFromEdit == true{
                        imageKey = "profile_image[\(i)]"
                    }else{
                        imageKey = "profile_image[\(i)]"
                    }
                    
                    if let data = img.jpegData(compressionQuality: 0.15) {
                        print(data.count.byteSize)
                        multipartFormData.append(data, withName: imageKey, fileName: "Profile\(i).png", mimeType: "image/png")
                    }
                    i = i + 1
                }
                if isFromEdit == true{
                    for (key, valuess) in Prams {
                        multipartFormData.append("\(valuess)".data(using: String.Encoding.utf8)!, withName: key as String)
                    }
                }
            },to: url,method: .post,headers: headers) { result in
                switch result {
                case .success(let upload, _, _):
                    
                    
                    upload.uploadProgress(closure: { (Progress) in
                        print("Upload Progress: \(Progress.fractionCompleted)")
                        let progress = Progress.fractionCompleted
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UploadProgress"), object: Double(progress))
                        
                    })
                    
                    upload.responseJSON { response in
                        print("Result",response.result)
                        print("data = \(response.result.value ?? "")")
                        //print("parameters = \(params)")
                        if response.result.value != nil {
                            print(JSON(response.result.value ?? ""))
                        }
                        SBUtill.dismissProgress()
                        switch response.result {
                        case .success(_):
                            if response.response?.statusCode == 200 || response.response?.statusCode == 201 {
                                guard response.data != nil else {
                                    print("Error: No data to decode")
                                    return
                                }
                                let json = JSON(response.result.value ?? "")
                                completion(json)
                            }else if response.response?.statusCode == 422{
                                if let responseMesssage = response.result.value as? [String:AnyObject]{
                                    SBUtill.showToastWith(responseMesssage["message"] as? String ?? SBText.Message.somethingWrong)
                                }else{
                                    SBUtill.showToastWith(SBText.Message.somethingWrong)
                                }
                            }else if response.response?.statusCode == 401{
                                let domain = Bundle.main.bundleIdentifier!
                                UserDefaults.standard.removePersistentDomain(forName: domain)
                                UserDefaults.standard.synchronize()
                                print(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)
                                
                                SBUtill.moveToHome(Status: false)
                                if let responseMesssage = response.result.value as? [String:AnyObject]{
                                    SBUtill.showToastWith(responseMesssage["message"] as? String ?? SBText.Message.somethingWrong)
                                }else{
                                    SBUtill.showToastWith(SBText.Message.somethingWrong)
                                }
                            }
                            else{
                                SBUtill.showToastWith(SBText.Message.somethingWrong)
                            }
                        case .failure(let error):
                            debugPrint("getEvents error: \(error)")
                            SBUtill.showToastWith(SBText.Message.somethingWrong)
                        }
                    }
                case .failure(let error):
                    print("Error in upload: \(error.localizedDescription)")
                    SBUtill.dismissProgress()
                    SBUtill.showToastWith(SBText.Message.somethingWrong)
                }
            }
        }else {
            SBUtill.showToastWith(SBText.Message.NoInternetSnack)
        }
    }
    public static func uploadFileRequest(completion: @escaping (JSON) -> (),Tag:String, Prams: [String:Any],fileUrl:URL,fileName:String,type:String,view:UIViewController) {
        if SBUtill.reachable() {
            let url = URL(string: ClS.baseUrl+Tag)!
            _ = URLRequest(url: url)
            let params = Prams
            
            let headers = ["Content-type": "multipart/form-data","X-Requested-With":"XMLHttpRequest","Upgrade":"h2,h2c","api-key":"DINE4ALL2023","platform":"IOS"]
            
            
            Alamofire.upload(multipartFormData: { multipartFormData in
                do {
                    let fileData = try Data(contentsOf: fileUrl)
                    multipartFormData.append(fileData, withName: "attachment", fileName: fileName, mimeType:type)
                    
                    for (key, value) in params {
                        multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                        print("multipart \(multipartFormData)")
                    }
                }catch {
                    //SBUtill.showToastWith("Something went wrong. Please try after some time")
                    return
                }
            },to: url,method: .post,headers: headers) { result in
                switch result {
                case .success(let upload, _, _):
                    
                    
                    upload.uploadProgress(closure: { (Progress) in
                        print("Upload Progress: \(Progress.fractionCompleted)")
                        let progress = Progress.fractionCompleted
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UploadProgress"), object: Double(progress))
                        
                    })
                    upload.responseJSON { response in
                        print("Result",response.result)
                        //print("parameters = \(params)")
                        if response.result.value != nil {
                            print(JSON(response.result.value ?? ""))
                        }
                        SBUtill.dismissProgress()
                        switch response.result {
                        case .success(_):
                            if response.response?.statusCode == 200 || response.response?.statusCode == 201 {
                                guard response.data != nil else {
                                    print("Error: No data to decode")
                                    return
                                }
                                let json = JSON(response.result.value ?? "")
                                completion(json)
                            }else if response.response?.statusCode == 422{
                                if let responseMesssage = response.result.value as? [String:AnyObject]{
                                    SBUtill.showToastWith(responseMesssage["message"] as? String ?? SBText.Message.somethingWrong)
                                }else{
                                    SBUtill.showToastWith(SBText.Message.somethingWrong)
                                }
                            }else if response.response?.statusCode == 401{
                                let domain = Bundle.main.bundleIdentifier!
                                UserDefaults.standard.removePersistentDomain(forName: domain)
                                UserDefaults.standard.synchronize()
                                print(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)
                                
                                SBUtill.moveToHome(Status: false)
                                if let responseMesssage = response.result.value as? [String:AnyObject]{
                                    SBUtill.showToastWith(responseMesssage["message"] as? String ?? SBText.Message.somethingWrong)
                                }else{
                                    SBUtill.showToastWith(SBText.Message.somethingWrong)
                                }
                            }
                            else{
                                SBUtill.showToastWith(SBText.Message.somethingWrong)
                            }
                        case .failure(let error):
                            debugPrint("getEvents error: \(error)")
                            SBUtill.showToastWith(SBText.Message.somethingWrong)
                        }
                    }
                case .failure(let error):
                    print("Error in upload: \(error.localizedDescription)")
                    SBUtill.dismissProgress()
                    SBUtill.showToastWith(SBText.Message.somethingWrong)
                }
            }
        }else{
            SBUtill.showToastWith(SBText.Message.NoInternetSnack)
        }
    }
}

// Dictionary extension for Json Quary , Created by Yash Shekahda 31-10-2019
extension Dictionary {
    func percentEscaped() -> String {
        return map { (key, value) in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}


extension Notification.Name {
    static let UploadProgress = Notification.Name("UploadProgress")
}

extension Int {
    var byteSize: String {
        return ByteCountFormatter().string(fromByteCount: Int64(self))
    }
}

