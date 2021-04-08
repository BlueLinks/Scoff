//
//  MenuView.swift
//  Scoff
//
//  Created by Scott Brown on 07/12/2020.
//

import SwiftUI
import Firebase
import URLImage



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
                    Spacer()
                    // Show dietary symbols
                    dietaryItemSymbolsView(item : item)
                }.padding(10)
                Spacer()
                
                // Show item image
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
    
    @EnvironmentObject var order : Order
    
    var item : itemRaw
    @Binding var showing : Bool
    var itemsRef : CollectionReference
    @State var data : [extraRaw] = []
    @State var userNotes = ""
    @State var orderAmount = 1.00
    
    var extrasPrice : Double {
        // Calculate total price of extras
        var totalExtrasPrice : Double = 0
        for extra in self.data{
            if extra.extraSelected {
                totalExtrasPrice += extra.price
            }
            
        }
        return totalExtrasPrice
    }
    
    var priceheaderText : String {
        // This is used to give feedback that the total price is including the price of the extras
        for extra in self.data{
            if extra.extraSelected {
                // If an extra has been selected
                return "with extras"
            }
        }
        return ""
        
    }
    
    
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
            HStack{
                // Show item name and dietary symbols
                Text("\(item.name)")
                    .font(.title)
                Spacer()
                dietaryItemSymbolsView(item: item)
            }.padding(.leading, 10)
            .padding(.trailing, 10)
            Form{
                // Check if item has extras
                if !self.data.isEmpty {
                    Section(header: Text("Any Extras?")){
                        
                        // Display Extras
                        ForEach(data.indices) { index in
                            // Use extraSelected field to keep track of each selected extra
                            Toggle(isOn: self.$data[index].extraSelected) {
                                HStack{
                                    // Show extra name and price
                                    VStack(alignment: .leading){
                                        Text("\(self.data[index].name)")
                                        Text("£\(self.data[index].price, specifier: "%.2f")")
                                    }
                                    // show extra dietary symbols
                                    dietaryExtraSymbolsView(extra: self.data[index])
                                }
                                
                            }
                        }
                        
                    }
                }
                Section(header: Text("Any requests for the chef?")){
                    TextField("e.g. no onions", text: $userNotes)
                }
                Section(header: Text("Total price for \(orderAmount, specifier: "%.0f") \(item.name) \(priceheaderText)")){
                    HStack{
                        Stepper("£\(orderAmount * (item.price + extrasPrice), specifier: "%.2f")", value: $orderAmount, in: 1...10)
                    }
                }
                // Button for adding item with extra to Order
                Section{
                Button( action: {
                    var listOfExtras : [extraRaw] = []
                    for extra in self.data{
                        if extra.extraSelected {
                            listOfExtras.append(extra)
                        }
                        for index in 0..<data.count{
                            // reset extra selected field in all extras
                            data[index].extraSelected = false
                        }
                    }
                    //Append item to order
                    self.order.items.append(orderItem(item: item, quantity: Int(orderAmount), extras: listOfExtras, notes: userNotes))
                    self.showing = false
                }) {
                        HStack{
                            Text("Add \(orderAmount, specifier: "%.0f") to order")
                        }
                    }
                }.buttonStyle(formButtonStyle())
                .listRowBackground(Color(.systemGroupedBackground))
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
                let extra = extraRaw(id: newExtra.documentID, name: newExtra.get("name") as! String, price: newExtra.get("price") as! Double, extraSelected: false, vegetarian: newExtra.get("vegetarian") as! Bool, vegan: newExtra.get("vegan") as! Bool, gluten: newExtra.get("gluten") as! Bool)
                
                // append new extra to list of extras
                self.data.append(extra)
                
            }
        }
    }
    
}

// Object used to store all items
class itemContainer : ObservableObject {
    
    // Track selected dietary filters
    @Published var vegetarianSelected = false
    @Published var veganSelected = false
    @Published var glutenFreeSelected = false
    @Published var userDietSelected = false
    
