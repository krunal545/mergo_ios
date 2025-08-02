//
//  NotificationVC.swift
//  Margo
//
//  Created by xuser on 10/02/25.
//

import UIKit
import FirebaseMessaging

class NotificationVC: UIViewController {

    @IBOutlet weak var tblView: UITableView!{
        didSet{
            tblView.register(UINib(nibName: "NotificationListTblCell", bundle: nil), forCellReuseIdentifier: "NotificationListTblCell")
        }
    }
    @IBOutlet weak var swtNotification: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()

        if Global.user?.notification == "1" {
            swtNotification.isOn = true
        }else {
            swtNotification.isOn = false
        }
        tblView.delegate = self
        tblView.dataSource = self
    }
//    MARK: - Methods
    
    func callNotificationUpdateAPI(notification:String){
        if SBUtill.reachable() {
            SBUtill.showProgress()
            let param = ["notification":notification]
            ClSApi.GetJsonModelValue(completion: { data in
                DispatchQueue.main.async {
                    SBUtill.dismissProgress()
                    if (data["data"].dictionary != nil){
                        Global.user?.notification = notification
                        SBUtill.showToastWith(data["message"].stringValue)
                    }else {
                        SBUtill.showToastWith(data["message"].stringValue)
                    }
                }
            }, Tag: ClS.API.notification_update, Prams: param, Method: ClS.post)
        }
    }
    
    func enablePushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            guard granted else {
                print("User denied notification permission")
                return
            }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func disablePushNotifications() {
        Messaging.messaging().deleteToken { error in
            if let error = error {
                print("Error deleting FCM token: \(error.localizedDescription)")
            } else {
                print("FCM token deleted, notifications disabled")
            }
        }
        UIApplication.shared.unregisterForRemoteNotifications()
    }
    
    @IBAction func swtNotificationAction(_ sender: UISwitch) {
        if swtNotification.isOn {
            enablePushNotifications()
            callNotificationUpdateAPI(notification: "1")
        }else{
            disablePushNotifications()
            callNotificationUpdateAPI(notification: "0")
        }
    }
    
    //MARK: - Action Methods
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
   
}

extension NotificationVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationListTblCell", for: indexPath) as! NotificationListTblCell
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
