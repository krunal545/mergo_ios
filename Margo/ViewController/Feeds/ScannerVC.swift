//
//  ScannerVC.swift
//  Qrchat
//
//  Created by Dharmesh A Nagvadia on 04/02/25.
//

import UIKit
import MercariQRScanner
import AVFoundation
class ScannerVC: UIViewController {
   
    @IBOutlet weak var scnrVW: QRScannerView!
   
    var isFromHome = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupQRScanner()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        scnrVW.stopRunning()
        //self.callScanAPI(qr_code: "6787756607bd0")
    }
    
    func callScanAPI(qr_code:String){
        if SBUtill.reachable() {
            SBUtill.showProgress()
            let params = ["qr_code":qr_code] as [String : Any]
            
            ClSApi.GetJsonModelValue(completion: { (data) in
                DispatchQueue.main.async { [self] in
                    Global.saveQRCode = qr_code
                    if (data["data"].dictionary != nil) {
                        SBUtill.showToastWith("Scanned successfully. Please wait while we are fetching the people.")
                        let now = Date()
                        UserDefaults.standard.set(now, forKey: "LastAPICallTime")
                    }else {
                        SBUtill.showToastWith(data["message"].stringValue)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                        SBUtill.dismissProgress()
                   
                        self.navigationController?.popViewController(animated: true)

                        if self.isFromHome{
                            if let tabBarController = self.tabBarController,
                               let tabViewControllers = tabBarController.viewControllers,
                               tabViewControllers.count > 2,
                               let navController = tabViewControllers[2] as? UINavigationController {
                                tabBarController.selectedIndex = 2
                            }
                        }
                       
                       
                    }
                }
            }, Tag: ClS.API.qr_code_scan, Prams: params, Method: ClS.post)
        }else {
            SBUtill.showToastWith(SBText.Message.noInternet)
        }
    }
    
    private func setupQRScanner() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupQRScannerView()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupQRScannerView()
                    }
                } else {
                    self?.showPermissionAlert()
                }
            }
        default:
            showPermissionAlert()
        }
    }
    
    private func showPermissionAlert() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            let alert = UIAlertController(
                title: "Camera Permission Required",
                message: "Please enable camera access in Settings to scan QR codes.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }
    
    private func setupQRScannerView() {
        scnrVW.configure(delegate: self, input: .init(isBlurEffectEnabled: true))
        scnrVW.startRunning()
    }
    
    @IBAction func btnRescanAction(_ sender: Any) {
        scnrVW.rescan()
//        self.callScanAPI(qr_code: "6787756607bd0")
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ScannerVC: QRScannerViewDelegate{
    func qrScannerView(_ qrScannerView: MercariQRScanner.QRScannerView, didFailure error: MercariQRScanner.QRScannerError) {
        let alert = UIAlertController(
            title: "Scan Failed",
            message: "Unable to process the QR code. Please rescan.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
       
    }
    
    func qrScannerView(_ qrScannerView: MercariQRScanner.QRScannerView, didSuccess code: String) {
       // SBUtill.showToastWith(code)
        self.callScanAPI(qr_code: code)
       // self.navigationController?.popViewController(animated: true)
    }
    
}
