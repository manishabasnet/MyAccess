import SwiftUI

struct HomeView: View {
    
    let searchBarColor = Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
    
    var body: some View {
        GeometryReader {
            geometry in
            
            VStack (spacing: geometry.size.height * 0.015) {
                // this is for estimation, replace with actual back button
//                Image(systemName: "plus")
//                    .font(.title)
//                    .padding()
                //search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .padding(.trailing, geometry.size.width * 0.015)
                    Text("Search places.....")
                }
                    .frame(maxWidth:.infinity, alignment: .leading)
                    .padding(.vertical, geometry.size.height * 0.01)
                    .padding(.leading, geometry.size.width * 0.03)
                    .background(searchBarColor)
                    .cornerRadius(geometry.size.height * 0.1)
                    .padding(.horizontal, geometry.size.height * 0.045)
                    .padding(.vertical, geometry.size.height * 0.015)


                Text("Places near you")
                        .font(.title)
                        .fontWeight(.bold)
                
                //Individual location display
                VStack {
                    Image("spence")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.35, alignment: .top)
                        .cornerRadius(20)
                        .padding(.top, geometry.size.height * 0.025)
                        .padding(.bottom, geometry.size.height * 0.015)
                    
                    //building name
                    Text("Spence Hall")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, geometry.size.height * 0.015)
                    
                    //Building description
                    Text("This is a very accessible building with all the accessible facilities included")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                    
                    //icons for a specific buildings
                    HStack{
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
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x:0.0, y: 10)
                )
                .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.7)
            
            
        }
    }
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
