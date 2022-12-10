//
//  DeviceDetail.swift
//  Onboarding
//
//  Created by Appinventiv on 22/08/16.
//  Copyright © 2016 Gurdeep Singh. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

struct DeviceDetail {
    
    /// Enum - NetworkTypes
    enum NetworkType: String {
        case _2G = "2G"
        case _3G = "3G"
        case _4G = "4G"
        case lte = "LTE"
        case wifi = "Wifi"
        case none = ""
    }
    
    /// Device Model
    static var deviceModel : String {
        return UIDevice.current.model
    }
    
    /// OS Version
    static var osVersion : String {
        return UIDevice.current.systemVersion
    }
    
    /// Platform
    static var platform : String {
        return UIDevice.current.systemName
    }
    
    /// Device Id
    static var deviceId : String {
        
        return UIDevice.current.identifierForVendor!.uuidString
    }
    
    /// IP Address
    static var ipAddress : String? {
        
        return getWiFiAddress()
    }
    
    /// Network Type
    static var networkType : NetworkType {
        
        return getNetworkType
    }
    
    static var bottomSafearaHeight:CGFloat{
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows[0]
            let bottomPadding = window.safeAreaInsets.bottom
            return bottomPadding
        }else{
            let window = UIApplication.shared.keyWindow
            return window?.safeAreaInsets.bottom ?? 0.0
        }
    }
       
    static var isNotch:Bool{
        return bottomSafearaHeight > 0 
    }
    static var deviceToken = ""
    
    static var fcmToken = "DummyFcmToken"

    /// Get Network Type
    private static var getNetworkType: NetworkType {
        
        if let statusBar = UIApplication.shared.value(forKey: "statusBar"),let foregroundView = (statusBar as AnyObject).value(forKey: "foregroundView") {
            
            let subviews = (foregroundView as AnyObject).subviews
            for subView in subviews! {
                
                if subView.isKind(of: NSClassFromString("UIStatusBarDataNetworkItemView")!) {
                    
                    if let value = subView.value(forKey: "dataNetworkType") {
                        
                        switch JSON(value).intValue {
                        case 0: return NetworkType.none
                        case 1: return NetworkType._2G
                        case 2: return NetworkType._3G
                        case 3: return NetworkType._4G
                        case 4: return NetworkType.lte
                        case 5: return NetworkType.wifi
                        default: return NetworkType.none
                        }
                    }
                }
            }
        }
        return NetworkType.none
    }
    
    /// Get Wifi Address
    fileprivate static func getWiFiAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            
            // For each interface ...
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                let interface = ptr?.pointee
                
                // Check for IPv4 or IPv6 interface:
                let addrFamily = interface?.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    
                    // Check interface name:
                    if let name = String(validatingUTF8: (interface?.ifa_name)!), name == "en0" {
                        
                        // Convert interface address to a human readable string:
                        var addr = interface?.ifa_addr.pointee
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(&addr!, socklen_t((interface?.ifa_addr.pointee.sa_len)!),
                            &hostname, socklen_t(hostname.count),
                            nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }

        return address
    }

}
