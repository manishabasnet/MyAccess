import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct PlaceDetailDisplay: View {
    @State var placeID: String
    @State private var place: Place?  // Store the fetched place data
    @State private var newComment: String
    @State private var newFeature: String
    @State private var isLoading = true
    private var placeService = PlaceService()
    init(placeID: String) {
        self._placeID = State(initialValue: placeID)
        self._newComment = State(initialValue: "")
        self._newFeature = State(initialValue: "")
    }

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
    
    func addComment() {
            guard let place = place, !newComment.isEmpty else { return }
        placeService.addComment(to: place, comment: newComment) { result in
                switch result {
                case .success:
                    self.newComment = "" // Clear the comment field after submission
                    self.fetchPlaceData() // Reload data to reflect the new comment
                case .failure(let error):
                    print("Error adding comment: \(error.localizedDescription)")
                }
            }
        }
    
    func addFeature() {
            guard let place = place, !newFeature.isEmpty else { return }
            placeService.addFeature(to: place, feature: newFeature) { result in
                switch result {
                case .success:
                    self.newFeature = "" // Clear the feature field after submission
                    self.fetchPlaceData() // Reload data to reflect the new comment
                case .failure(let error):
                    print("Error adding feature: \(error.localizedDescription)")
                }
            }
        }


    var body: some View {
        GeometryReader { geometry in
            VStack { // Outer VStack for centering
                if isLoading {
                    ProgressView("Loading data...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let place = place {
                    VStack(spacing: geometry.size.height * 0.015) {
                        // Individual location display
                        VStack(alignment: .leading) {
                            // Building name
                            Text(place.placeName)
                                .font(.title)
                                .fontWeight(.semibold)
                                .padding(.bottom, geometry.size.height * 0.015)
                            
                            // Display multiple images
                            if !place.images.isEmpty {
                                TabView {
                                    ForEach(place.images, id: \.self) { imageUrl in
                                        AsyncImage(url: URL(string: imageUrl)) { image in
                                            image.resizable()
                                                .scaledToFill()
                                                .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.3, alignment: .top)
                                                .cornerRadius(20)
                                                .padding(.top, geometry.size.height * 0.025)
                                                .padding(.bottom, geometry.size.height * 0.015)
                                        } placeholder: {
                                            Image(systemName: "photo")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.3)
                                                .cornerRadius(20)
                                                .padding(.top, geometry.size.height * 0.025)
                                                .padding(.bottom, geometry.size.height * 0.015)
                                        }
                                    }
                                }
                                .frame(height: geometry.size.height * 0.3)
                                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                            }
                            
                            // Building description
                            Text(place.description)
                                .font(.title3)
                                .multilineTextAlignment(.center)
                                .padding(.bottom, geometry.size.height * 0.015)

                            // Features section
                            VStack(alignment: .leading, spacing: 5) {
                                TextField("Add a feature...", text: $newFeature)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                                    .onSubmit {
                                        addFeature()
                                    }
                                
                                // Iterate over the features
                                ForEach(place.features.keys.sorted(), id: \.self) { user in
                                    ForEach(place.features[user] ?? [], id: \.self) { feature in
                                        Text("• \(feature)")
                                            .font(.body)
                                            .padding(.vertical, 2)
                                    }
                                }
                            }
                            .padding(.bottom, geometry.size.height * 0.015)
                            
                            // Comments section
                            VStack(alignment: .leading) {
                                TextField("Add a comment ...", text: $newComment)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                                    .onSubmit {
                                        addComment() // Add comment on submit
                                    }

                                
                                // Iterate over comments
                                ForEach(place.comments.keys.sorted(), id: \.self) { user in
                                    ForEach(place.comments[user] ?? [], id: \.self) { comment in
                                        HStack {
                                            Image(systemName: "person.circle.fill")
                                                .font(.title3)
                                            Text(comment)
                                                .font(.body)
                                                .lineLimit(1)
                                                .padding(.leading, 5)
                                        }
                                        .padding(.vertical, 5)
                                        .background(Color(UIColor.systemGray6))
                                        .cornerRadius(8)
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        
                        }
                        .background(
                            Color.white
                                .cornerRadius(15)
                        )
                        .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.85)
                        
                        // Icons for specific actions (thumbs-up, thumbs-down)
                        HStack {
                            Image(systemName: "hand.thumbsup.fill")
                                .font(.largeTitle)
                                .padding()
                            Image(systemName: "hand.thumbsdown.fill")
                                .font(.largeTitle)
                                .padding()
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .onAppear {
                fetchPlaceData()
            }
        }
    }
}
