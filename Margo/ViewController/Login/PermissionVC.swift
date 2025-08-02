//
//  PermissionVC.swift
//  Margo
//
//  Created by Lenovo on 10/01/25.
//

import UIKit
import CoreLocation


class PermissionVC: UIViewController {

    @IBOutlet weak var vwDropShadow: UIView!
    @IBOutlet weak var btnContinue: UIButton!
    
    var locationManager: CLLocationManager!
    var showAlert = false

    var lat = ""
    var long = ""
    var City = ""
    var State = ""
    var Address = ""

  
    override func viewDidLoad() {
        super.viewDidLoad()
        vwDropShadow.addBottomShadow()
        configureLocationManager()
        updateButtonTitleBasedOnPermission()
    }

    // MARK: - Configuration
    func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func updateButtonTitleBasedOnPermission() {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .notDetermined:
            btnContinue.setTitle("Continue", for: .normal)
        case .authorizedWhenInUse, .authorizedAlways:
            btnContinue.setTitle("Continue", for: .normal)
        case .denied, .restricted:
            btnContinue.setTitle("Continue", for: .normal)
        @unknown default:
            btnContinue.setTitle("Continue", for: .normal)
        }
    }

    // MARK: - Actions
    @IBAction func btnContinueAction(_ sender: UIButton) {
        showAlert = true
        let status = CLLocationManager.authorizationStatus()

        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            redirectToNextScreen()

        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()

        case .denied, .restricted:
//            showLocationAlert()
            redirectToNextScreen()
        @unknown default:
            redirectToNextScreen()
        }
    }

    @IBAction func btnNotNowAction(_ sender: UIButton) {
        SignUpData.shared.Lat = ""
        SignUpData.shared.Long = ""
        SignUpData.shared.Address = ""
        SignUpData.shared.City = ""
        SignUpData.shared.State = ""
        redirectToNextScreen()
    }

    @IBAction func btnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Helper Methods
    func showLocationAlert() {
        let alertController = UIAlertController(
            title: "Location Access Denied",
            message: "Please enable location access in Settings to use this feature, or tap 'Not Now' to continue without location.",
            preferredStyle: .alert
        )
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }

    func redirectToNextScreen() {
        showAlert = false
        let vc = storyboard?.instantiateViewController(withIdentifier: "GenderSelectionVC") as! GenderSelectionVC
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - CLLocationManagerDelegate
extension PermissionVC: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        updateButtonTitleBasedOnPermission()
        switch status {
           case .authorizedWhenInUse, .authorizedAlways:
               locationManager.requestLocation()
               locationManager.startUpdatingLocation()
           
           case .denied, .restricted:
               if showAlert {
                   // User denied, proceed without location
                   SignUpData.shared.Lat = ""
                   SignUpData.shared.Long = ""
                   SignUpData.shared.Address = ""
                   SignUpData.shared.City = ""
                   SignUpData.shared.State = ""
                   redirectToNextScreen()
               }

           default:
               break
           }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        lat = "\(location.coordinate.latitude)"
        long = "\(location.coordinate.longitude)"

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Reverse geocoding error: \(error.localizedDescription)")
                return
            }

            guard let placemark = placemarks?.first else { return }

            self.City = placemark.locality ?? ""
            self.State = placemark.subAdministrativeArea ?? ""
            self.Address = placemark.administrativeArea ?? ""

            SignUpData.shared.Lat = self.lat
            SignUpData.shared.Long = self.long
            SignUpData.shared.Address = self.Address
            SignUpData.shared.City = self.City
            SignUpData.shared.State = self.State
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
