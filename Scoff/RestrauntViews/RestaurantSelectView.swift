//
//  RestaurantSelectView.swift
//  Scoff
//
//  Created by Scott Brown on 17/11/2020.
//

import SwiftUI
import Firebase
import URLImage



// View for displaying restraunt details
struct restaurantCardView : View {
    var restaurant: restaurantRaw
    
    var body: some View{
        // create link to view of restraunts menus
        NavigationLink(destination: MenuSelectView(restaurant: restaurant)){
            VStack(spacing: 0){
                Divider()
                HStack(spacing: 15){
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        Text(restaurant.name)
                            .font(.title)
                    }
                    
                    Spacer()
                    
                    URLImage(url: URL(string: restaurant.picture)!){ image in
                        image
                        .resizable()
                            .scaledToFill()
                        .frame(width: 180, height: 180, alignment : .center)
                            .clipped()
                    }
                    
                }
            }
        }
    }
}


struct RestaurantSelectView: View {
    
    let db = Firestore.firestore()
    @State var lastDoc : QueryDocumentSnapshot!
    @State var data : [restaurantRaw] = []
    @State var time = Timer.publish(every: 0.1, on: .main, in: .tracking).autoconnect()
    @State var firstLoad = true
    
    var body: some View {
        // loop through received restraunts
        ForEach(self.data){ i in
            ZStack{
                
                if self.data.last!.id == i.id{
                    
                    GeometryReader{g in

                        // display restraunt
                        restaurantCardView(restaurant: i)
                            
                        .onAppear{
                            
                            self.time = Timer.publish(every: 0.1, on: .main, in: .tracking).autoconnect()
                        }
                        .onReceive(self.time) { (_) in
                            
                            if g.frame(in: .global).maxY < UIScreen.main.bounds.height - 80{
                                
                                self.UpdateData()
                                
                                print("Update Data...")
                                
                                self.time.upstream.connect().cancel()
                            }
                        }
                    }
                    .frame(height: 65)
                    
                }
                else{
                    
                    restaurantCardView(restaurant: i)
                    
                }
            }
        }
            .navigationTitle("Select")
        .onAppear(){
            if firstLoad{
                self.getFirstData()
                self.firstLoad = false
            }
        }
    }
    
    // Recieve data from firestore

    
    func getFirstData() {
        db.collection("restaurants").order(by: "name").limit(to: 20).getDocuments { (snap, err) in
            
            getData(snap: snap, err: err)
            
        }
    }
    
    
    func UpdateData() {
        
        db.collection("restaurants").order(by: "name").limit(to: 20).start(afterDocument: self.lastDoc).limit(to: 20).getDocuments { (snap, err) in
            
            getData(snap: snap, err: err)
        
        }
    }
    
    func getData(snap : QuerySnapshot?, err : Error?){
        
        if err != nil{
            print((err?.localizedDescription)!)
            return
        }
        
        for newRestaurant in snap!.documents{
            let data = restaurantRaw(id: newRestaurant.documentID, name: newRestaurant.get("name") as! String, picture: newRestaurant.get("splash_image") as! String)
            
            self.data.append(data)
        }
        
        self.lastDoc = snap!.documents.last
            
            
    }
    
}




struct RestaurantSelectView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantSelectView()
    }
}
