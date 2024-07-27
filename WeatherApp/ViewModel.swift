import Foundation
import CoreLocation
import Combine
import SwiftUI

struct WeatherResponse: Codable {
    let current: CurrentWeather
}

struct ZipResponse: Codable {
    let lat: Double
    let lon: Double
}

struct CityResponse: Codable {
    let cities: [City]
}

struct City: Codable {
    var name: String
    var lat: Double
    var lon: Double
    var country: String
    var state: String
}



struct CurrentWeather: Codable {
    let temp: Double
    let humidity: Int
    let weather: [Weather]
    let wind_speed: Double
}

struct Weather: Codable {
    let main: String
    let icon: String
}

class WeatherViewModel: ObservableObject {
    @Published var currentWeather: CurrentWeather?
    @Published var CurrentCity : DataBaseCity?
    
    @Published var message: String = ""
    @Published var isLoading: Bool = false // Add this line
    @Published var cityNames: [String] = []
    let uuid = UIDevice.current.identifierForVendor?.uuidString ?? ""
    
    private var debounceTimer: AnyCancellable?
    private var searchText = ""

    
    func loadAPIKey() -> String? {
        guard
            let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String else {
            return nil
        }
        
        return apiKey
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        guard let apiKey = loadAPIKey() else {
            isLoading = false
            self.message = "API Key not found."
            return
        }
        
        let urlString = "https://api.openweathermap.org/data/3.0/onecall?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=imperial"
        
        guard let url = URL(string: urlString) else {
            self.message = "Invalid URL."
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    self.isLoading = false // Stop loading once the request is completed or failed
                    self.message = "Network request failed."
                    return
                }
                
                let decoder = JSONDecoder()
                do {
                    let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
                        
                        self.currentWeather = weatherResponse.current
                        
                        self.isLoading = false // Stop loading once the request is completed or
                        
                        self.message = ""
                        
                    }
                catch {
                    self.isLoading = false
                    
                    self.message = error.localizedDescription
                }
            }
        }.resume()
        
    }
    
    func fetchByZip(zipCode: String) {
        if zipCode.isEmpty{
            return
        }
        isLoading = true // Start loading
        message = "Loading..." // Optional: Update message to indicate loading
        
        guard let apiKey = loadAPIKey() else {
            
            self.message = "API Key not found."
            return
        }
        
        
        // Assuming USA zip codes for simplicity; specify country code as needed
        
        let urlString = "https://api.openweathermap.org/geo/1.0/zip?zip=\(zipCode)&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            self.message = "Invalid URL."
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    self.isLoading = false // Stop loading once the request is completed or failed
                    self.message = "Network request failed."
                    return
                }
                
                let decoder = JSONDecoder()
                if let ZipResponse = try? decoder.decode(ZipResponse.self, from: data) {
                    
                    self.CurrentCity = DataBaseCity( lat: ZipResponse.lat, lon: ZipResponse.lon, country: "US", state: "ZIP", name: zipCode, user_id: self.uuid)
                                            
                    self.fetchWeather(latitude: ZipResponse.lat, longitude: ZipResponse.lon)
                    
                    
                } else {
                    self.isLoading = false // Stop loading once the request is completed or failed
                    self.message = "ZipCode invalid."
                }
            }
        }.resume()
    }
    
    func fetchByCity(city: String) {
            isLoading = true // Start loading
            message = "Loading..." // Optional: Update message to indicate loading
            
        if city.isEmpty{
            return
        }
            guard let apiKey = loadAPIKey() else {
                self.message = "API Key not found."
                return
            }
            
            
            
            let urlString = "https://api.openweathermap.org/geo/1.0/direct?q=\(city)&limit=5&appid=\(apiKey)"
            
            guard let url = URL(string: urlString) else {
                self.message = "Invalid URL."
                self.isLoading = false // Stop loading once the request is completed or failed
                
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                DispatchQueue.main.async {
                    guard let data = data, error == nil else {
                        
                        self.message = "Network request failed."
                        self.isLoading = false // Stop loading once the request is completed or failed
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    if let cities = try? decoder.decode([City].self, from: data) {
                        
                        do{
                            self.CurrentCity = DataBaseCity(lat: cities[0].lat, lon: cities[0].lon, country: cities[0].country, state: cities[0].state, name: cities[0].name, user_id: self.uuid)
                            print (self.CurrentCity?.latitude)
                            
                            self.fetchWeather(latitude: self.CurrentCity!.latitude, longitude: self.CurrentCity!.longitude)
                        }
                        catch{
                            self.message = "City not found"
                        }
                    } else {
                        self.message = "Couldn't find city."
                        self.isLoading = false // Stop loading once the request is completed or failed
                    }
                }
            }.resume()
        }
    
    func handleInput(input: String) -> Void{
        if input.range(of: "^[0-9]+$", options: .regularExpression) != nil {
            fetchByZip(zipCode: input)
        } else {
            fetchByCity(city: input)
        }
    
        }
    }
