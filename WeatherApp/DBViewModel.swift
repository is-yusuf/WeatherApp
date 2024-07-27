//
//  DataBaseViewModel.swift
//  WeatherApp
//
//  Created by Yusuf Ismail     on 3/19/24.
//

import Foundation
import SwiftUI
import SwiftData

@Model
class DataBaseCity: Encodable, Identifiable, Hashable , Decodable{
    var id: String
    var user_id: String
    var latitude: Double
    var longitude: Double
    var country: String
    var state: String
    var cityname: String
    
    // Hashable conformance requires a function to hash its properties
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(user_id)
        hasher.combine(latitude)
        hasher.combine(longitude)
        hasher.combine(country)
        hasher.combine(state)
        hasher.combine(cityname)
    }
    
    // Equatable part of Hashable requires this static function
    static func == (lhs: DataBaseCity, rhs: DataBaseCity) -> Bool {
        return lhs.id == rhs.id && lhs.user_id == rhs.user_id && lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude && lhs.country == rhs.country && lhs.state == rhs.state && lhs.cityname == rhs.cityname
    }
    
    init(lat: Double, lon: Double, country: String, state: String, name: String, id: String = UUID().uuidString, user_id: String) {
        self.id = id
        self.user_id = user_id
        self.latitude = lat
        self.longitude = lon
        self.country = country
        self.state = state
        self.cityname = name
    }
    
    // Encodable conformance requires encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(user_id, forKey: .user_id)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(country, forKey: .country)
        try container.encode(state, forKey: .state)
        try container.encode(cityname, forKey: .cityname)
    }
    required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            user_id = try container.decode(String.self, forKey: .user_id)
            country = try container.decode(String.self, forKey: .country)
            state = try container.decode(String.self, forKey: .state)
            cityname = try container.decode(String.self, forKey: .cityname)
            
            // For latitude and longitude, we decode as Double directly
            latitude = try container.decode(Double.self, forKey: .latitude)
            longitude = try container.decode(Double.self, forKey: .longitude)
        }
    
    // CodingKeys for encoding and decoding
    private enum CodingKeys: String, CodingKey {
        case id
        case user_id
        case latitude
        case longitude
        case country
        case state
        case cityname
    }
}

class DBViewModel: ObservableObject {
    
    
    @Published var publishedCities: [DataBaseCity]
    
    
//    @Published var publishedCities: [DataBaseCity] = []
    let uuid = UIDevice.current.identifierForVendor?.uuidString ?? ""
    
    init(){
        
        //        let cities = (1...3).map { i in
//
//            DataBaseCity(lat: Double.random(in: -90..<90), lon: Double.random(in: -180..<180), country: "\(i)", state: "Random State \(i)", name: "Random Location \(i)", user_id: self.uuid)
//        }
//
        
        self.publishedCities = []
        
//        self.getFavourites()
    }
    
    func addFavourite(_ city : DataBaseCity ) -> Bool {
//        @Environment(\.modelContext) var modelContext

        if self.publishedCities.contains(where: { $0.cityname == city.cityname &&  city.user_id == self.uuid && $0.state == city.state }) {
            print("Already in favourites")
            return false
        }
        
//        TODO: Just for testing
        
//        var i = 0
//        var city2 = DataBaseCity(lat: Double.random(in: -90..<90), lon: Double.random(in: -180..<180), country: "\(i)", state: "Random State \(i)", name: "Random Location \(i)", user_id: self.uuid)
//        
//        modelContext.insert(city)
//        modelContext.insert(city2)
        self.publishedCities.append(city)
        
        
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
        let cityToDelete = self.publishedCities.first { $0.cityname == cityname && $0.state == state }
//        modelContext.delete(cityToDelete!)
//        self.publishedCities.removeAll { $0.cityname == cityname && $0.state == state }
        
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
                    print(response ?? "no response")
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
                            print("error1")
                            
//                                modelContext.self = fetchedciti
                            
                            
//                            self.publishedCities = fetchedCities
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


//@Model
//class Trip {
//    var name: String
//
//    init(name: String) {
//        print("init")
//        self.name = name
//    }
//}
