//
//  MenuView.swift
//  Scoff
//
//  Created by Scott Brown on 07/12/2020.
//

import SwiftUI
import Firebase
import URLImage

// For storing items from menu
struct itemRaw : Identifiable {
    var id: String
    var name: String
    var price : Double
    var image : String
}

// For storing extra's for items
struct extraRaw : Identifiable {
    var id: String
    var name: String
    var price : Double
    var extraSelected : Bool
}

// For displaying items
struct itemCardView : View {
    // Keep track if sheet for ordering item is showing
    @State var showingDetail = false
    var item: itemRaw
    var itemsRef : CollectionReference
    
    var body: some View{
        Button( action: {
            // When button is pressed, show sheet
            self.showingDetail.toggle()
        }) {
            HStack{
                VStack(alignment: .leading){
                    Text(item.name)
                        .font(.title)
                    
                    Text("£\(item.price, specifier: "%.2f")")
                        .font(.body)
                }.padding(.leading, 10)
                Spacer()
                
                URLImage(url: URL(string: item.image)!){ image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150, alignment : .center)
                        .clipped()
                }
                
            }
        }.sheet(isPresented: $showingDetail) {
            addItemToOrderView(item: item, showing: self.$showingDetail, itemsRef: itemsRef)
        }
        
    }
}

// View displayed as sheet to add item to order
struct addItemToOrderView : View{
    
    var item : itemRaw
    @Binding var showing : Bool
    var itemsRef : CollectionReference
    @State var data : [extraRaw] = []
    @State var userRequests = ""
    @State var orderAmount = 1.00
    
    @EnvironmentObject var settings: Order
    
    
    var body : some View{
        
        // Button for returing without ordering
        HStack{
            Button( action: {
                showing = false
            }) {
                HStack{
                    Image(systemName : "chevron.left")
                    Text("Back ")
                }
            }.padding()
            Spacer()
        }
        VStack{
            // Display image of item
            URLImage(url: URL(string: item.image)!){ image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.size.width, height: 250, alignment : .center)
                    .clipped()
            }
            Text("\(item.name)")
                .font(.title)
            Form{
                // Check if item has extras
                if !self.data.isEmpty {
                    Section(header: Text("Any Extras?")){
                        ScrollView(.vertical){
                                // Display Extras
                                ForEach(data.indices) { index in
                                    Toggle(isOn: self.$data[index].extraSelected) {
                                        VStack(alignment: .leading){
                                            Text("\(self.data[index].name)")
                                            Text("£\(self.data[index].price, specifier: "%.2f")")
                                        }
                                        
                                    }
                                }.padding(.trailing)
                                .padding(.leading)
                        }
                    }
                }
                Section(header: Text("Any requests for the chef?")){
                    TextField("e.g. no onions", text: $userRequests)
                }
                Section(header: Text("Total price for \(orderAmount, specifier: "%.0f") \(item.name)")){
                    HStack{
                        Stepper("£\(orderAmount * item.price, specifier: "%.2f")", value: $orderAmount, in: 1...10)
                    }
                }
                // Button for adding item with extra to Order TODO
                Button( action: {
                    var listOfExtras : [extraRaw] = []
                    for extra in self.data{
                        if extra.extraSelected {
                            listOfExtras.append(extra)
                        }
                        for index in 0..<data.count{
                            data[index].extraSelected = false
                        }
                    }
                    self.settings.items.append(orderItem(item: item, quantity: Int(orderAmount), extras: listOfExtras))
                    self.showing = false
                }) {
                    Section{
                        HStack{
                            Spacer()
                            Text("Add \(orderAmount, specifier: "%.0f") to order")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.blue)
                                .clipShape(Capsule())
                            Spacer()
                        }
                    }
                }
            }
        }
        // On load get extras
        .onAppear(){
            getExtras(dbRef: itemsRef, itemID: item.id)
        }
        
    }
    
    func getExtras(dbRef : CollectionReference, itemID : String) {
        // get extra documents
        dbRef.document(itemID).collection("extras").getDocuments() { (extraList, err) in
            
            
            if err != nil{
                print((err?.localizedDescription)!)
                return
            }
            
            // Loop through extras in retrieved extras
            for newExtra in extraList!.documents{
                
                // construct new extra
                let extra = extraRaw(id: newExtra.documentID, name: newExtra.get("name") as! String, price: newExtra.get("price") as! Double, extraSelected: false)
                
                // append new extra to list of extras
                self.data.append(extra)
                
            }
        }
    }
    
}

struct MenuView: View {
    
    var menu : menuRaw
    var restaurantID : String
    
    let db = Firestore.firestore()
    @State var data : [itemRaw] = []
    @State var firstLoad = true
    
    var body: some View {
        // Create reference to item in firestore
        let itemsRef = db.collection("restaurants").document(restaurantID).collection("menus").document(menu.id).collection("items")
        
        ScrollView(.vertical){
            VStack(spacing: 0){
                ForEach(self.data){ item in
                    Divider()
                    itemCardView(item : item, itemsRef: itemsRef)
                    // display each item from menu
                }
                Divider()
                Spacer()
            }
        }.padding(.top)
        .onAppear(){
            if firstLoad {
                self.getItems(dbRef: itemsRef)
                self.firstLoad = false
            }
        }.navigationTitle("\(menu.name)")
    }
    
    
    func getItems(dbRef : CollectionReference) {
        // get item documents
        db.collection("restaurants").document(restaurantID).collection("menus").document(menu.id).collection("items").getDocuments() { (itemList, err) in
            
            
            if err != nil{
                print((err?.localizedDescription)!)
                return
            }
            
            // Loop through items in retrieved menus
            for newItem in itemList!.documents{
                
                // construct new item
                let item = itemRaw(id: newItem.documentID, name: newItem.get("name") as! String, price: newItem.get("price") as! Double, image: newItem.get("image") as! String)
                
                // append new item to list of items
                self.data.append(item)
                
            }
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        
        MenuView(menu: menuRaw(id: "1", name: "Placeholder"), restaurantID : "Placeholder")
    }
}
