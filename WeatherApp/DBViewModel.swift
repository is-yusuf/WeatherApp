//
//  DataBaseViewModel.swift
//  WeatherApp
//
//  Created by Yusuf Ismail     on 3/19/24.
//

import Foundation
import SwiftUI


struct DataBaseCity: Codable, Identifiable {
    var id: String
    var user_id : String
    var latitude: Double
    var longitude: Double
    var country: String
    var state: String
    var cityname: String

    init(lat: Double, lon: Double, country: String, state: String, name: String, id: String = UUID().uuidString, user_id:String) {
        self.id = id
        self.user_id = user_id
        self.latitude = lat
        self.longitude = lon
        self.country = country
        self.state = state
        self.cityname = name
    }
    init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: CodingKeys.self)
           id = try container.decode(String.self, forKey: .id)
           cityname = try container.decode(String.self, forKey: .cityname)
           country = try container.decode(String.self, forKey: .country)
           state = try container.decode(String.self, forKey: .state)
           user_id = try container.decode(String.self, forKey: .user_id)
           
           // For latitude and longitude, we decode as String then convert to Double
           let latString = try container.decode(String.self, forKey: .latitude)
           let lonString = try container.decode(String.self, forKey: .longitude)
           latitude = Double(latString) ?? 0.0
           longitude = Double(lonString) ?? 0.0
       }
}

class DBViewModel: ObservableObject {
    
    @Published var publishedCities: [DataBaseCity] = []
    let uuid = UIDevice.current.identifierForVendor?.uuidString ?? ""
    
    init(){
        self.getFavourites()
    }
    func addFavourite(_ city : DataBaseCity ) -> Bool {
        
        if self.publishedCities.contains(where: { $0.cityname == city.cityname &&  city.user_id == self.uuid && $0.state == city.state }) {
            return false
        }
        
        
        
        let urlString = "http://44.205.244.237:9000/favourites"
        guard let url = URL(string: urlString) else { return false }
        
        // Prepare your parameters
        let parameters = [
            "user_id": self.uuid,
            "cityname": city.cityname,
            "state": city.state,
            "country": city.country,
            "longitude": city.longitude,
            "latitude": city.latitude
        ] as [String : Any]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return  false}
        Task {
            do {
                var request = URLRequest(url: url)
                        request.httpMethod = "POST"
                        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                        request.httpBody = jsonData
                        
                let (data, response) = try await URLSession.shared.data(for: request)
                self.getFavourites()
                if let responseString = String(data: data, encoding: .utf8) {
                    
                    print("Response data string: \(responseString)")
                }
            } catch {
                print("Error performing POST request: \(error)")
            }
        }
        return true
    }
    func deleteFavourite( cityname : String,  state : String){
        self.publishedCities.removeAll { $0.cityname == cityname && $0.state == state }
        guard let url = URL(string: "http://44.205.244.237:9000/deletecity?user_id=\(uuid)&cityname=\(cityname)&state=\(state)") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            
            // Assuming the server expects a JSON body with cityname and state
//            let body: [String: Any] = ["user_id": self.uuid,"cityname": cityname, "state": state]
//            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Perform the request
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print(response)
                    print("Error sending delete request: \(error)")
                    return
                }
                
                // Handle the response here. For example, check for success status code.
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("Successfully deleted city.")
                } else {
                    print("Failed to delete city.")
                }
            }
            task.resume()
    }
    
    func getFavourites() {
        print("getting favourites")
            let uuid = UIDevice.current.identifierForVendor?.uuidString ?? ""
            let urlString = "http://44.205.244.237:9000/favourites?user_id=\(uuid)"
            
            guard let url = URL(string: urlString) else { return }
            
            Task {
                do {
                    var request = URLRequest(url: url)
                    request.httpMethod = "GET"
                    
                    let (data, _) = try await URLSession.shared.data(for: request)
                    
                    // Assuming the server returns an array of DataBaseCity objects
                    do {
                        let fetchedCities = try JSONDecoder().decode([DataBaseCity].self, from: data)
                        DispatchQueue.main.async {
                            self.publishedCities = fetchedCities
                        }
                    } catch {
                        DispatchQueue.main.async {
                            print(data)
                            print("Decoding error: \(error.localizedDescription)")
                        }
                    }
                    
                } catch {
                    print("Error performing GET request: \(error)")
                }
            }
        }
    
}
