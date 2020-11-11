//
//  RestaurantView.swift
//  Scoff
//
//  Created by Scott Brown on 11/11/2020.
//

import SwiftUI

struct RestaurantSelectView: View {
    var body: some View {
            VStack{
                Text("This is the select view")
                NavigationLink(destination: Text("This is the restaurant view")){
                    Text("Tap Here")
                }
            }
                .navigationTitle("Select")
    }
}

struct RestaurantView: View {
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
}

struct RestaurantView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantView()
    }
}
