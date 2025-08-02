//
//  ProfileTabVC.swift
//  Margo
//
//  Created by Only Mac on 11/01/25.
//

import UIKit
import iOSDropDown
import SDWebImage
import Photos

class ProfileTabVC: UIViewController {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblCountryCode: UILabel!
    @IBOutlet weak var tfMobileNumber: UITextField!
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfGender: UITextField!
    @IBOutlet weak var ddDatInt: DropDown!
    @IBOutlet weak var ddHeight: DropDown!
    @IBOutlet weak var tvBio: UITextView!
    @IBOutlet weak var vwPhoneNumber: UIView!
    @IBOutlet weak var stkProfile: UIStackView!
    
    @IBOutlet weak var btnEditProfile: UIButton!
    //    Profile Image Outlets
    
    @IBOutlet weak var imgP1: SDAnimatedImageView!
    @IBOutlet weak var imgP2: SDAnimatedImageView!
    @IBOutlet weak var imgP3: SDAnimatedImageView!
    @IBOutlet weak var imgP4: SDAnimatedImageView!
    @IBOutlet weak var imgP5: SDAnimatedImageView!
    @IBOutlet weak var imgP6: SDAnimatedImageView!
    
    @IBOutlet weak var vwImgP1: UIView!
    @IBOutlet weak var vwImgP2: UIView!
    @IBOutlet weak var vwImgP3: UIView!
    @IBOutlet weak var vwImgP4: UIView!
    @IBOutlet weak var vwImgP5: UIView!
    @IBOutlet weak var vwImgP6: UIView!
    
    @IBOutlet weak var vwEditImgP1: UIView!
    @IBOutlet weak var vwEditImgP2: UIView!
    @IBOutlet weak var vwEditImgP3: UIView!
    @IBOutlet weak var vwEditImgP4: UIView!
    @IBOutlet weak var vwEditImgP5: UIView!
    @IBOutlet weak var vwEditImgP6: UIView!
    
    var userProfile: User?
    var datInt = [String]()
    var heights = [String]()
    var arrImageViews =  [UIImageView]()
    var arrAddImgView = [UIView]()
    var arrEditImgView = [UIView]()
    var arrProfileImg = [UIImage]()
    var selectedIndex: Int?
    var isPhotoPermissionEnable = false
    var isPermissionDenid = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datInt = SBText.Other.datingIntensions
        heights = SBText.Other.heightArray
        
        arrImageViews = [imgP1, imgP2, imgP3, imgP4, imgP5, imgP6]
        arrAddImgView = [vwImgP1, vwImgP2, vwImgP3, vwImgP4, vwImgP5, vwImgP6]
        arrEditImgView = [vwEditImgP1, vwEditImgP2, vwEditImgP3, vwEditImgP4, vwEditImgP5, vwEditImgP6]
        
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let status = PHPhotoLibrary.authorizationStatus()
            switch status {
            case .authorized:
                self.isPhotoPermissionEnable = true
            case .denied, .restricted:
                self.isPhotoPermissionEnable = false
                self.isPermissionDenid = true
            case .notDetermined:
                self.isPhotoPermissionEnable = false
             
            case .limited:
                self.isPhotoPermissionEnable = true
            @unknown default:
                break
            }
        
        callGetProfileApi()
    }	
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        btnEditProfile.setTitle("Edit Profile", for: .normal)
        stkProfile.isUserInteractionEnabled = false
        self.view.endEditing(true)
    }
