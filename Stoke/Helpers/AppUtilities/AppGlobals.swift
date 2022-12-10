//
//  Globals.swift
//  Onboarding
//
//  Created by Appinventiv on 22/08/16.
//  Copyright © 2016 Gurdeep Singh. All rights reserved.
//

import Foundation
import UIKit

/// Print Debug
func printDebug<T>(_ obj : T) {
    #if DEBUG
        print(obj)
    #endif
}

/// Is Simulator or Device
var isSimulatorDevice: Bool {

    var isSimulator = false
    #if arch(i386) || arch(x86_64)
        //simulator
        isSimulator = true
    #endif
    return isSimulator
}

/// Is this iPhone X or not
func isDeviceIsIphoneX() -> Bool {
    if UIDevice().userInterfaceIdiom == .phone {
        switch UIScreen.main.nativeBounds.height {
        case 1136: return false
        case 1334: return false
        case 2208: return false
        case 2436: return true
        default: return false
        }
    }
    return false
}


