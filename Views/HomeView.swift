import SwiftUI

struct HomeView: View {
    @State private var places: [Place] = []  // Array to hold places ids
    @State private var isLoading = true
    @State private var searchText = ""  // Added for search functionality
    
    private var placeService = PlaceService()
    
    let searchBarColor = Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
    
    func fetchPlaces() {
        placeService.fetchPlaces { result in
            switch result {
            case .success(let fetchedPlaces):
                self.places = fetchedPlaces
                self.isLoading = false
            case .failure(let error):
                print("Error fetching places: \(error.localizedDescription)")
                self.isLoading = false
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Sticky Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search places...", text: $searchText)
                }
                .padding()
                .background(searchBarColor)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top)
                
                // Places List
                ScrollView {
                    // Title
                    Text("Places near you")
                        .font(.title)
                        .fontWeight(.bold)
                    VStack(spacing: 70) {
                        if isLoading {
                            ProgressView("Loading places...")
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ForEach(places, id: \.id) { place in
                                PlaceSnapshot(placeID: place.id ?? "")
                                    .frame(height: 200)
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                fetchPlaces()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
