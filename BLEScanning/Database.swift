//
//  Database.swift
//  BLEScanning
//
//  Created by imac on 11/2/19.
//  Copyright © 2019 Vivek Roy. All rights reserved.
//

import Foundation
import SQLite

class Database {

    public static let shared = Database()
    private var database : Connection?
    private let beacons = Table("beacons")
    private let id = Expression<Int64>("id")
    private let uid = Expression<String>("uid")
    private let major = Expression<String>("major")
    private let minor = Expression<String>("minor")
    private let timestamp = Expression<Int64>("timestamp")
    private let rssi = Expression<Int64>("rssi")
    
    init() {
        do {
            let file = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("com.vivekroy.navcoglogging", isDirectory: false)
            database = try Connection(file.path)
            try database?.run(
                beacons.create(ifNotExists: true) { t in
                    t.column(id, primaryKey: .autoincrement )
                    t.column(uid)
                    t.column(major)
                    t.column(minor)
                    t.column(timestamp)
                    t.column(rssi)
                }
            )
            database?.busyTimeout = 10
        } catch {
            print("Database init failed")
            print(error)
            database = nil
        }
    }
    
    func insert(_uid: String, _major: String, _minor: String, _rssi: Int, _timestamp: Int64) {
        do {
            try database?.run(beacons.insert(
                uid <- _uid,
                major <- _major,
                minor <- _minor,
                rssi <- Int64(_rssi),
                timestamp <- _timestamp
            ))
        } catch {
            print("Insert error")
            print(error)
        }
    }
    
    func clearBeaconsTable() {
        do {
            try database?.run(beacons.delete())
        } catch {
            print("Clear Table error")
            print(error)
        }
    }
    
    func commitDatabase() {
        do {
            let src = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("com.vivekroy.navcoglogging", isDirectory: false)
            let dst = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(
                "com.vivekroy.navcoglogging \(SyncedTime.time.client.referenceTime?.now().timeIntervalSince1970 ?? 0)", isDirectory: false)
            try FileManager.default.copyItem(at: src, to: dst)
            clearBeaconsTable()
        } catch {
            print("Database commit error")
            print(error)
        }
    }
}
