//
//  RestaurantSelectView.swift
//  Scoff
//
//  Created by Scott Brown on 17/11/2020.
//

import SwiftUI
import Firebase
import URLImage
import MapKit



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
    @State var searchData : [restaurantRaw] = []
    @State var time = Timer.publish(every: 0.1, on: .main, in: .tracking).autoconnect()
    @State var firstLoad = true
    @State var mapIsActive = false
    @State var searchText : String = ""
    @State var showFindMoreButton: Bool = false
    
    
    var body: some View {
        VStack(spacing: 0){
            
            // Navigation link for map view
            NavigationLink(
                destination: RestaurantMapView(data: $data),
                isActive: $mapIsActive
            ) {
                EmptyView()
            }.isDetailLink(false)
            
            // Display search bar
            SearchBar(text: $searchText, data: $searchData)
                .padding(.top)
                .padding(.bottom)
            // loop through received restraunts
            if searchText.isEmpty{
                // User is not searching, display results as usual
                ForEach(self.data){ i in
                    
                    restaurantCardView(restaurant: i)
                }
                
                if showFindMoreButton{
                    // Display button for finding more restaurants
                    Button(action: {
                        print("Finding more restaurants")
                        UpdateData()
                    }){
                        Text("Get More").blueButtonStyle()
                    }
                }
            } else {
                // User is searching
                VStack{
                    ForEach(self.searchData){ i in
                        
                        restaurantCardView(restaurant: i)
                    }
                    
                }
                .onAppear(perform: {
                    self.searchData = []
                    print("User is now searching")
                })
            }
            Spacer()
        }
        .navigationBarTitle("Select")
        .navigationBarItems(trailing:
                                Button(action: {
                                    print("Map button pressed \(self.mapIsActive)")
                                    self.mapIsActive = true
                                }) {
                                    Image(systemName: "map")
                                }
        )
        .onAppear(){
            mapIsActive = false
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
            
            let coords = newRestaurant.get("location") as! GeoPoint
            let lat = coords.latitude
            let lon = coords.longitude
            let data = restaurantRaw(id: newRestaurant.documentID, name: newRestaurant.get("name") as! String, picture: newRestaurant.get("splash_image") as! String, location: CLLocationCoordinate2D(latitude: lat,longitude: lon), email: newRestaurant.get("email") as! String)
            
            self.data.append(data)
        }
        
        if let lastDoc = snap!.documents.last{
            if !(snap!.documents.count < 20) {
                self.showFindMoreButton = true
            }
            self.lastDoc = snap!.documents.last
        } else {
            self.showFindMoreButton = false
        }
        
        
        
    }
    
}




struct RestaurantSelectView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantSelectView()
    }
}
