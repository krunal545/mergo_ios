 //
//  RUExtension.swift
//  RateUs
//
//  Created by Abhijit Soni on 19/03/17.
//  Copyright © 2017 Abhijit Soni. All rights reserved.
//

import UIKit
import FirebaseMessaging
import FirebaseAuth

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

extension UIImageView{
    func addBlackGradientLayer(frame: CGRect){
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.colors = [UIColor.clear.cgColor, UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor]
        gradient.locations = [0.0, 1.0]
        self.layer.addSublayer(gradient)
    }
}



extension UIStoryboard {
    static var dashboard: UIStoryboard {
        return UIStoryboard(name: "Dashboard", bundle: nil)
    }
    static var storyboardMain: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    static var menu: UIStoryboard {
        return UIStoryboard(name: "Menu", bundle: nil)
    }
    public func get<T:UIViewController>(_ identifier: T.Type) -> T? {
        let storyboardID = String(describing: identifier)
        
        guard let viewController = instantiateViewController(withIdentifier: storyboardID) as? T else {
            return nil
        }
        
        return viewController
    }
}

extension Double {
    /// Returns propotional height according to device height
    var propotionalHeight: CGFloat {
        return Screen.height / CGFloat(IPHONE6_HEIGHT) * CGFloat(self)
    }
    
    /// Returns propotional width according to device width
    var propotional: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return CGFloat(IPHONE6_PLUS_WIDTH) / CGFloat(IPHONE6_WIDTH) * CGFloat(self)
        }
        return CGFloat(Screen.width) / CGFloat(IPHONE6_WIDTH) * CGFloat(self)
    }
    
    /// Returns rounded value for passed places
    ///
    /// - parameter places: Pass number of digit for rounded value off after decimal
    ///
    /// - returns: Returns rounded value with passed places
    func roundTo(_ places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension CGFloat {
    /// Returns propotional height according to device height
    var propotionalHeight: CGFloat {
        return Screen.height / CGFloat(IPHONE6_HEIGHT) * CGFloat(self)
    }
    
    /// Returns propotional width according to device width
    var propotional: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return CGFloat(IPHONE6_PLUS_WIDTH) / CGFloat(IPHONE6_WIDTH) * CGFloat(self)
        }
        return CGFloat(Screen.width) / CGFloat(IPHONE6_WIDTH) * CGFloat(self)
    }
}

extension String {
    
    var htmlDecoded: NSAttributedString {
        let decoded = try? NSAttributedString(data: Data(utf8), options: [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ], documentAttributes: nil)
        
        return decoded!
    }
    
