import SwiftUI

struct CityCardView: View {
    @EnvironmentObject var dataViewModel: DBViewModel
    
    var city: DataBaseCity
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(city.cityname) // Assuming your DataBaseCity uses 'name' instead of 'cityname'
                    .font(.headline)
                    .foregroundColor(.primary) // Use the primary color for better readability
                Text(city.state)
                    .font(.subheadline)
                    .foregroundColor(.secondary) // Use the secondary color for
                Text( String(city.longitude) )
                    .font(.subheadline)
                    .foregroundColor(.secondary) // Use the secondary color for subtlety
                Text(String(city.latitude))
                    .font(.subheadline)
                    .foregroundColor(.secondary) // Use the secondary color for subtlety
                
            }
            
            
            
            Spacer() // Pushes the content and the button to opposite sides
            Button(action: {
                dataViewModel.deleteFavourite(cityname: city.cityname, state: city.state)
                
            }) {
                Image(systemName: "xmark.circle.fill") // Using SF Symbols for the "X" icon
                    .foregroundColor(.red) // Red color to signify deletion
                    .imageScale(.large) // Increase the size of the icon
            }
            .padding(.leading, 8) // Add some padding to avoid the text and button being too close
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal, 8) // Add some horizontal padding to the whole card
    }
}