    let db = Firestore.firestore()
    @Published var data : [itemRaw] = []
    
    // Filter data
    var filteredData : [itemRaw] {
        var unfilteredData = self.data
        if vegetarianSelected {
            unfilteredData = unfilteredData.filter{$0.vegetarian}
        }
        if veganSelected {
            unfilteredData = unfilteredData.filter{$0.vegan}
        }
        if glutenFreeSelected {
            unfilteredData = unfilteredData.filter{!$0.gluten}
        }
        // if no filter selcted, unfilteredData will hold all data
        return unfilteredData
    }
    
    func getData(restaurantID : String, menu : menuRaw){
        // get item documents
        self.data = []
        db.collection("restaurants").document(restaurantID).collection("menus").document(menu.id).collection("items").getDocuments() { (itemList, err) in
            
            
            if err != nil{
                print((err?.localizedDescription)!)
                return
            }
            
            // Loop through items in retrieved menus
            for newItem in itemList!.documents{
                
                // construct new item
                let item = itemRaw(id: newItem.documentID, name: newItem.get("name") as! String, price: newItem.get("price") as! Double, image: newItem.get("image") as! String, vegetarian: newItem.get("vegetarian") as! Bool, vegan: newItem.get("vegan") as! Bool, gluten: newItem.get("gluten") as! Bool)
                
                // append new item to list of items
                self.data.append(item)
                
            }
        }
    }
}

struct MenuView: View {
    
    var menu : menuRaw
    var restaurantID : String
    
    let db = Firestore.firestore()
    @State var firstLoad = true
    @ObservedObject var data = itemContainer()
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        // Create reference to item in firestore
        let itemsRef = db.collection("restaurants").document(restaurantID).collection("menus").document(menu.id).collection("items")
        
        ScrollView(.vertical){

            HStack{
                // Show dietary filters
                Button(action: {
                    self.data.vegetarianSelected.toggle()
                    self.data.userDietSelected = false
                    print("Vegetarian filter selected")
                }){
                    // saturation used to indicate filter selected
                    vegetarianSymbol().saturation(self.data.vegetarianSelected ? 1.0 : 0)
                }
                Button(action: {
                    self.data.veganSelected.toggle()
                    self.data.userDietSelected = false
                    print("Vegan filter selected")
                }){
                    veganSymbol().saturation(self.data.veganSelected ? 1.0 : 0)
                }
                Button(action: {
                    self.data.glutenFreeSelected.toggle()
                    self.data.userDietSelected = false
                    print("Gluten Free filter selected")
                }){
                    glutenFreeSymbol().saturation(self.data.glutenFreeSelected ? 1.0 : 0)
                }
                if let user = session.session{
                    // if user is signed in, show button to filter by account requirments
                    HStack{
                        Button(action: {
                            print("User diet selected")
                            self.data.userDietSelected.toggle()
                            if user.vegetarian!{
                                self.data.vegetarianSelected = self.data.userDietSelected
                            }
                            if user.vegan!{
                                self.data.veganSelected = self.data.userDietSelected
                            }
                            if user.coeliac!{
                                self.data.glutenFreeSelected = self.data.userDietSelected
                            }
                        }){
                            userDietSymbol().saturation(self.data.userDietSelected ? 1.0 : 0)
                        }
                    }
                }
            }
            
            VStack(spacing: 0){
                ForEach(self.data.filteredData){ item in
                    Divider()
                    itemCardView(item : item, itemsRef: itemsRef).frame(minHeight: 150,maxHeight: .infinity)
                    // display each item from menu
                }.animation(.default)
                Divider()
                Spacer()
            }
        }.padding(.top)
        .onAppear(){
            if firstLoad {
                self.data.getData(restaurantID: restaurantID, menu: menu)
                self.firstLoad = false
            }
        }.navigationTitle("\(menu.name)")
    }
    
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        
        MenuView(menu: menuRaw(id: "1", name: "Placeholder"), restaurantID : "Placeholder")
    }
}
