//
//  HomeDisplay.swift
//  MyAccess
//
//  Created by Manisha Basnet on 9/21/24.
//

import SwiftUI
import FirebaseFirestore

struct HomeDisplay: View {
    @State private var documentData: [String: Any]? = nil // Store the fetched document data
    @State private var errorMessage: String? = nil        // Store error messages if any
    
    let db = Firestore.firestore() // Firestore instance
    
    // Function to read data from Firestore
    func testFirestoreRead() async {
        do {
            let document = try await db.collection("test").document("1").getDocument()
            if let data = document.data() {
                DispatchQueue.main.async {
                    self.documentData = data
                    self.errorMessage = nil
                }
                print("Document data: \(data)")
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Document does not exist!"
                    self.documentData = nil
                }
                print("Document does not exist!")
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error reading from Firestore: \(error.localizedDescription)"
                self.documentData = nil
            }
            print("Error reading from Firestore: \(error.localizedDescription)")
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            // Button to fetch data
            Button("Fetch Document") {
                Task {
                    await testFirestoreRead()
                }
            }
            
            // Display the fetched data
            if let data = documentData {
                Text("Fetched Data:")
                    .font(.headline)
                ForEach(data.keys.sorted(), id: \.self) { key in
                    if let value = data[key] {
                        Text("\(key): \(value)")
                            .font(.subheadline)
                    }
                }
            }
            
            // Display error message if any
            if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}

#Preview {
    HomeDisplay()
}
