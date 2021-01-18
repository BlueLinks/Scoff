//
//  OrderView.swift
//  Scoff
//
//  Created by Scott Brown on 11/11/2020.
//

import SwiftUI
import Stripe
import URLImage
import Firebase

struct OrderView: View {
    
    
    @EnvironmentObject var order : Order
    @EnvironmentObject var session: SessionStore
    
    @State private var itemsInCart : Bool = true
    
    @State private var tableNumberPicker : Int = 0
    
    private var tableNumber : Int {
        return tableNumberPicker + 1
    }
    
    @State private var tableWarn : Bool = false
    @State var orderWarn : Bool = false
    
    var body: some View {
        NavigationView{
            VStack{
                if itemsInCart {
                    // if items are in the cart then show the checkout
                    List{
                        if let restaurant = self.order.restaurant{
                            Section{
                                HStack(){
                                    Text(restaurant.name)
                                        .font(.title)
                                Spacer()
                                    URLImage(url: URL(string: restaurant.picture)!){ image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 100)
                                            .clipped()
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                    }
                                }
                                
                            }
                        }
                        
                        Section(header: Text("Cart")){
                            ForEach(self.order.items){ item in
                                // Show items in the order
                                VStack(alignment: .leading, spacing: 5){
                                    HStack{
                                        Text("\(item.quantity) * \(item.item.name)")
                                        Spacer()
                                        Text("£\(item.item.price, specifier: "%.2f")")
                                    }
                                    if (item.extras.count > 0){
                                        // Show the extras that have been added to item
                                        ForEach(item.extras){extra in
                                            HStack{
                                                Spacer()
                                                Text("\(extra.name)")
                                                Spacer()
                                                Spacer()
                                                Spacer()
                                                Text("£\(extra.price, specifier: "%.2f")")
                                            }
                                        }
                                    }
                                    if (item.notes != ""){
                                        HStack{
                                            Text("Notes:")
                                            Text("\(item.notes)").foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                            .onDelete(perform: delete)
                        }
                        Section{
                            
                            HStack{
                                Picker(selection : $tableNumberPicker, label : Text("Please select your table number")){
                                    ForEach(1 ..< 30){ number in
                                        Text("Table \(number)")
                                    }
                                }
                            }.alert(isPresented:$tableWarn){
                                Alert(title: Text("Table Number"), message: Text("Are you sure you're at table \(tableNumber)?"), primaryButton: .destructive(Text("I'm Sure")){
                                    print("They are sure")
                                    order.orderTime = Date()
                                    placeOrder()
                                    
                                }, secondaryButton: .cancel())
                            }
                            HStack{
                                // Show total price
                                Text("Total")
                                Spacer()
                                Text("£\(self.order.total, specifier: "%.2f")")
                            }
                            
                            Button(action : {
                                //Checkout button
                                print("Checkout button pressed")
                                tableWarn.toggle()
                            }){
                                HStack{
                                    Spacer()
                                    Text("Checkout").font(.title)
                                        .padding()
                                        .background(Color.blue)
                                        .clipShape(Capsule())
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                            }
                            .alert(isPresented:$orderWarn){
                                Alert(title: Text("Order Status"), message: Text("Order placed!"), dismissButton: .default(Text("OK")))
                            }
                            
                        }
                    }.listStyle(GroupedListStyle())
                } else {
                    // if no items in the order then suggest the user add items
                    Text("Add some items to your cart!")
                }
                
            }.padding(.top)
            .navigationBarTitle("Checkout")
            .navigationBarItems(trailing: EditButton())
            
        }
        
        .onAppear(){
            // Check the status of the users cart when view appears
            print("View appeard, items in cart: \(self.order.items.count)")
            if self.order.items.count > 0 {
                itemsInCart = true
            } else {
                itemsInCart = false
            }
        }
    }
    
    
    
    func delete(at offsets: IndexSet) {
        order.items.remove(atOffsets: offsets)
        print("Items in cart: \(self.order.items.count)")
        if self.order.items.count == 0 {
            // If cart is now empty then hide checkout view and show notice
            itemsInCart = false
            print("Cart now empty")
        }
    }
    
    func placeOrder(){
        let db = Firestore.firestore()
        uploadOrder(dbRef: db.collection("restaurants").document(self.order.restaurant!.id).collection("orders"))
        if session.session != nil {
            print("User is logged in")
            uploadOrder(dbRef: db.collection("users").document(session.session!.uid).collection("orders"))
        }
        self.orderWarn.toggle()
    }
    
    func uploadOrder(dbRef: CollectionReference){
        
        var orderRef: DocumentReference? = nil
        
        orderRef = dbRef.addDocument(data: [
            "restaurantName" : order.restaurant!.name as String,
            "dateTime" : order.orderTime! as Date,
            "tableNumber" : tableNumber as Int,
        ]) {
            err in
            if let err = err {
                print("Error adding order: \(err)")
            } else {
                print("Order added with ID: \(orderRef!.documentID)")
                for item in self.order.items{
                    var itemRef : DocumentReference? = nil
                    itemRef = dbRef.document(orderRef!.documentID).collection("items").addDocument(data :[
                        "name" : item.item.name,
                        "quantity" : item.quantity,
                        "price" : item.item.price,
                        "notes" : item.notes,
//                        "extras" : item.extras.map{$0.name}
                    ]) { err in
                        if let err = err {
                            print("Error adding item: \(err)")
                        } else {
                            print("Item added with ID: \(itemRef!.documentID)")
                            for extra in item.extras{
                                var extraRef : DocumentReference? = nil
                                extraRef = dbRef.document(orderRef!.documentID).collection("items").document(itemRef!.documentID).collection("extras").addDocument(data :[
                                    "name" : extra.name,
                                    "price" : extra.price
                                ]) {
                                    err in
                                    if let err = err {
                                        print("Error adding extra: \(err)")
                                    } else {
                                        print("Extra added with ID: \(extraRef!.documentID)")
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
        }
    }
    
}

struct OrderView_Previews: PreviewProvider {
    static var previews: some View {
        //OrderView(order : PresentableOrder(name: "Placeholder"))
        OrderView()
    }
}
