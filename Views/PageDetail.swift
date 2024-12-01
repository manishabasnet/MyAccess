//
//  PageDetail.swift
//  MyAccess
//
//  Created by Manisha Basnet on 11/3/24.
//

import SwiftUI

struct PageDetail: View {
    
    let searchBarColor = Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
    let features: [String] = ["Ramp", "Entrance-exit signs", "Elevator", "Voice menu"]
    let comments: [String] = ["The employees are friendly...", "Great accessibility features...", "Easy to navigate for wheelchair users."]
    
    var body: some View {
        GeometryReader { geometry in
            VStack { // Outer VStack for centering
                VStack(spacing: geometry.size.height * 0.015) {
                    
                    // Individual location display
                    VStack(alignment: .leading) {
                        Image("spence")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.3, alignment: .top)
                            .cornerRadius(20)
                            .padding(.top, geometry.size.height * 0.025)
                            .padding(.bottom, geometry.size.height * 0.015)
                        
                        // Building name
                        Text("Spence Hall")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.bottom, geometry.size.height * 0.015)
                        
                        // Building description
                        Text("This is a very accessible building with all the accessible facilities included.")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, geometry.size.height * 0.015)
                        
                        // Features section
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Features")
                                .font(.headline)
                                .padding(.bottom, 5)
                            
                            ForEach(features, id: \.self) { feature in
                                Text("• \(feature)")
                                    .font(.body)
                                    .padding(.vertical, 2)
                            }
                        }
                        .padding(.bottom, geometry.size.height * 0.015)
                        
                        // Comments section
                        VStack(alignment: .leading) {
                            TextField("Add a comment ...", text: .constant(""))
                                .padding()
                                .background(searchBarColor)
                                .cornerRadius(8)
                            
                            ForEach(comments, id: \.self) { comment in
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
                        
                        // Icons for a specific building
                        HStack {
                            Image(systemName: "hand.thumbsup.fill")
                                .font(.largeTitle)
                                .padding()
                            Image(systemName: "hand.thumbsdown.fill")
                                .font(.largeTitle)
                                .padding()
                            Image(systemName: "plus.message.fill")
                                .font(.largeTitle)
                                .padding()
                            Image(systemName: "plus")
                                .font(.largeTitle)
                                .padding()
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                    }
                    .background(
                        Color.white
                            .cornerRadius(15)
                    )
                    .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.85)
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Center inner VStack
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center) // Center outer VStack
        }
    }
}

#Preview {
    PageDetail()
}
