import SwiftUI
import Combine

struct WeatherView: View {
    @StateObject private var weatherViewModel = WeatherViewModel()
    @StateObject private var dataViewModel = DBViewModel()
    @State private var input: String = ""
    private var debounceTimer: AnyCancellable?
    var dropDownItem: [String]  = ["item 1", "item 2", "item 3"]
    
    @State var value = ""
    
    
    var body: some View {
        VStack {
            ScrollView {
                        VStack(spacing: 12) {
                            ForEach(dataViewModel.publishedCities) { city in
                                CityCardView(city: city)
                            }
                        }
                        .padding()
                    }.environmentObject(dataViewModel)
            
            TextField("Enter City Name or Zip Code", text: $input)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .disabled(weatherViewModel.isLoading) // Disable text field when loading
            
            Button("Submit") {
                weatherViewModel.handleInput(input: input)
            }
            .disabled(weatherViewModel.isLoading || input.isEmpty) // Disable button when loading
            .padding()
            
            if weatherViewModel.isLoading {
                Text("Loading...")
            } else if let weather = weatherViewModel.currentWeather {
                VStack
                {
                    AsyncImageLoader(urlString: "https://openweathermap.org/img/wn/\(weather.weather.first?.icon ?? "").png")
                        .frame(width: 60, height: 60) // Adjust size as needed
                    
                    Text("Temperature: \(weather.temp, specifier: "%.0f"),°F")
                    Text("Humidity: \(weather.humidity)%")
                    Text("Condition: \(weather.weather.first?.main ?? "N/A")")
                    Text("Wind Speed: \(weather.wind_speed) mph")
                    Button("Add To Favourites") {
                        if let to_add = weatherViewModel.CurrentCity
                        {
                            if dataViewModel.addFavourite(to_add)
                                    {
                                Text( "Already in favourites")
                                    }

                        }
                    }
                    .disabled(weatherViewModel.isLoading) // Disable button when loading
                    .padding()
                }
            } else {
                Text(weatherViewModel.message)
            }
        }
        .padding()
    }
}