//    MARK: - Methods
    
    func callGetProfileApi(){
        if SBUtill.reachable() {
            //SBUtill.showProgress()
            
            let params = ["user_id":Global.user?.id]
            
            ClSApi.GetJsonModelValue(completion: { (data) in
                DispatchQueue.main.async { [self] in
                  //  SBUtill.dismissProgress()
                    //                    data["success"].boolValue,
                    if data["data"].dictionary != nil {
                        userProfile = User(data["data"])
                        if let userData = self.userProfile{
                            userData.saveInUserDefaults()
                        }
                        setData()
                    }else {
                        SBUtill.showToastWith(data["message"].stringValue)
                    }
                }
            }, Tag: ClS.API.get_profile, Prams: params, Method: ClS.post)
        }else {
            SBUtill.showToastWith(SBText.Message.noInternet)
        }
    }
   
    func callEditProfileApi(){
        if SBUtill.reachable() {
            SBUtill.showProgress()
            var gender = tfGender.text == "Male" ? 0 : 1
            let params = [ "name": tfFirstName.text ?? "",
                           "last_name": tfLastName.text ?? "",
                           "height": ddHeight.text ?? "" ,
                           "gender": gender,
                        "description": tvBio.text ?? "",
                           "dating_intentions": ddDatInt.text ?? ""] as [String : Any]
            
            ClSApi.GetJsonModelValue(completion: { (data) in
                DispatchQueue.main.async { [self] in
                    SBUtill.dismissProgress()
                    //                    data["success"].boolValue,
                    if data["data"].dictionary != nil {
                            callGetProfileApi()
                        SBUtill.showToastWith(data["message"].stringValue)
                    }else {
                        SBUtill.showToastWith(data["message"].stringValue)
                    }
                }
            }, Tag: ClS.API.complete_profile, Prams: params, Method: ClS.post)
        }else {
            SBUtill.showToastWith(SBText.Message.noInternet)
        }
    }
    
    func setData(){
        lblName.text = (userProfile?.name ?? "") + " " + (userProfile?.lastName ?? "")
        lblEmail.text = userProfile?.email
        if userProfile?.profileImage?.count != 0{
            let urls = URL(string: userProfile?.profileImage?[0] ?? "")
            imgProfile.sd_setImage(with: urls, placeholderImage: UIImage(named: "ic_profile"))
        }
        lblCountryCode.text = userProfile?.countryCode
        tfMobileNumber.text = userProfile?.phoneNo
        tfFirstName.text = userProfile?.name
        tfLastName.text = userProfile?.lastName
        tfGender.text = userProfile?.gender == 0 ? "Male" : "Female"
        ddDatInt.inputView = UIView()
        ddDatInt.isUserInteractionEnabled = true
        ddDatInt.delegate = self
        ddDatInt.optionArray = datInt
        ddDatInt.arrowColor = .clear
        ddDatInt.selectedIndex = datInt.firstIndex(of: userProfile?.datingIntension ?? "")
        ddDatInt.text = userProfile?.datingIntension
        ddDatInt.addTarget(self, action: #selector(showDatingIntDropdown), for: .touchDown)
        
        ddDatInt.didSelect { (selectedText , index ,id) in
            self.ddDatInt.text = selectedText
        }
        
        ddHeight.inputView = UIView()
        ddHeight.isUserInteractionEnabled = true
        ddHeight.delegate = self
        ddHeight.optionArray = heights
        ddHeight.arrowColor = .clear
        ddHeight.selectedIndex = heights.firstIndex(of: userProfile?.height ?? "")
        ddHeight.text = userProfile?.height
        ddHeight.addTarget(self, action: #selector(showDropdown), for: .touchDown)
        ddHeight.didSelect{(selectedText , index ,id) in
            self.ddHeight.text = selectedText
        }
        
        tvBio.text = userProfile?.user_description
        setProfileImage()
    }
    
    func setProfileImage(){
        arrProfileImg.removeAll()
        for image in arrImageViews {
            image.image = nil
        }
        if let profileImageUrls = userProfile?.profileImage, profileImageUrls.count > 0 {
            for (index, imageView) in arrImageViews.enumerated() {
                if index < profileImageUrls.count, let url = URL(string: profileImageUrls[index]) {
                    
                    arrAddImgView[index].isHidden = true
                    arrEditImgView[index].isHidden = true
                    imageView.isHidden = false
                    imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
                    imageView.backgroundColor = .white
                }else{
                    arrAddImgView[index].isHidden = false
                    arrEditImgView[index].isHidden = true
                    imageView.isHidden = true
                }
            }
        }
    }
    
    func callUpdateProfileImgAPI(){
        if SBUtill.reachable() {
            SBUtill.showProgress()
            let param = ["":""]
            arrProfileImg.removeAll()
            for image in arrImageViews {
                if image.image != nil{
                    arrProfileImg.append((image.image ?? UIImage(named: ""))!)
                }
            }
            ClSApi.uploadArrImgRequest(completion: { data in
                SBUtill.dismissProgress()
                DispatchQueue.main.async {
                    if let dataUser = data["data"].array,dataUser.count != 0{
                     
                        self.callGetProfileApi()
                    }else{
                        SBUtill.showToastWith(data["message"].stringValue)
                    }
                }
                
            }, Tag: ClS.API.profile_image_update, Prams: param, images: arrProfileImg, view: self, isFromEdit: false)
        }else{
            SBUtill.showToastWith(SBText.Message.NoInternetSnack)
        }
    }
    
    func photoRequestAuthorization(){
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                self.isPhotoPermissionEnable = true
                print("Photo library access authorized")
            case .denied, .restricted:
                self.isPhotoPermissionEnable = false
                self.isPermissionDenid = true
                print("Photo library access denied or restricted")
            case .notDetermined:
                self.isPhotoPermissionEnable = true
                print("Photo library access not determined")
            default:
                break
            }
        }
    }
