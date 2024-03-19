//
//  ContentView.swift
//  WeatherApp
//
//  Created by Yusuf Ismail on 3/18/24.
//

import SwiftUI
import CoreLocation

let latitude = LocationManager.shared.currentLocation?.latitude ?? 44.887681
let longitude = LocationManager.shared.currentLocation?.longitude ?? -93.451890

struct ContentView: View {
    var body: some View {
        VStack {
            WeatherView()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
