//
//  BLEScanner.swift
//  BLEScanning
//
//  Created by imac on 11/2/19.
//  Copyright © 2019 Vivek Roy. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftUI
import Combine

class BLEScanner : NSObject, CLLocationManagerDelegate, ObservableObject {

    private var locationManager : CLLocationManager? = CLLocationManager()
    private let proximityUUID = UUID(uuidString: "F7826DA6-4FA2-4E98-8024-BC5B71E0893E")!
    @Published public var isRanging = false
    @Published public var beaconCount = 0

    override init() {
        super.init()
        locationManager?.requestWhenInUseAuthorization()
        if !CLLocationManager.isRangingAvailable() {
            locationManager = nil
        }
        locationManager?.delegate = self
    }

    func startRanging() {
        isRanging = true
        locationManager?.startRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: proximityUUID))
    }

    func stopRanging() {
        locationManager?.stopRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: proximityUUID))
        isRanging = false
        Database.shared.commitDatabase()
    }

    func locationManager(_ manager: CLLocationManager,
                         didRangeBeacons beacons: [CLBeacon],
                         in region: CLBeaconRegion) {
        beaconCount = beacons.count
        let timestamp = Int64(SyncedTime.time.client.referenceTime?.now().timeIntervalSince1970 ?? 0)
        SyncedTime.time.ntpTime = timestamp
        if beacons.count > 0 {
            DispatchQueue.global(qos: .background).async {
                beacons.forEach { beacon in
                    Database.shared.insert(_uid: self.proximityUUID.uuidString, _major: beacon.major.stringValue, _minor: beacon.minor.stringValue, _rssi: beacon.rssi, _timestamp: timestamp)
                }
            }
        }
    }
}
