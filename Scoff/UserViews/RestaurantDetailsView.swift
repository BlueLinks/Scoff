//
//  RestaurantDetailsView.swift
//  Scoff
//
//  Created by Scott Brown on 04/01/2021.
//

import SwiftUI
import Firebase

struct RestaurantDetailsView: View {
    
    let db = Firestore.firestore()
    @State var restaurant = restaurantRaw(id: "", name: "", picture: "")
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        VStack{
            Form{
                if  let user = session.session{
                    Section(header: Text("Restaurant details")){
                        Text("\(restaurant.name)")
                        Text("\(restaurant.picture)")
                    }
                    Section(header: Text("User details")){
                        Text("\(user.firstName!)")
                        Text("\(user.lastName!)")
                        Text("\(user.email!)")
                        Text("\(user.dateOfBirth!)")
                    }
                }
                
            }
        }.onAppear(perform: getData)
    }
    
    
    func getData() {
        if let user = session.session{
            db.collection("restaurants").document(user.restaurantID!).getDocument { (document, err) in
                
                if err != nil{
                    print((err?.localizedDescription)!)
                    return
                }
                
                if let restaurant = document{
                    self.restaurant =  restaurantRaw(id: restaurant.documentID, name: restaurant.get("name") as! String, picture: restaurant.get("splash_image") as! String)
                }
                
            }
        }
    }
    
    struct RestaurantDetailsView_Previews: PreviewProvider {
        static var previews: some View {
            RestaurantDetailsView()
        }
    }
    
    
}
