//
//  PortraitsVC.swift
//  Margo
//
//  Created by Lenovo on 10/01/25.
//

import UIKit
import Photos

class PortraitsVC: UIViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    
    var selectedIndex: IndexPath?
    var selectedImages: [IndexPath: UIImage] = [:]
    var isPermissionEnable: Bool?

    @IBOutlet var imgCheckMark: UIImageView! // This is your extra image view
    @IBOutlet var btnCheckBox: UIButton!
    @IBOutlet weak var vwDropShadow: UIView!
    @IBOutlet weak var collView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    var user : User?
    override func viewDidLoad() {
        super.viewDidLoad()
        vwDropShadow.addBottomShadow()
        btnCheckBox.setImage(UIImage(systemName: "square"), for: .normal)
        btnCheckBox.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        
        let status = PHPhotoLibrary.authorizationStatus()
            switch status {
            case .authorized:
                self.isPermissionEnable = true
                
                print("Photo library access authorized")
            case .denied, .restricted:
                self.isPermissionEnable = false
            case .notDetermined:
                self.isPermissionEnable = false
            @unknown default:
                break
            }
        self.Permision()
    }
    
    func Permision(){
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                // Access to photo library authorized
                self.isPermissionEnable = true
                print("Photo library access authorized")
            case .denied, .restricted:
                self.isPermissionEnable = false
                print("Photo library access denied or restricted")
            case .notDetermined:
                self.isPermissionEnable = false
                print("Photo library access not determined")
            default:
                break
            }
        }
    }
    func AddImage(){
        let alert = UIAlertController(title: "", message: "Choose File", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
            UIAlertAction in
            if(UIImagePickerController.isSourceTypeAvailable(.camera)){
                let vc = UIImagePickerController()
                vc.sourceType = .camera
                vc.delegate = self
                vc.allowsEditing = true
                self.present(vc, animated: true, completion: nil)
            }else{
                SBUtill.showToastWith(SBText.Message.NoInternetSnack)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: {
            UIAlertAction in
            SBUtill.showProgress()
            if(UIImagePickerController.isSourceTypeAvailable(.photoLibrary)){
                let vc = UIImagePickerController()
                vc.sourceType = .photoLibrary
                vc.delegate = self
                self.present(vc, animated: true)
            }else{
                SBUtill.showToastWith(SBText.Message.NoInternetSnack)
            }
            SBUtill.dismissProgress()
        }))
        
        self.present(alert, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage, let selectedIndex = selectedIndex {
            selectedImages[selectedIndex] = image
            collView.reloadItems(at:[selectedIndex] )
            
            self.selectedIndex = nil // Reset selectedIndex after setting the image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
  
    func showAlert() {
        let alertController = UIAlertController(title: "Photos Access Denied", message: "Please enable photo access in Settings to use this feature. or go with Not Allow", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true)
    }
    
    @IBAction func btnNextAction(_ sender: Any) {
        if selectedImages.keys.count < 2{
            SBUtill.showToastWith("Please select at least two images.")
        }else if btnCheckBox.isSelected == false{
            SBUtill.showToastWith("You must agree to the terms in order to proceed.")
        }else{
                callSingUpAPI()
            }
        }
    
    @IBAction func btnTermsAndCondition(_ sender: UIButton) {
        btnCheckBox.isSelected.toggle()
//        let imageName = btnCheckBox.isSelected ? "checkmark.square.fill" : "square"
//           imgCheckMark.image = UIImage(systemName: imageName)
    }
    
    @IBAction func btnTermsAndConditionAction(_ sender: UIButton) {
        let termsStoryboard = UIStoryboard(name: "TabBar", bundle: nil)
        if let vc = termsStoryboard.instantiateViewController(withIdentifier: "Terms_ConditionsVC") as? Terms_ConditionsVC {
            vc.htmlString = SignUpData.shared.termsAndCondition ?? ""
            vc.isFromTermsCondition = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}


extension PortraitsVC : UICollectionViewDataSource , UICollectionViewDelegate , UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImgCollCell", for: indexPath) as! ImgCollCell
        
        if indexPath.item == 0 {
            cell.lblMain.isHidden = false
            cell.vwMain.isHidden = false
        }else {
            cell.lblMain.isHidden = true
            cell.vwMain.isHidden = true
        }
        if let selectedImage = selectedImages[indexPath] {
            cell.img.image = selectedImage
            cell.btnAddImage.isHidden = true
            cell.vwImgEdit.isHidden = false
            cell.vwMain.isHidden = true
            cell.lblMain.isHidden = true
        } else {
            cell.btnAddImage.isHidden = false
            cell.vwImgEdit.isHidden = true
            cell.img.image = nil // Clear image if none is selected
        }
        
        if let selectedIndex = selectedIndex, selectedIndex == indexPath {
            cell.img.isHidden = false
        } else {
            cell.img.isHidden = true
            
        }
        
        
        cell.AddImage = {
            if self.isPermissionEnable == false {
                self.showAlert()
                }else{
                    self.selectedIndex = indexPath
                    collectionView.reloadItems(at: [indexPath])
                    self.AddImage()
                }
           
//            
//            if self.isPermissionEnable == false{
//                self.showAlert()
//            }else{
//                
//            }
        }
        cell.EditImage = {
            if self.isPermissionEnable == false{
                self.showAlert()
            }else{
                self.selectedIndex = indexPath
                collectionView.reloadItems(at: [indexPath])
                self.AddImage()
            }
         
        }
        
        self.updateCollectionViewHeight()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width / 3
        return CGSize(width: width, height: width + 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func updateCollectionViewHeight() {
        let totalItems = 6
        let itemsPerRow = 3 
        
        let numberOfRows = totalItems / itemsPerRow + (totalItems % itemsPerRow == 0 ? 0 : 1)
        
        let cellHeight: CGFloat = collView.frame.width / CGFloat(itemsPerRow)
        
        let totalCellHeight = CGFloat(numberOfRows) * cellHeight
        
        let collectionViewBottomInset = collView.contentInset.bottom
        let adjustedHeight = totalCellHeight + collectionViewBottomInset
        
        collectionViewHeightConstraint.constant = collView.contentSize.height
        view.layoutIfNeeded()
    }

    func callSingUpAPI(){
        if SBUtill.reachable() {
            SignUpData.shared.Profile_Images = Array(selectedImages.values)
            
            SBUtill.showProgress()
            let name = SignUpData.shared.Name ?? ""
            let lastName = SignUpData.shared.LastName ?? ""
            let appleID = SignUpData.shared.apple_id ?? ""
            let googleID = SignUpData.shared.google_id ?? ""
            let email = SignUpData.shared.Email ?? ""
            let countryCode = SignUpData.shared.CountryCode ?? ""
            let phoneNo = SignUpData.shared.PhoneNumber ?? ""
            let gender = SignUpData.shared.Gender ?? 0
            let height = SignUpData.shared.Height ?? ""
            let dob = SignUpData.shared.DOB ?? ""
            let lat = SignUpData.shared.Lat ?? ""
            let long = SignUpData.shared.Long ?? ""
            let city = SignUpData.shared.City ?? ""
            let state = SignUpData.shared.State ?? ""
            let address = SignUpData.shared.Address ?? ""
            let datingIntentions = SignUpData.shared.DatingIntension ?? ""
            let datingIntentionsVisible = SignUpData.shared.DatingIntentionsVisible ?? 0
            let notification = SignUpData.shared.notification ?? ""
            let platform = "IOS"
            let deviceToken = SBGlobal.fcm
            let prefrence = SignUpData.shared.Prefernce ?? 0
            let params: [String: Any] = [
                "name": name,
                "last_name": lastName,
                "apple_id": appleID,
                "google_id": googleID,
                "email": email,
                "country_code": countryCode,
                "phone_no": phoneNo,
                "password": "",
                "gender": gender,
                "height": height,
                "dob": dob,
                "lat": lat,
                "long": long,
                "city": city,
                "state": state,
                "address": address,
                "dating_intentions": datingIntentions,
                "dating_intentions_visible": datingIntentionsVisible,
                "description": "",
                "platform": platform,
                "device_token": deviceToken,
                "notification": notification,
                "preference": prefrence
            ]
            
            ClSApi.uploadArrImgRequest(completion: { data in
                SBUtill.dismissProgress()
                
                DispatchQueue.main.async {
                    if data["data"].dictionary != nil{
//                        SBUtill.showToastWith(data["message"].stringValue)
                        self.user = User(data["data"])
                        Global.user = self.user
                        Global.apiToken = self.user?.apiToken ?? ""
                        UserDefault.set(self.user?.apiToken, forKey: KeyMessage.apiToken)
                        if let userData = self.user{
                            userData.saveInUserDefaults()
                        }
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TermsConditionVC") as! TermsConditionVC
                        vc.modalTransitionStyle = .crossDissolve
                        vc.modalPresentationStyle = .overFullScreen
                        self.present(vc, animated: true)
                        
                       
                        
                    }else{
//                        SBUtill.showToastWith(data["message"].stringValue)
                    }
                }
            }, Tag: ClS.API.signup, Prams: params, images: SignUpData.shared.Profile_Images, view: self, isFromEdit: true)
            
        }else {
            SBUtill.showToastWith(SBText.Message.NoInternetSnack)
        }
    }
    
}