//    MARK: - Action Methods
    @objc func showDatingIntDropdown() {
        ddDatInt.showList()
    }
    @objc func showDropdown() {
        ddHeight.showList()
    }
    
    @IBAction func btnEditProfile(_ sender: UIButton) {
        self.view.endEditing(true)
        if sender.titleLabel?.text == "Edit Profile"{
            sender.setTitle("Submit", for: .normal)
            stkProfile.isUserInteractionEnabled = true
            ddDatInt.arrowColor = .black
            ddHeight.arrowColor = .black
            
            for (index, imageView) in arrImageViews.enumerated() {
                if imageView.image != nil {
                    arrAddImgView[index].isHidden = true
                    arrEditImgView[index].isHidden = false
                }else{
                    arrAddImgView[index].isHidden = false
                    arrEditImgView[index].isHidden = true
                }
            }
        }else{
            sender.setTitle("Edit Profile", for: .normal)
            stkProfile.isUserInteractionEnabled = false
            ddDatInt.arrowColor = .clear
            ddHeight.arrowColor = .clear
            callEditProfileApi()
           // callUpdateProfileImgAPI()
            
        }
    }
    
    @IBAction func btnAddEditImageAction(_ sender: UIButton) {
        if isPhotoPermissionEnable {
            selectedIndex = sender.tag
            presentImagePicker()
        }else{
            if isPermissionDenid {
                showAlert()
            }else {
                photoRequestAuthorization()
            }
        }
    }
    
    @IBAction func btnSettingsAction(_ sender: Any) {
        let settingsVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
    
}
extension ProfileTabVC: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
}
extension ProfileTabVC : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    func AddImage() {
        let alert = UIAlertController(title: "", message: "Choose File", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
            UIAlertAction in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let vc = UIImagePickerController()
                vc.sourceType = .camera
                vc.delegate = self
                vc.allowsEditing = true
                self.present(vc, animated: true, completion: nil)
            } else {
                SBUtill.showToastWith(SBText.Message.NoInternetSnack)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: {
            UIAlertAction in
            SBUtill.showProgress()
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let vc = UIImagePickerController()
                vc.sourceType = .photoLibrary
                vc.delegate = self
                self.present(vc, animated: true)
            } else {
                SBUtill.showToastWith(SBText.Message.NoInternetSnack)
            }
            SBUtill.dismissProgress()
        }))
        
        self.present(alert, animated: true)
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
    
    func presentImagePicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage, let selectedIndex = selectedIndex else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        arrEditImgView[selectedIndex].isHidden = false
        arrImageViews[selectedIndex].isHidden = false
        arrAddImgView[selectedIndex].isHidden = true
        
        arrImageViews[selectedIndex].image = image
        callUpdateProfileImgAPI()
        print("Updating image at index \(selectedIndex)")
        print("Image at index \(selectedIndex): \(image)")
        self.selectedIndex = nil
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
