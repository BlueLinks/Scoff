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
                HStack(spacing: 15){
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        Text(restaurant.name)
                            .font(.title)
                    }
                    
                    Spacer()
                    
                    // Show restaurant splash image
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
                List{
                    ForEach(self.data){ i in
                        
                        restaurantCardView(restaurant: i)
                    }
                    
                    if showFindMoreButton{
                        // Display button for finding more restaurants
                        Button(action: {
                            print("Finding more restaurants")
                            UpdateData()
                        }){
                            HStack{
                                Spacer()
                                Text("Get More").blueButtonStyle()
                                Spacer()
                            }
                        }
                    }
                }
            } else {
                // User is searching
                VStack{
                    List{
                        ForEach(self.searchData){ i in
                            restaurantCardView(restaurant: i)
                        }
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
                                // Show button to map view
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
                // When view is first loaded get the inital data
                // This check is performed as this closure will execute when navigating back from a restaurant
                self.getFirstData()
                self.firstLoad = false
            }
        }
    }
    
    // Recieve data from firestore
    
    
    func getFirstData() {
        // Get initial data
        // Limited to 5 restaurants to show how more documents could be retrived
        db.collection("restaurants").order(by: "name").limit(to: 5).getDocuments { (snap, err) in
            
            getData(snap: snap, err: err)
        }
    }
    
    
    func UpdateData() {
        // Get more data by specifying last retrieved document
        // Limited to 5 restaurants to show how more documents could be retrived
        db.collection("restaurants").order(by: "name").limit(to: 5).start(afterDocument: self.lastDoc).limit(to: 5).getDocuments { (snap, err) in
            
            getData(snap: snap, err: err)
        }
    }
    
    func getData(snap : QuerySnapshot?, err : Error?){
        
        if err != nil{
            print((err?.localizedDescription)!)
            return
        }
        
        for newRestaurant in snap!.documents{
            // Loop through retrived restaurants
            
            // Convert firebase data type to swift
            let coords = newRestaurant.get("location") as! GeoPoint
            let lat = coords.latitude
            let lon = coords.longitude
            let data = restaurantRaw(id: newRestaurant.documentID, name: newRestaurant.get("name") as! String, picture: newRestaurant.get("splash_image") as! String, location: CLLocationCoordinate2D(latitude: lat,longitude: lon), email: newRestaurant.get("email") as! String)
            
            // Appened restaurant to array
            self.data.append(data)
        }
        
        if let lastDoc = snap!.documents.last{
            if !(snap!.documents.count < 5) {
                // Assumed that if less than 5 documents are retrived then there are more restaurants
                self.showFindMoreButton = true
            }
            self.lastDoc = lastDoc
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
