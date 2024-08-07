//
//  WeatherAppApp.swift
//  WeatherApp
//
//  Created by Yusuf Ismail on 3/18/24.
//

import SwiftUI
import SwiftData

@main
struct WeatherAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: DataBaseCity.self)
    }
}