    func getContactAttributed() -> NSAttributedString {
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 17.0)] as [NSAttributedString.Key : Any]
        let underlineAttributedString = NSAttributedString(string: self, attributes: underlineAttribute)
        return underlineAttributedString
    }
    
    func convertHtml() -> NSAttributedString{
        //        guard let data = data(using: .utf8) else { return NSAttributedString() }
        //        do{
        //            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue ], documentAttributes: nil)
        //        }catch{
        //            return NSAttributedString()
        //        }
        var valx=UIColor.init(named: "TextBackColorBlack")
        let htmlCSSString = "<style> body { color: \((UIColor.init(named: "TextBackColorBlack")?.toHexString())!) }</style> \(self)"
        
        print("htmlCSSString"+htmlCSSString)
        // let data = htmlCSSString.data(using: .utf8) else { return NSAttributedString() }
        guard let data = htmlCSSString.data(using: .utf8) else { return NSAttributedString() }
        do{
            
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html,  .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
            
        }catch{
            return NSAttributedString()
        }
    }
    
    func safelyLimitedTo(length n: Int)->String {
        if (self.count <= n) {
            return self
        }
        return String( Array(self).prefix(upTo: n) )
    }
    func height(constrainedBy width: CGFloat, with font: UIFont) -> CGFloat {
        let constraintSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintSize, options: .usesLineFragmentOrigin, attributes: [kCTFontAttributeName as NSAttributedString.Key: font], context: nil)
        
        return boundingBox.height
    }
    
    func width(constrainedBy height: CGFloat, with font: UIFont) -> CGFloat {
        let constrainedSize = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constrainedSize, options: .usesLineFragmentOrigin, attributes: [kCTFontAttributeName as NSAttributedString.Key: font], context: nil)
        
        return boundingBox.width
    }
    
    func estimatedHeightOfLabel(width:CGFloat) -> CGFloat {
        
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        let attributes = [kCTFontAttributeName: UIFont.boldSystemFont(ofSize: 14.0.propotional)]
        
        let rectangleHeight = self.boundingRect(with: size, options: options, attributes: attributes as [NSAttributedString.Key : Any], context: nil).height
        
        return rectangleHeight
    }
    
    /// Returns trim string
    var trimmed: String{
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    var boolValue: Bool {
        return NSString(string: self).boolValue
    }
    var cardFormatted: String {
        var output = ""
        self.replacingOccurrences(of: " ", with: "").enumerated().forEach { index, c in
            if index % 4 == 0 && index > 0 {
                output += " "
            }
            output.append(c)
        }
        return output
    }
    
    var cardDateFormatted: String {
        var output = ""
        self.replacingOccurrences(of: "/", with: "").enumerated().forEach { index, c in
            if index % 2 == 0 && index > 0 {
                output += "/"
            }
            output.append(c)
        }
        return output
    }
    
    /// Returns length of string
    var length: Int{
        return self.count
    }
    
    /// Returns length of string after trim it
    var trimmedLength: Int{
        return self.trimmed.length
    }
    func hexStringToUIColor () -> UIColor {
        var cString:String = self.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension UserDefaults {
    public subscript(key: String) -> Any? {
        get {
            return object(forKey: key) as Any?
        }
        set {
            set(newValue, forKey: key)
            synchronize()
        }
    }
    
    public static func contains(_ key: String) -> Bool {
        return self.standard.contains(key)
    }
    
    public func contains(_ key: String) -> Bool {
        return self.dictionaryRepresentation().keys.contains(key)
    }
    
    public func reset() {
        UserDefaults.standard.removeObject(forKey: UserKey)
        synchronize()
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension Date {
    var age: Int {
        return Calendar.current.dateComponents([.year], from: self, to: Date()).year!
    }
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfYear], from: date, to: self).weekOfYear ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
}

extension UIView {
    @IBInspectable var proRadius : CGFloat {
        get {
            return layer.cornerRadius
        }set {
            layer.cornerRadius = newValue.propotional
        }
    }
    @IBInspectable var customRadius : CGFloat {
        get {
            return layer.cornerRadius
        }set {
            layer.cornerRadius = newValue
        }
    }
    @IBInspectable var customBorderWidth : CGFloat {
        get {
            return layer.borderWidth
        }set {
            layer.borderWidth = newValue
        }
    }
    @IBInspectable var customBorderColor : UIColor {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }set {
            layer.borderColor = newValue.cgColor
        }
    }
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offSet
        self.layer.shadowRadius = radius
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}

extension UILabel {
    @IBInspectable var propotionalFontSize : CGFloat {
        get {
            return font.pointSize
        }set {
            font = UIFont(name: font.fontName, size: newValue.propotional)
            
        }
    }
}

private var __maxLengths = [UITextField: Int]()
extension UITextField {
    @IBInspectable var maxLength: Int {
        get {
            guard let l = __maxLengths[self] else {
                return 150 // (global default-limit. or just, Int.max)
            }
            return l
        }
        set {
            __maxLengths[self] = newValue
            addTarget(self, action: #selector(fix), for: .editingChanged)
        }
    }
    @objc func fix(textField: UITextField) {
        let t = textField.text
        textField.text = t?.safelyLimitedTo(length: maxLength)
    }
    
    @IBInspectable var propotionalFontSize : CGFloat {
        get {
            return font!.pointSize
        }set {
            font = UIFont(name: (font?.fontName)!, size: newValue.propotional)
            
        }
    }
}

extension UITextView:UITextViewDelegate {
    @IBInspectable var propotionalFontSize : CGFloat {
        get {
            return font!.pointSize
        }set {
            font = UIFont(name: (font?.fontName)!, size: newValue.propotional)
            
        }
    }
    
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    /// The UITextView placeholder text
    public var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }
    
    /// When the UITextView did change, show or hide the label based on if the UITextView is empty or not
    ///
    /// - Parameter textView: The UITextView that got updated
    public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = self.text.count > 0
        }
    }
    
    /// Resize the placeholder UILabel to make sure it's in the same position as the UITextView text
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top - 2
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height
            
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    /// Adds a placeholder UILabel to this UITextView
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.tag = 100
        
        placeholderLabel.isHidden = self.text.count > 0
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        self.delegate = self
    }
}

