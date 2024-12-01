//
//  SwiftUIView.swift
//  SwiftfulThinking
//
//  Created by Manisha Basnet on 10/6/24.
//

import SwiftUI
//writing a comment for testing purpose

struct MainView: View {
    @State private var selectedView: ViewType = .home
    var body: some View {
        GeometryReader {geometry in
            VStack{
        
                Spacer()
                
                switch selectedView {
                    case .home:
                        HomeView()
                    case .addPlace:
                        AddPlaceView()
                    case .profile:
                        DynamicProfileView()
                }
                
                HStack{
                    Image(systemName: "house.fill")
                        .font(.largeTitle)
                        .padding()
                        .onTapGesture {
                            selectedView = .home
                        }
                    Image(systemName: "plus.app.fill")
                        .font(.largeTitle)
                        .padding(.horizontal, geometry.size.height * 0.1)
                        .onTapGesture {
                            selectedView = .addPlace
                        }
                    Image(systemName: "person.crop.circle.fill")
                        .font(.largeTitle)
                        .padding()
                        .onTapGesture {
                            selectedView = .profile
                        }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}

enum ViewType {
    case home
    case addPlace
    case profile
}

#Preview {
    MainView()
}
