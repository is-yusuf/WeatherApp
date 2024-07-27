import SwiftUI

struct CityCardView: View {
     var dataViewModel: DBViewModel
    
    var city: DataBaseCity
    
    var body: some View {
        
        
        
            
            HStack(spacing: 8) {
                Text("\(city.cityname), \(city.state)")
                    .foregroundColor(.primary)
                
                Spacer()
//                Button(action: {
//                    dataViewModel.deleteFavourite(cityname: city.cityname, state: city.state)
//                }){
//                    
//                    Image(systemName: "xmark.circle.fill")
//                    
//                        .foregroundColor(.red)
//                        .imageScale(.large)
//                    
//                }.buttonStyle(PlainButtonStyle())
            }
            
            .padding()
            
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding(.horizontal, 8) // Add some horizontal padding to the whole card
        }
    }


#Preview {
    WeatherView()
}
