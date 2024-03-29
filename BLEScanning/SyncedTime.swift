//
//  SyncedTime.swift
//  BLEScanning
//
//  Created by imac on 11/2/19.
//  Copyright © 2019 Vivek Roy. All rights reserved.
//

import Foundation
import TrueTime

class SyncedTime : ObservableObject {
    
    public static let time = SyncedTime()
    let client = TrueTimeClient.sharedInstance
    @Published public var ntpTime : Int64 = 0
}
