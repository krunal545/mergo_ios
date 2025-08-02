//
//  ChatExtension.swift
//  FirebaseChat
//
//  Created by Techavtra's Mac Mini on 01/03/24.
//

import Foundation
import UIKit
import SDWebImage

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIImageView{
    
    func loadImageFromURL(url:String?,placeholderImage:UIImage){
        
        guard let strURL = url, let imageURL = URL.init(string: strURL) else {
            image = placeholderImage
            
            return
        }
        
        sd_setImage(with: imageURL, placeholderImage: placeholderImage, options: .highPriority) { (image, error, cacheType, url) in
            if let image = image{
                self.image = image
            }
        }
    }
}

extension UIView{
    
    func anchors(left:NSLayoutXAxisAnchor?,right:NSLayoutXAxisAnchor?,top:NSLayoutYAxisAnchor?,bottom:NSLayoutYAxisAnchor?,leftConstant:CGFloat = 0,rightConstant:CGFloat = 0,topConstant:CGFloat = 0,bottomCosntant:CGFloat = 0) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let leftAnchor = left{
            self.leftAnchor.constraint(equalTo: leftAnchor, constant: leftConstant).isActive = true
        }
        
        if let rightAnchor = right{
            self.rightAnchor.constraint(equalTo: rightAnchor, constant: rightConstant).isActive = true
        }
        
        if let topAnchor = top{
            self.topAnchor.constraint(equalTo: topAnchor, constant: topConstant).isActive = true
        }
        
        if let bottomAnchor = bottom{
            self.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottomCosntant).isActive = true
        }
    }
    
    func setHieghtOrWidth(height:CGFloat?,width:CGFloat?){
        self.translatesAutoresizingMaskIntoConstraints = false
        if let heightConst = height{
            self.heightAnchor.constraint(equalToConstant: heightConst).isActive = true
        }
        if let widthAnchor = width{
            self.widthAnchor.constraint(equalToConstant: widthAnchor).isActive = true
        }
    }
    
    func centerOnYOrX(x:Bool?,y:Bool?,xConst:CGFloat=0,yConst:CGFloat=0){
        self.translatesAutoresizingMaskIntoConstraints = false
        if x != nil && y != nil{
            
            self.centerOnSuperView(constantX: xConst , constantY: yConst)
        }else if x != nil{
            self.centerXAnchor.constraint(equalTo: self.superview!.centerXAnchor, constant: xConst ).isActive = true
        }else if y != nil{
            self.centerYAnchor.constraint(equalTo: self.superview!.centerYAnchor, constant: yConst).isActive = true
        }
    }
    
    func centerOnSuperView(constantX:CGFloat = 0 , constantY:CGFloat = 0 ){
        self.translatesAutoresizingMaskIntoConstraints = false
        if let subperView = self.superview{
            self.centerXAnchor.constraint(equalTo: subperView.centerXAnchor, constant: constantX).isActive = true
            self.centerYAnchor.constraint(equalTo: subperView.centerYAnchor, constant: constantY).isActive = true
        }
    }
}

extension Bundle {
    
    static func loadView<T>(fromNib name: String, withType type: T.Type) -> T {
        if let view = Bundle.main.loadNibNamed(name, owner: nil, options: nil)?.first as? T {
            return view
        }
        
        fatalError("Could not load view with type " + String(describing: type))
    }
}

extension UIView{
    func addNoDataView(title:String? = nil){
        //1001
        let view = viewWithTag(1001)
        if view == nil{
            let noDataView = Bundle.loadView(fromNib: "NoDataView", withType: NoDataView.self)
            noDataView.lblNoDataTitle.text = title ?? "No Data Available"
            noDataView.frame = self.bounds
            noDataView.backgroundColor = .clear
            addSubview(noDataView)
        }
    }
    
    func removeNoDataView(){
        let view = viewWithTag(1001)
        view?.removeFromSuperview()
    }
}



extension Date {
    func convertDate(dateValue: Int) -> String {
        let truncatedTime = Int(dateValue / 1000)
        let date = Date(timeIntervalSince1970: TimeInterval(truncatedTime))
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter.string(from: date)
    }
}
