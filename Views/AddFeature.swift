//
//  AddFeature.swift
//  MyAccess
//
//  Created by Manisha Basnet on 10/20/24.
//

import SwiftUI

struct AddFeature: View {
    
    @State private var placeName: String = ""
    @State private var featuresNames = [String]()
    @State private var featureInput: String = ""
    @State private var location: String = "" // later put a location object or whatever data comes from API
    
    var body: some View {
        Form{
            VStack(alignment: .leading) {
                Text("Place Name")
                    .font(.headline)
                TextField("Enter place name", text: $placeName)
                    .padding()
                    .background(Color.gray.opacity(0.6))
                    .cornerRadius(15)

                Text("Location")
                    .font(.headline)
                TextField("Enter location", text: $location)
                    .padding()
                    .background(Color.gray.opacity(0.6))
                    .cornerRadius(15)
                
                Text("Additional Features")
                    .font(.headline)
                // Features input and display
                VStack(alignment: .leading) {
                    // Displaying the existing features as tags
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(featuresNames, id: \.self) { feature in
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

                    // TextField to add new features
                    TextField("Add a feature and press Enter", text: $featureInput, onCommit: addFeature)
                        .padding()
                        .background(Color.gray.opacity(0.6))
                        .cornerRadius(15)
                }
                
                HStack {
                    Spacer()
                    Text("Submit")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 100, height: 55)
                        .background(Color.blue)
                        .cornerRadius(10)
                    Spacer() // Ensure the button is centered
                }
                .padding(.vertical, 20)
            }
        }
        
//this is where the button is supposed to be
    }
    
    private func addFeature() {
        let trimmedInput = featureInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedInput.isEmpty {
            featuresNames.append(trimmedInput)
            featureInput = "" // Reset input field after adding
        }
    }

    // Function to remove a feature
    private func removeFeature(_ feature: String) {
        featuresNames.removeAll { $0 == feature }
    }
}

#Preview {
    AddFeature()
}
