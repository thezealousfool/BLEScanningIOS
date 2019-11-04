//
//  ContentView.swift
//  BLEScanning
//
//  Created by imac on 11/2/19.
//  Copyright © 2019 Vivek Roy. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject var bleScanner = BLEScanner()
    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            Text("\(self.bleScanner.beaconCount)")
            Button(action: {
                self.bleScanner.isRanging ? self.bleScanner.stopRanging() : self.bleScanner.startRanging()
            }) {
                Text(self.bleScanner.isRanging ? "Stop" : "Start")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
