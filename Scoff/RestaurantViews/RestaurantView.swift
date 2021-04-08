//
//  RestaurantView.swift
//  Scoff
//
//  Created by Scott Brown on 11/11/2020.
//

import SwiftUI


struct RestaurantView: View {
    // First view a user will see when opening Scoff for first time
    
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        NavigationView{
            
            ZStack {
                // Show splash image behind ui components
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
                        .blueButtonStyle()
                        
                    }
                    Spacer()
                }
                
            }
        }
    }
    

    struct RestaurantView_Previews: PreviewProvider {
        static var previews: some View {
            RestaurantView()
        }
    }
}
