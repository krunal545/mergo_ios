//
//  NotificationPermissionVC.swift
//  Margo
//
//  Created by Dharmesh A Nagvadia on 18/01/25.
//

import UIKit
import CoreLocation

class NotificationPermissionVC: UIViewController {

    @IBOutlet weak var vwDropShadow: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vwDropShadow.addBottomShadow()
        // Do any additional setup after loading the view.
    }
    
    func showPermissionDeniedPopup() {
        let alert = UIAlertController(title: "Notifications Disabled",
                                      message: "Please enable notifications in Settings to continue.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnAllowAction(_ sender: Any) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.configureFirebasePushNotifications(UIApplication.shared) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.btnNextAction(sender)
                    } else {
                        self.btnNextAction(sender)
                    }
                }
            }
        }
    }
    
    func hasLocationPermission() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        return status == .authorizedWhenInUse || status == .authorizedAlways
    }
    
    @IBAction func btnNextAction(_ sender: Any) {
        
        if hasLocationPermission() {
            let vc = storyboard?.instantiateViewController(withIdentifier: "GenderSelectionVC") as! GenderSelectionVC
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let VC = storyboard?.instantiateViewController(withIdentifier: "PermissionVC") as! PermissionVC
            self.navigationController?.pushViewController(VC, animated: true)
        }
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
