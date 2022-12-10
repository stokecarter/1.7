//
//  AppNetworkDetector.swift
//  Stoke
//
//  Created by Admin on 24/06/21.
//

import Foundation

class AppNetworkDetector {
    
    static let sharedInstance = AppNetworkDetector()
    private var reachability : Reachability!
    
    
    var isIntenetOk:Bool = true
    
    func observeReachability(){
        self.reachability = try! Reachability()
        isIntenetOk = CommonFunctions.checkForInternet()
        NotificationCenter.default.addObserver(self, selector:#selector(self.reachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: nil)
        do {
            try self.reachability.startNotifier()
        }
        catch(let error) {
            printDebug("Error occured while starting reachability notifications : \(error.localizedDescription)")
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .unavailable:
            isIntenetOk = false
            let flag:[String: Bool] = ["status": false]
            NotificationCenter.default.post(name: .internetUpdate, object: flag)
            break
        default:
            isIntenetOk = true
            let flag:[String: Bool] = ["status": true]
            NotificationCenter.default.post(name: .internetUpdate, object: flag)
            break
        }
    }
}


extension NSNotification.Name{
    static let internetUpdate = NSNotification.Name(rawValue: "internetUpdate")
    static let internetDown = NSNotification.Name(rawValue: "internetDown")
    static let internetUp = NSNotification.Name(rawValue: "internetUp")
}