extension Notification.Name {
    static let userLoggedInOut = Notification.Name(
        rawValue: "userLoggedInOut")
}

extension UIButton {
    @IBInspectable var propotionalFontSize : CGFloat {
        get {
            return titleLabel!.font.pointSize
        }set {
            titleLabel!.font = UIFont(name: titleLabel!.font.fontName, size: newValue.propotional)
            
        }
    }
}



public enum PanDirection: Int {
    case up,
         down,
         left,
         right
    
    public var isX: Bool {
        return self == .left || self == .right
    }
    
    public var isY: Bool {
        return !isX
    }
}

extension UIImage {
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIPanGestureRecognizer {
    var direction: PanDirection? {
        let velocity = self.velocity(in: view)
        let vertical = fabs(velocity.y) > fabs(velocity.x)
        switch (vertical, velocity.x, velocity.y) {
        case (true, _, let y):
            return y < 0 ? .up : .down
            
        case (false, let x, _):
            return x > 0 ? .right : .left
        }
    }
}

extension Equatable {
    func share() {
        let activity = UIActivityViewController(activityItems: [self], applicationActivities: nil)
        Global.navigationController!.present(activity, animated: true, completion: nil)
    }
}

extension UISearchBar {
    
    func getTextField() -> UITextField? { return value(forKey: "searchField") as? UITextField }
    func setText(color: UIColor) { if let textField = getTextField() { textField.textColor = color } }
    func setPlaceholderText(color: UIColor) { getTextField()?.setPlaceholderText(color: color) }
    func setClearButton(color: UIColor) { getTextField()?.setClearButton(color: color) }
    
    func setTextField(color: UIColor) {
        guard let textField = getTextField() else { return }
        switch searchBarStyle {
        case .minimal:
            textField.layer.backgroundColor = color.cgColor
            textField.layer.cornerRadius = 6
        case .prominent, .default: textField.backgroundColor = color
        @unknown default: break
        }
    }
    
    func setSearchImage(color: UIColor) {
        guard let imageView = getTextField()?.leftView as? UIImageView else { return }
        imageView.tintColor = color
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
    }
}

extension UITextField {
    
    private class ClearButtonImage {
        static private var _image: UIImage?
        static private var semaphore = DispatchSemaphore(value: 1)
        static func getImage(closure: @escaping (UIImage?)->()) {
            DispatchQueue.global(qos: .userInteractive).async {
                semaphore.wait()
                DispatchQueue.main.async {
                    if let image = _image { closure(image); semaphore.signal(); return }
                    guard let window = UIApplication.shared.windows.first else { semaphore.signal(); return }
                    let searchBar = UISearchBar(frame: CGRect(x: 0, y: -200, width: UIScreen.main.bounds.width, height: 44))
                    window.rootViewController?.view.addSubview(searchBar)
                    searchBar.text = "txt"
                    searchBar.layoutIfNeeded()
                    _image = searchBar.getTextField()?.getClearButton()?.image(for: .normal)
                    closure(_image)
                    searchBar.removeFromSuperview()
                    semaphore.signal()
                }
            }
        }
    }
    
