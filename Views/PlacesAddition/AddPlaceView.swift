//
//  AddPlaceView.swift
//  SwiftfulThinking
//
//  Created by Manisha Basnet on 10/6/24.
//

import SwiftUI

struct AddPlaceView: View {
    @EnvironmentObject private var authViewModel: AuthenticationViewModel

    @State private var hasVisited: Bool = false
    @State private var placeName: String = ""
    @State private var featuresNames = [String]()
    @State private var featureInput: String = ""
    @State private var features: [String:[String]] = [:]
    @State private var description: String = ""
    @State private var location: String = "" // Replace with location object if needed
    @State private var city: String = ""
    @State private var images = [UIImage]()
    @State private var selectedImage: UIImage? = nil
    @State private var selectedImages: [UIImage] = []
    @State private var showImagePicker: Bool = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""

    private let placeService = PlaceService()
    
    var body: some View {
        NavigationView {
            ScrollView{
                Form {
                    Section(header: Text("Place Details")) {
                        Text("Place Name")
                            .font(.headline)
                        TextField("Enter place name", text: $placeName)
                            .padding()
                            .background(Color.gray.opacity(0.6))
                            .cornerRadius(15)
                        
                        HStack {
                            Text("Have you visited this place?")
                                .font(.headline)
                            Spacer()
                            Picker(selection: $hasVisited, label: Text("")) {
                                Text("Yes").tag(true)
                                Text("No").tag(false)
                            }
                        }
                    }
                    
                    Section(header: Text("Description")) {
                        TextField("Enter description", text: $description)
                            .padding()
                            .background(Color.gray.opacity(0.6))
                            .cornerRadius(15)
                    }
                    
                    Section(header: Text("Address")) {
                        TextField("Enter location", text: $location)
                            .padding()
                            .background(Color.gray.opacity(0.6))
                            .cornerRadius(15)
                        Text("City")
                            .font(.headline)
                        TextField("Enter city name", text: $city)
                            .padding()
                            .background(Color.gray.opacity(0.6))
                            .cornerRadius(15)
                    }
                    
                    Section(header: Text("Features")) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                // Get the features for the currentUserID
                                if let userFeatures = features[authViewModel.currentUserID] {
                                    ForEach(userFeatures, id: \.self) { feature in
                                        HStack {
                                            Text(feature)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 5)
                                                .background(Color.blue.opacity(0.2))
                                                .cornerRadius(10)
                                            Button(action: {
                                                removeFeature(feature)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                            }
                                        }
                                        .padding(.trailing, 5)
                                    }
                                }
                            }
                        }

                        
                        TextField("Add a feature and press Enter", text: $featureInput, onCommit: addFeature)
                            .padding()
                            .background(Color.gray.opacity(0.6))
                            .cornerRadius(15)
                    }
                    
                    Section(header: Text("Upload Place Images")) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(selectedImages.indices, id: \.self) { index in
                                    Image(uiImage: selectedImages[index])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(10)
                                        .overlay(
                                            Button(action: {
                                                selectedImages.remove(at: index)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                                    .background(Color.white.clipShape(Circle()))
                                            }
                                                .padding(4),
                                            alignment: .topTrailing
                                        )
                                }
                                
                                Button(action: {
                                    showImagePicker = true
                                }) {
                                    Image(systemName: "plus")
                                        .foregroundColor(.blue)
                                        .frame(width: 100, height: 100)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                    
                    Section {
                        HStack {
                            Spacer()
                            Button(action: handleSubmit) {
                                Text("Submit")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 100, height: 55)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            Spacer()
                        }
                    }
                }
                .frame(minHeight: UIScreen.main.bounds.height) // Force minimum height
            }
            .navigationTitle("")
            .sheet(isPresented: $showImagePicker) {
                MultiImagePicker(selectedImages: $selectedImages)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Add Place"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // Function to add a feature when the user hits "Enter"
    private func addFeature() {
           let trimmedInput = featureInput.trimmingCharacters(in: .whitespacesAndNewlines)
           if !trimmedInput.isEmpty {
               // Use the currentUserID from the authViewModel
               if features[authViewModel.currentUserID] == nil {
                   features[authViewModel.currentUserID] = []
               }
               
               features[authViewModel.currentUserID]?.append(trimmedInput)
               print("Updated features: \(features)") // Debugging line

               featureInput = "" // Reset input field after adding
           }
       }

    // Function to remove a feature
    private func removeFeature(_ feature: String) {
        featuresNames.removeAll { $0 == feature }
        features[authViewModel.currentUserID]?.removeAll { $0 == feature }
    }
    
    // Function to handle form submission
    private func handleSubmit() {
        guard !placeName.isEmpty, !location.isEmpty, !description.isEmpty, !city.isEmpty else {
            alertMessage = "Please fill in all required fields."
            showAlert = true
            return
        }
        
        let imagesToUpload = selectedImages.isEmpty ? [] : selectedImages

        // Call the addPlace function
        placeService.addPlace(placeName: placeName, description: description, location:location, features:features, images: imagesToUpload, userID: authViewModel.currentUserID, city: city ) { result in
            switch result {
            case .success:
                alertMessage = "Place added successfully!"
            case .failure(let error):
                alertMessage = "Failed to add place: \(error.localizedDescription)"
            }
            showAlert = true
        }
    }
}

struct AddPlaceView_Previews: PreviewProvider {
    static var previews: some View {
        AddPlaceView()
            .environmentObject(AuthenticationViewModel())
    }
}
