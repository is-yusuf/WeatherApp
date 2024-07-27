//
//  CityData.swift
//  WeatherApp
//
//  Created by Yusuf Ismail on 7/25/24.
//

import SwiftUI
import CoreLocation

struct CityData: View  {
//    @Environment(\.modelContext) var modelContext
    
    let city: DataBaseCity
    @ObservedObject var dataViewModel: DBViewModel
    @ObservedObject var weatherViewModel: WeatherViewModel
    
    var body: some View {
           VStack {
               MapView(coordinate: CLLocationCoordinate2D(latitude: city.latitude, longitude: self.city.longitude))
                   .frame(height: 300)
               
               

               VStack(alignment: .leading) {
                   HStack{
                       Text(city.cityname)
                           .font(.title)
                    
                       Spacer()
                       Button(action: {
                           if let to_add = weatherViewModel.CurrentCity
                           {
//                               modelContext.insert(to_add)
                               if (!dataViewModel.addFavourite(to_add))
                               {
                                   dataViewModel.publishedCities.removeAll(where: { $0.cityname == to_add.cityname })
                               }
                               
                           }
                           
                       }){
//                           change size to large
                           if (dataViewModel.publishedCities.contains(city)){
                               Image(systemName: "star.fill").foregroundColor( Color.yellow).imageScale(.large)
                           }
                           else{
                               Image(systemName: "star").foregroundColor( Color.yellow).imageScale(.large)
                           }
                           
                       }
                   }
                   
                   HStack {
                       Text(city.state)
                       Spacer()
                    
                   }
                   .font(.subheadline)
                   .foregroundStyle(.secondary)


                   Divider()
                   
                   
                    if let weather = weatherViewModel.currentWeather {
                       HStack{
                           Spacer()
                           VStack
                           {
                               AsyncImageLoader(urlString: "https://openweathermap.org/img/wn/\(weatherViewModel.currentWeather?.weather.first?.icon ?? "").png")
                                   .frame(width: 60, height: 60) // Adjust size as needed
                               
                               Text("Temperature: \(weather.temp, specifier: "%.0f"),°F")
                               Text("Humidity: \(weather.humidity)%")
                               Text("Condition: \(weather.weather.first?.main ?? "N/A")")
                               Text("Wind Speed: \(weather.wind_speed) mph")
                               
                               
                               .disabled(weatherViewModel.isLoading) // Disable button when loading
                               .padding()
                           }
                           Spacer()
                       }
                       
                       
                       
                   } else if weatherViewModel.message != "" {
                       Text(weatherViewModel.message)
                   }
                   else{
                       Text(weatherViewModel.message)
                   }
                   
               }
               .padding()


               Spacer()
           }
       }
   }


   #Preview {
       Image(systemName: "star.fill").foregroundColor( Color.yellow).imageScale(.large)
   }

