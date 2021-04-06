//
//  SearchBar.swift
//  Scoff
//
//  Created by Scott Brown on 07/02/2021.
//  Resource used https://www.appcoda.com/swiftui-search-bar/
//
import SwiftUI
import Firebase
import MapKit

struct SearchBar: View {
    
    let db = Firestore.firestore()
    @Binding var text: String
    @Binding var data : [restaurantRaw]
    
    var isEditing : Bool {
        if text.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    var body: some View {
        HStack {
            
            TextField("Search ...", text: $text).onChange(of: text, perform: { (value) in
                print("name changed to \(value)")
            })
            .padding(7)
            .padding(.horizontal, 25)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 8)
                    
                    if isEditing {
                        // Button to cancel search
                        Button(action: {
                            self.text = ""
                        }) {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 8)
                        }
                    }
                }
            )
            .padding(.horizontal, 10)
            
            if isEditing {
                // Button for user to search
                Button(action: {
                    getQuiredData()
                }) {
                    Text("Search")
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }
    }
    
    func getQuiredData() {
        self.data = []
        
        
        let searchTerm = self.text.capitalizingFirstLetter()
        print(searchTerm)
        db.collection("restaurants").whereField("name", isGreaterThanOrEqualTo: searchTerm).getDocuments { (snap, err) in
            
            
            if err != nil{
                print((err?.localizedDescription)!)
                return
            }
            
            for newRestaurant in snap!.documents{
                
                // As the firebase query will get all documents after the query
                if (newRestaurant.get("name") as! String).contains(searchTerm){
                    
                    let coords = newRestaurant.get("location") as! GeoPoint
                    let lat = coords.latitude
                    let lon = coords.longitude
                    let data = restaurantRaw(id: newRestaurant.documentID, name: newRestaurant.get("name") as! String, picture: newRestaurant.get("splash_image") as! String, location: CLLocationCoordinate2D(latitude: lat,longitude: lon), email: newRestaurant.get("email") as! String)
                    
                    self.data.append(data)
                }
            }
            
        }
        
    }
}

// This is used to capitalise the first letter of the search term as the query is case sensitive
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
