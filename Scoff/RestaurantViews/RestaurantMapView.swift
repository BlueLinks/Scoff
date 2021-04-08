//
//  RestaurantMapView.swift
//  Scoff
//
//  Created by Scott Brown on 25/01/2021.
//

import SwiftUI
import MapKit

struct RestaurantMapView: View {
    // Map view to select restaurants
    
    @State private var centerCoordinate = CLLocationCoordinate2D()
    @State private var locations = [MKPointAnnotation]()
    @State private var selectedPlace: MKPointAnnotation?
    @State private var showingPlaceDetails = false
    
    private var selectedRestaurant : restaurantRaw {
        if let restaurantAnnotation = selectedPlace {
            let index = Int(restaurantAnnotation.subtitle!)
            return data[index!]
        }
        return restaurantRaw(id: "", name: "placeholder", picture: "", email: "")
    }
    
    
    // Current limitiation that map will only show restaurants downloaded from RestaurantSelectView
    @Binding var data : [restaurantRaw]
    
    var body: some View {
        
        MapView(centerCoordinate: $centerCoordinate, selectedPlace: $selectedPlace, showingPlaceDetails: $showingPlaceDetails, annotations: locations)
        
        NavigationLink(
            // Create navigation link to restaurant
            destination: MenuSelectView(restaurant: selectedRestaurant),
            isActive: $showingPlaceDetails
        ) {
            // When map pin is tapped on, pop up will already show restaurant name
            EmptyView()
        }
            
        .navigationBarTitle(Text("Map"), displayMode: .inline)
            .onAppear(){
                showingPlaceDetails = false
                addLocations()
            }
    }
    
    func addLocations(){
        // Add each location to map
        for index in data.indices {
            let restaurant = data[index]
            let newLocation = MKPointAnnotation()
            newLocation.coordinate = restaurant.location
            newLocation.title = restaurant.name
            newLocation.subtitle = String(index)
            print("Adding pin at \(restaurant.location)")
            self.locations.append(newLocation)
        }
    }
    
}
