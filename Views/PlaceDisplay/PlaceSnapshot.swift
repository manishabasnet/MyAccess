import SwiftUI
import FirebaseAuth

struct PlaceSnapshot: View {
    let searchBarColor = Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
    @State var placeID: String
    @State var place: Place? // Store the fetched place data
    @State var isLoading = true
    
    init(placeID: String) {
        self._placeID = State(initialValue: placeID)
    }
    
    private var placeService = PlaceService()
    
    // Function to fetch place data
    func fetchPlaceData() {
        placeService.fetch_place(placeID: placeID) { result in
            switch result {
            case .success(let fetchedPlace):
                self.place = fetchedPlace
                self.isLoading = false
            case .failure(let error):
                print("Error fetching place: \(error.localizedDescription)")
                self.isLoading = false
            }
        }
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                // Show loading view until data is fetched
                if isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let place = place {
                    // Once the data is fetched, display the place information
                    
                    // Make the whole place block clickable using NavigationLink
                    NavigationLink(destination: PlaceDetailDisplay(placeID: placeID)) {
                        VStack {
                            // Display image if available (use a placeholder image if none)
                            if let firstImage = place.images.first, !firstImage.isEmpty {
                                AsyncImage(url: URL(string: firstImage)) { image in
                                    image.resizable()
                                        .scaledToFill()
                                        .frame(width: geometry.size.width * 0.65, height: geometry.size.height * 0.35, alignment: .top)
                                        .cornerRadius(20)
                                        .padding(.top, geometry.size.height * 0.025)
                                        .padding(.bottom, geometry.size.height * 0.015)
                                } placeholder: {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: geometry.size.width * 0.65, height: geometry.size.height * 0.35)
                                        .cornerRadius(20)
                                        .padding(.top, geometry.size.height * 0.025)
                                        .padding(.bottom, geometry.size.height * 0.015)
                                }
                            }
                            
                            // Building name
                            Text(place.placeName)
                                .foregroundStyle(.black)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.bottom, geometry.size.height * 0.015)
                            
                            // Building description
                            Text(place.description)
                                .foregroundStyle(.gray)
                                .font(.title3)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.7)
                    }
                    .frame(maxWidth: .infinity) // Make sure it's full-width in the parent container
                    
                    // HStack for thumbs up, thumbs down, and other icons (this stays below the main content)
                    HStack {
                        // Use LikeDislikeButton instead of static icons
                        LikeDislikeButton(
                            count: place.likes.count,
                            iconName: "hand.thumbsup.fill",
                            isSelected: place.likes.contains(Auth.auth().currentUser?.uid ?? ""),
                            action: {
                                // Implement like action
                                placeService.addLikeDislike(to: place, type: .like) { result in
                                    switch result {
                                    case .success:
                                        fetchPlaceData() // Reload place data to reflect like/dislike changes
                                    case .failure(let error):
                                        print("Error adding like: \(error.localizedDescription)")
                                    }
                                }
                            }
                        )
                        
                        LikeDislikeButton(
                            count: place.dislikes.count,
                            iconName: "hand.thumbsdown.fill",
                            isSelected: place.dislikes.contains(Auth.auth().currentUser?.uid ?? ""),
                            action: {
                                // Implement dislike action
                                placeService.addLikeDislike(to: place, type: .dislike) { result in
                                    switch result {
                                    case .success:
                                        fetchPlaceData() // Reload place data to reflect like/dislike changes
                                    case .failure(let error):
                                        print("Error adding dislike: \(error.localizedDescription)")
                                    }
                                }
                            }
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .center)  // Center the icons horizontally
                    .padding(.top, geometry.size.height * 0.015)  // Add some space between the main content and icons
                }
            }
            .background(
                Color.white
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x:0.0, y: 10)
            )
            .onAppear {
                fetchPlaceData()
            }
        }
    }
}
