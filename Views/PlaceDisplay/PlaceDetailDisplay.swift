import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

struct Buttons: View {
    @State var placeID: String
    @State private var place: Place?
    @State private var hasLiked = false
    @State private var hasDisliked = false
    
    private var placeService = PlaceService()
    
    init(placeID: String) {
        self._placeID = State(initialValue: placeID)
    }
    
    private func fetchPlaceData() {
        placeService.fetch_place(placeID: placeID) { result in
            switch result {
            case .success(let fetchedPlace):
                self.place = fetchedPlace
                if let currentUser = Auth.auth().currentUser {
                    self.hasLiked = fetchedPlace.likes.contains(currentUser.uid)
                    self.hasDisliked = fetchedPlace.dislikes.contains(currentUser.uid)
                }
            case .failure(let error):
                print("Error fetching place: \(error.localizedDescription)")
            }
        }
    }
    
    private func performLikeDislike(type: PlaceService.LikeDislikeType) {
        guard let place = place else { return }
        
        placeService.addLikeDislike(to: place, type: type) { result in
            switch result {
            case .success:
                fetchPlaceData()
                
                if type == .like {
                    hasLiked = true
                    hasDisliked = false
                } else {
                    hasDisliked = true
                    hasLiked = false
                }
            case .failure(let error):
                print("Error adding \(type == .like ? "like" : "dislike"): \(error.localizedDescription)")
            }
        }
    }
    
    var body: some View {
        HStack {
            LikeDislikeButton(
                count: place?.likes.count ?? 0,
                iconName: "hand.thumbsup.fill",
                isSelected: hasLiked
            ) {
                performLikeDislike(type: .like)
            }
            
            LikeDislikeButton(
                count: place?.dislikes.count ?? 0,
                iconName: "hand.thumbsdown.fill",
                isSelected: hasDisliked
            ) {
                performLikeDislike(type: .dislike)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .onAppear(perform: fetchPlaceData)
    }
}

struct LikeDislikeButton: View {
    let count: Int
    let iconName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        VStack {
            Text("\(count)")
            Button(action: action) {
                Image(systemName: iconName)
                    .foregroundStyle(isSelected ? .blue : .black)
                    .font(.largeTitle)
                    .padding()
            }
        }
    }
}

struct PlaceDetailDisplay: View {
    @State var placeID: String
    @State private var place: Place?
    @State private var newComment: String = ""
    @State private var newFeature: String = ""
    @State private var isLoading = true
    
    private var placeService = PlaceService()
    
    init(placeID: String) {
        self._placeID = State(initialValue: placeID)
    }
    
    private func fetchPlaceData() {
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
    
    private func addComment() {
        guard let place = place, !newComment.isEmpty else { return }
        placeService.addComment(to: place, comment: newComment) { result in
            switch result {
            case .success:
                self.newComment = ""
                self.fetchPlaceData()
            case .failure(let error):
                print("Error adding comment: \(error.localizedDescription)")
            }
        }
    }
    
    private func addFeature() {
        guard let place = place, !newFeature.isEmpty else { return }
        placeService.addFeature(to: place, feature: newFeature) { result in
            switch result {
            case .success:
                self.newFeature = ""
                self.fetchPlaceData()
            case .failure(let error):
                print("Error adding feature: \(error.localizedDescription)")
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if isLoading {
                    ProgressView("Loading data...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let place = place {
                    ScrollView {
                        VStack(spacing: geometry.size.height * 0.015) {
                            placeDetailView(place: place, geometry: geometry)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .onAppear(perform: fetchPlaceData)
        }
    }
    
    private func placeDetailView(place: Place, geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading) {
            Text(place.placeName)
                .font(.title)
                .fontWeight(.semibold)
                .padding(.bottom, geometry.size.height * 0.015)
            
            imageSection(place: place, geometry: geometry)
            
            Text(place.description)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.bottom, geometry.size.height * 0.015)
            
            featuresSection(place: place, geometry: geometry)
            
            commentsSection(place: place, geometry: geometry)
            
            Buttons(placeID: placeID)
        }
        .background(Color.white.cornerRadius(15))
        .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.85)
    }
    
    private func imageSection(place: Place, geometry: GeometryProxy) -> some View {
        Group {
            if !place.images.isEmpty {
                TabView {
                    ForEach(place.images, id: \.self) { imageUrl in
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image.resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.3)
                                .cornerRadius(20)
                        } placeholder: {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.3)
                                .cornerRadius(20)
                        }
                    }
                }
                .frame(height: geometry.size.height * 0.3)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            }
        }
    }
    
    private func featuresSection(place: Place, geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            TextField("Add a feature...", text: $newFeature)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
                .onSubmit(addFeature)
            
            ForEach(place.features.keys.sorted(), id: \.self) { user in
                ForEach(place.features[user] ?? [], id: \.self) { feature in
                    Text("• \(feature)")
                        .font(.body)
                        .padding(.vertical, 2)
                }
            }
        }
        .padding(.bottom, geometry.size.height * 0.015)
    }
    
    private func commentsSection(place: Place, geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading) {
            TextField("Add a comment ...", text: $newComment)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
                .onSubmit(addComment)
            
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
}
