//
//  OtherExtensions.swift
//  NewsReader

import Foundation
import UIKit
import SystemConfiguration

protocol Utilities {
}

//MARK:- Utilities Extensions
extension NSObject:Utilities {
    
    enum ReachabilityStatus {
        case notReachable
        case reachableViaWWAN
        case reachableViaWiFi
    }
    
    var currentReachabilityStatus: ReachabilityStatus {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return .notReachable
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return .notReachable
        }
        if flags.contains(.reachable) == false {
            return .notReachable
        }
        else if flags.contains(.isWWAN) == true {
            return .reachableViaWWAN
        }
        else if flags.contains(.connectionRequired) == false {
            return .reachableViaWiFi
        }
        else if (flags.contains(.connectionOnDemand) == true || flags.contains(.connectionOnTraffic) == true) && flags.contains(.interventionRequired) == false {
            return .reachableViaWiFi
        }
        else {
            return .notReachable
        }
    }
    
}   

//MARK:-UIColor Extensions
extension UIColor {
    
    class func hexStringToUIColor (hex:String, withOpacity: CGFloat) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(withOpacity)
        )
    }
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat)->UIColor{
        return UIColor(red:red/255 , green: green/255, blue: blue/255, alpha: 1)
    }
    
    
}


//MARK: Dictionary [AnyHashable: Any]

extension Dictionary where Key: Hashable, Value: Any
{
    func getDataFromDictionary() -> Data? {
        do {
            let taskData = try JSONSerialization.data(withJSONObject: self as Any, options: .prettyPrinted)
            return taskData
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
}

//MARK:- UIWindow Extensions

extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.connectedScenes
            // Keep only active scenes, onscreen and visible to the user
                .filter { $0.activationState == .foregroundActive }
            // Keep only the first `UIWindowScene`
                .first(where: { $0 is UIWindowScene })
            // Get its associated windows
                .flatMap({ $0 as? UIWindowScene })?.windows
            // Finally, keep only the key window
                .first(where: \.isKeyWindow)
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}

//MARK:- UIView Extensions

extension UIView {
    
    func addConstraints(_ format: String, constraintViews: [UIView]) {
        var viewsDictionary = [String: Any]()
        for view: UIView in constraintViews {
            let key = "v\((constraintViews as NSArray).index(of: view))"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: [], metrics: nil, views: viewsDictionary))
    }
    
    func showNoDataLabel(withText text: String?) {
        hideNoDataLabel()
        layoutIfNeeded()
        let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 20))
        noDataLabel.text = text
        noDataLabel.textAlignment = .center
        noDataLabel.font = UIFont.systemFont(ofSize: 16)
        noDataLabel.textColor = .lightGray
        noDataLabel.sizeToFit()
        noDataLabel.tag = NO_DATA_LABEL_TAG
        if (self is UITableView) {
            let tableView = self as? UITableView
            tableView?.tableHeaderView = noDataLabel
            var frame: CGRect? = tableView?.tableHeaderView?.frame
            frame?.size.height = tableView?.frame.size.height ?? 0.0
            tableView?.tableHeaderView?.frame = frame ?? CGRect.zero
            tableView?.reloadData()
        } else {
            noDataLabel.center = center
            var frame: CGRect = noDataLabel.frame
            frame.origin.y = self.frame.size.height / 2 - 10
            noDataLabel.frame = frame
            addSubview(noDataLabel)
            bringSubviewToFront(noDataLabel)
        }
    }
    
    func hideNoDataLabel() {
        if (self is UITableView) {
            let tableView = self as? UITableView
            //            tableView?.tableHeaderView = UIView()
            tableView?.tableHeaderView = nil
        } else {
            viewWithTag(NO_DATA_LABEL_TAG)?.removeFromSuperview()
        }
    }
    
    func setInterfaceTheme() {
        let windowStyle = self.window?.overrideUserInterfaceStyle
        if (windowStyle == .dark) {
            self.window?.overrideUserInterfaceStyle = .light
        } else {
            self.window?.overrideUserInterfaceStyle = .dark
        }
    }
    
    func dropShadow() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        layer.shadowOpacity = 0.7
    }
}

//MARK: UIViewController Extensions

extension UIViewController {
    
    //MARK:- For InternetConnectivity Observers
    func addObserverForInternetConnectivity() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.gotInternetConnectivity), name: NSNotification.Name.INTERNET_CONNECTION, object: nil)
    }
    
    func removeObserverForInternetConnectivity() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.INTERNET_CONNECTION, object: nil)
    }
    
    @objc func gotInternetConnectivity() {
        SHOW_TOAST("Connection established")
    }
}

//MARK: Extention for Array

extension Array {
    func indexesOf<T : Equatable>(object:T) -> [Int] {
        var result: [Int] = []
        for (index,obj) in self.enumerated() {
            if obj as! T == object {
                result.append(index)
            }
        }
        return result
    }
}

extension UIImageView {
    func setCornerForImage() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 5
        self.layer.maskedCorners = [ .layerMinXMaxYCorner, .layerMinXMinYCorner]
        
    }
}
