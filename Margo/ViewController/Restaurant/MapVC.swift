//
//  MapVC.swift
//  Margo
//
//  Created by Lenovo on 19/05/25.
//

import UIKit
import MapKit
import CoreLocation
import SDWebImage

class MapVC: UIViewController, CLLocationManagerDelegate ,MKMapViewDelegate{
    @IBOutlet weak var mapView : MKMapView!
    @IBOutlet weak var vwReasturantDetails : UIView!{
        didSet{
            self.vwReasturantDetails.isHidden = true
        }
    }
    
    @IBOutlet weak var lblRestName: UILabel!
    @IBOutlet weak var lblRestAddress: UILabel!
    @IBOutlet weak var vwDetails: UIView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgRest: SDAnimatedImageView!
    
    var arrLocation = [("41.838759", "-87.623277", "USA"),
                       ("37.808211","-122.415805","USA"),
                       ("12.975880","77.604523","INDIA"),
                       ("40.644551","-74.010895","USA"),
                       ("33.928703","-84.240784","USA"),
                       ("34.0843568","-118.40896","USA"),
                       ("37.808197021484375","-122.41580963134766","USA"),
                       ("28.6314022","77.2193791","INDIA"),
                       ("22.25770136871455","70.80013083087817","INDIA"),
                       ("38.404416","-122.365039","USA")]
    var arrRestaurantList = [MDRestaurantList]()
    var latitude = Double()
    var longitude = Double()
    var address = String()
    let locationManager = CLLocationManager()
    
    
//    var mapdata = [MDRestaurantLocation]
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.mapType = .standard
        mapView.overrideUserInterfaceStyle = .light
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        if let coor = mapView.userLocation.location?.coordinate{
            mapView.setCenter(coor, animated: true)
            
        }
        self.callGetRestaurantApi()
        
    }
//    MARK: - API calling
    func callGetRestaurantApi(){
        if SBUtill.reachable() {
            
            let params = [String : Any]()
            
            ClSApi.GetJsonModelValue(completion: { (data) in
                DispatchQueue.main.async { [self] in
                    
                     if let profileData = data["data"].array {
                         arrRestaurantList.removeAll()
                         for profile in profileData{
                             self.arrRestaurantList.append(MDRestaurantList(profile))
                         }
                         for (index,i) in arrLocation.enumerated(){
                           if self.arrRestaurantList.count - 1 >= index{
                                self.arrRestaurantList[index].latitude = i.0
                                self.arrRestaurantList[index].longitude = i.1
                                self.arrRestaurantList[index].country = i.2
                                
                            }
                         }
                         
                         self.setCordinate()
                    }else {
                        SBUtill.showToastWith(data["message"].stringValue)
                    }
                }
            }, Tag: ClS.API.get_restaurant, Prams: params, Method: ClS.get)
        }else {
            SBUtill.showToastWith(SBText.Message.noInternet)
        }
    }
//    MARK: - set up Annotation View & add Annotation
    func setCordinate(){
        var j = 0
        for i in arrRestaurantList{
            let lat = Double("\(i.latitude ?? "")") ?? 0.0
            let long = Double("\(i.longitude ?? "")") ?? 0.0
            let res_name = "\(i.title ?? "")"
            self.createAnnotations(latitude: lat, longitude: long, title: res_name)
            print(j)
            j += 1
        }
    }
    
    func createAnnotations(latitude:Double,longitude:Double,title:String){
        
        self.latitude = latitude
        self.longitude = longitude
             let address = CLGeocoder.init()
             
        address.reverseGeocodeLocation(CLLocation.init(latitude: latitude, longitude:longitude)) { (places, error) in
            if let places = places?.first {
                print(places)
                let annotations = MKPointAnnotation()
                annotations.coordinate = CLLocationCoordinate2D(latitude: latitude ,
                                                                longitude: longitude)
                annotations.title = title
                self.mapView.addAnnotation(annotations)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView: MKAnnotationView?
        
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }else{
            annotationView = MKAnnotationView(
                annotation: annotation,
                reuseIdentifier: annotationIdentifier
            )
            annotationView?.canShowCallout = true
        }
            if let annotationView = annotationView {
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "Map_Icon")
        }
        return annotationView
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? MKPointAnnotation else {
            return
        }
        if let restaurantLocation = arrRestaurantList.first(where: { $0.title ?? "" == annotation.title }) {
            UIView.animate(withDuration: 0.1, animations: {
                self.vwReasturantDetails.isHidden = false
                self.lblRestName.text = restaurantLocation.title ?? ""
                self.lblRestAddress.text = restaurantLocation.address ?? ""
                self.lblDescription.text = restaurantLocation.description ?? ""
                let imageURL = URL(string: restaurantLocation.image ?? "img_PlaceHolder")
                self.imgRest.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "img_PlaceHolder"))
            })
            
        }
    }
    //    MARK: - Action Methods
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnHideVwRestDetailsAction(_ sender: Any) {
        self.vwReasturantDetails.isHidden = true
    }
    @IBAction func btnScanAction(_ sender: Any) {
        self.vwReasturantDetails.isHidden = true
        let userSelectionVC = self.storyboard?.instantiateViewController(withIdentifier: "ScannerVC") as! ScannerVC
        self.navigationController?.pushViewController(userSelectionVC, animated: true)
        
    }
}
