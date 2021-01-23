//
//  RestaurantView.swift
//  Scoff
//
//  Created by Scott Brown on 11/11/2020.
//

import SwiftUI


struct RestaurantView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        NavigationView{
            
            ZStack {
                
                
                Image("Splash")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                VStack{
                    
                    
                    Text("Scoff")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    NavigationLink(destination: RestaurantSelectView()){
                        HStack{
                            Text("Find a restaurant ")
                            Image(systemName : "chevron.right")
                        }
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Capsule())
                        .foregroundColor(.white)
                        
                    }
                    Spacer()
                }
                
            }
        }
    }
    
    init() {
//        UINavigationBar.appearance().backgroundColor = .black
//        if colorScheme == .dark {
//            UINavigationBar.appearance().backgroundColor = .black
//        } else {
//            UINavigationBar.appearance().backgroundColor = .white
//        }
    }
    
    struct RestaurantView_Previews: PreviewProvider {
        static var previews: some View {
            RestaurantView()
        }
    }
}
