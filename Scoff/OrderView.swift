//
//  OrderView.swift
//  Scoff
//
//  Created by Scott Brown on 11/11/2020.
//

import SwiftUI
import Stripe

struct OrderView: View {
    
    
    @EnvironmentObject var settings: Order
    
    @State private var itemsInCart : Bool = true
    
    @State private var tableNumber : Int = 0
    
    var body: some View {
        NavigationView{
            VStack{
                if itemsInCart {
                    // if items are in the cart then show the checkout
                    List{
                        Section(header: Text("Cart")){
                            ForEach(self.settings.items){ items in
                                // Show items in the order
                                VStack(alignment: .leading, spacing: 5){
                                    HStack{
                                        Text("\(items.quantity) * \(items.item.name)")
                                        Spacer()
                                        Text("£\(items.item.price, specifier: "%.2f")")
                                    }
                                    if (items.extras.count > 0){
                                        // Show the extras that have been added to item
                                        ForEach(items.extras){extra in
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
                                    if (items.notes != ""){
                                        HStack{
                                        Text("Notes:")
                                            Text("\(items.notes)").foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                            .onDelete(perform: delete)
                        }
                        Section{
                            
                            HStack{
                                Picker(selection : $tableNumber, label : Text("Please select your table number")){
                                    ForEach(0 ..< 30){ number in
                                        Text("Table \(number)")
                                    }
                                }
                            }
                            HStack{
                                // Show total price
                                Text("Total")
                                Spacer()
                                Text("£\(self.settings.total, specifier: "%.2f")")
                            }
                            
                            Button(action : {
                                //Checkout button
                                print("Checkout button pressed")
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
                        }
                    }.listStyle(GroupedListStyle())
                } else {
                    // if no items in the order then suggest the user add items
                    Text("Add some items to your cart!")
                }
                
            }
            .navigationBarTitle("Checkout")
            .navigationBarItems(trailing: EditButton())
            
        }
        
        .onAppear(){
            // Check the status of the users cart when view appears
            print("View appeard, items in cart: \(self.settings.items.count)")
            if self.settings.items.count > 0 {
                itemsInCart = true
            } else {
                itemsInCart = false
            }
        }
    }
    
    
    
    func delete(at offsets: IndexSet) {
        settings.items.remove(atOffsets: offsets)
        print("Items in cart: \(self.settings.items.count)")
        if self.settings.items.count == 0 {
            // If cart is now empty then hide checkout view and show notice
            itemsInCart = false
            print("Cart now empty")
        }
    }
    
}

struct OrderView_Previews: PreviewProvider {
    static var previews: some View {
        //OrderView(order : PresentableOrder(name: "Placeholder"))
        OrderView()
    }
}