    func setClearButton(color: UIColor) {
        ClearButtonImage.getImage { [weak self] image in
            guard   let image = image,
                    let button = self?.getClearButton() else { return }
            button.imageView?.tintColor = color
            button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    func setPlaceholderText(color: UIColor) {
        attributedPlaceholder = NSAttributedString(string: placeholder != nil ? placeholder! : "", attributes: [.foregroundColor: color])
    }
    
    func getClearButton() -> UIButton? { return value(forKey: "clearButton") as? UIButton }
}


extension UIApplication { func makeSnapshot() -> UIImage? { return keyWindow?.layer.makeSnapshot() } }

extension CALayer {
    func makeSnapshot() -> UIImage? {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        render(in: context)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        return screenshot
    }
}

extension UIView {
    func makeSnapshot() -> UIImage? {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(size: frame.size)
            return renderer.image { _ in drawHierarchy(in: bounds, afterScreenUpdates: true) }
        } else {
            return layer.makeSnapshot()
        }
    }
    
    func addBottomShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.masksToBounds = false
    }
    
}

extension UIImage {
    convenience init?(snapshotOf view: UIView) {
        guard let image = view.makeSnapshot(), let cgImage = image.cgImage else { return nil }
        self.init(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}

//
//    public func get<T:UIViewController>(_ identifier: T.Type) -> T? {
//        let storyboardID = String(describing: identifier)
//
//        guard let viewController = instantiateViewController(withIdentifier: storyboardID) as? T else {
//            return nil
//        }
//
//        return viewController
//    }

extension UIView {
    func dropShadow() {
        
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 6
        
    }
}

extension UIStoryboard {
    static var Home: UIStoryboard {
        return UIStoryboard(name: "TabBar", bundle: nil)
    }
    
    static var subscription: UIStoryboard {
        return UIStoryboard(name: "Subscription", bundle: nil)
    }
}

extension UIView {
    func roundCorners(view :UIView, corners: UIRectCorner, radius: CGFloat){
        let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        view.layer.mask = mask
    }
}

extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

extension UINavigationController {
    
    func popBack(_ nb: Int) {
        let viewControllers: [UIViewController] = self.viewControllers
        guard viewControllers.count < nb else {
            self.popToViewController(viewControllers[viewControllers.count - nb], animated: true)
            return
        }
    }
    
    /// pop back to specific viewcontroller
    func popBack<T: UIViewController>(toControllerType: T.Type) {
        var viewControllers: [UIViewController] = self.viewControllers
        viewControllers = viewControllers.reversed()
        for currentViewController in viewControllers {
            if currentViewController .isKind(of: toControllerType) {
                self.popToViewController(currentViewController, animated: true)
                break
            }
        }
    }
}

extension UIColor {
    static func random() -> UIColor {
        func random() -> CGFloat { return .random(in:0...1) }
        return UIColor(red:   random(),
                       green: random(),
                       blue:  random(),
                       alpha: 1.0)
    }
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}
extension Dictionary {
    subscript(keyPath keyPath: String) -> Any? {
        get {
            guard let keyPath = Dictionary.keyPathKeys(forKeyPath: keyPath)
            else { return nil }
            return getValue(forKeyPath: keyPath)
        }
        set {
            guard let keyPath = Dictionary.keyPathKeys(forKeyPath: keyPath),
                  let newValue = newValue else { return }
            self.setValue(newValue, forKeyPath: keyPath)
        }
    }
    
    static private func keyPathKeys(forKeyPath: String) -> [Key]? {
        let keys = forKeyPath.components(separatedBy: ".")
            .reversed().flatMap({ $0 as? Key })
        return keys.isEmpty ? nil : keys
    }
    
    // recursively (attempt to) access queried subdictionaries
    // (keyPath will never be empty here; the explicit unwrapping is safe)
    private func getValue(forKeyPath keyPath: [Key]) -> Any? {
        guard let value = self[keyPath.last!] else { return nil }
        return keyPath.count == 1 ? value : (value as? [Key: Any])
            .flatMap { $0.getValue(forKeyPath: Array(keyPath.dropLast())) }
    }
    
    // recursively (attempt to) access the queried subdictionaries to
    // finally replace the "inner value", given that the key path is valid
    private mutating func setValue(_ value: Any, forKeyPath keyPath: [Key]) {
        guard self[keyPath.last!] != nil else { return }
        if keyPath.count == 1 {
            (value as? Value).map { self[keyPath.last!] = $0 }
        }
        else if var subDict = self[keyPath.last!] as? [Key: Value] {
            subDict.setValue(value, forKeyPath: Array(keyPath.dropLast()))
            (subDict as? Value).map { self[keyPath.last!] = $0 }
        }
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
extension AppDelegate:UNUserNotificationCenterDelegate,MessagingDelegate{
    
    func configureFirebasePushNotifications(_ application: UIApplication, completion: @escaping (Bool) -> Void)
    {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, _ in
                DispatchQueue.main.async {
                    if granted {
                        SignUpData.shared.notification = "1"
                        UIApplication.shared.registerForRemoteNotifications()
                        completion(true)
                    } else {
                        SignUpData.shared.notification = "0"
                        completion(false)
                    }
                }
            }
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            completion(true)
        }
        
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if Auth.auth().canHandleNotification(userInfo) {
            return
        }
        print("Received remote notification but not handled by Firebase Auth")
        
        if let messageID = userInfo["gsm.Message_ID"] {
            print("Message ID: \(messageID)")
        }
        
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
            return
        }

        // Your additional handling here (optional)
        completionHandler(.newData)
        // Print full message.
        print(userInfo)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        print(userInfo)
        completionHandler([.alert, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        
        // ...
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print full message.
        print(userInfo)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        SBGlobal.fcm = fcmToken!
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
}
