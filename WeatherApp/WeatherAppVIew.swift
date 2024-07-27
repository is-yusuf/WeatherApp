import SwiftUI
import Combine
import MapKit
import SwiftData



struct WeatherView: View {
    @Environment(\.modelContext) var modelContext
    @Query
    var publishedCities: [DataBaseCity]
    
    @ObservedObject private var weatherViewModel = WeatherViewModel()
    @ObservedObject private var dataViewModel = DBViewModel()
    
    
    
    @State private var input: String = ""
    private var debounceTimer: AnyCancellable?
    var dropDownItem: [String]  = ["item 1", "item 2", "item 3"]
    
    @State var value = ""
    @State private var selection: DataBaseCity?
    @StateObject var locationManager = LocationManager()
    
    init(){
        
        dataViewModel.publishedCities = publishedCities
        print("init")
    }
    
    func addFavourite(city:DataBaseCity){
        
    }

    var body: some View {
//        ForEach(trips){trip in
//            Text(trip.name)
//        }
//        
//        Button("Add trip"){
//            let newTrip = Trip(name: "\(trips.count)")
//            modelContext.insert(newTrip)
//        }
        NavigationSplitView (){
            VStack{
                Text("location status: \(locationManager.statusString)")
                
                Section(header: Text("Search City").foregroundStyle(Color.accentColor)) {
                    HStack {
                        TextField("Enter City Name or Zip Code", text: $input)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .disabled(weatherViewModel.isLoading) // Disable text field when loading
                        
                        Button(action: {
                            
                            weatherViewModel.handleInput(input: input)
                            
                        }) {
                            Image(systemName: "magnifyingglass").foregroundColor(.accentColor)
                        }.disabled(weatherViewModel.isLoading || input.isEmpty).padding(10)
                        
                        //                        TODO: make it actually make api call
                        Button(action: {
                            
                            if let coordinate = locationManager.lastLocation {
                                print(coordinate)
                                let i  = 1
                                weatherViewModel.CurrentCity = DataBaseCity(lat: coordinate.coordinate.latitude, lon: coordinate.coordinate.longitude, country: "\(i)", state: locationManager.lastState! , name: locationManager.lastCity!, user_id: dataViewModel.uuid)
                            }
                            
                            else{
                                weatherViewModel.CurrentCity =  dataViewModel.publishedCities[1]
                            }
                            //                            weatherViewModel.handleInput(input: input)
                            
                        }) {
                            Image(systemName:   "location").foregroundColor(.accentColor)
                        }.padding(10)
                        
                    }
                }
                
                Section(header:Text("Favourites").foregroundStyle(Color.accentColor)){
                    
//                    
//                    List{
//                        ForEach(dataViewModel.publishedCities)
//                        { city in
//                            NavigationLink(city.cityname, value: city)
//                        }.environmentObject(dataViewModel).environmentObject(weatherViewModel)
//                    }
                    
                    
                    List($dataViewModel.publishedCities,  editActions: .delete, selection: $weatherViewModel.CurrentCity){ $city in
                        
                        NavigationLink (city.cityname,value:city)
                        
                    }
                    .environmentObject(dataViewModel).environmentObject(weatherViewModel)
                }
            }
            .onChange(of: weatherViewModel.CurrentCity) { newCity in
                guard let city = newCity else { return }
                weatherViewModel.CurrentCity = city
                weatherViewModel.fetchWeather(latitude: city.latitude, longitude: city.longitude)
            }
            
        }
        
        detail: {
            if let city = weatherViewModel.CurrentCity {
                CityData(city: city, dataViewModel: dataViewModel, weatherViewModel: weatherViewModel)
            }
            else{
                Text("Pick a city")
            }
        }
    }
    
}


#Preview {
    WeatherView()
}
