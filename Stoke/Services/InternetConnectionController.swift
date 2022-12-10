//
//  InternetConnectionController.swift
//  Stoke
//
//  Created by Admin on 28/02/21.
//

import Foundation
import Alamofire

private let manager = NetworkReachabilityManager(host: "www.apple.com")

func isNetworkReachable() -> Bool {
    return manager?.isReachable ?? false
}
