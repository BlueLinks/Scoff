//
//  OrderView.swift
//  Scoff
//
//  Created by Scott Brown on 11/11/2020.
//

import SwiftUI
import Stripe
import URLImage

struct OrderView: View {
    
    
    @EnvironmentObject var order : Order
    
    @State private var itemsInCart : Bool = true
    
    @State private var tableNumberPicker : Int = 0
    
    private var tableNumber : Int {
        return tableNumberPicker + 1
    }
    
    @State private var tableWarn : Bool = false
    
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
                            ForEach(self.order.items){ items in
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
                                Picker(selection : $tableNumberPicker, label : Text("Please select your table number")){
                                    ForEach(1 ..< 30){ number in
                                        Text("Table \(number)")
                                    }
                                }
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
                            }.alert(isPresented:$tableWarn){
                                Alert(title: Text("Table Number"), message: Text("Are you sure you're at table \(tableNumber)?"), primaryButton: .destructive(Text("I'm Sure")){
                                    print("They are sure")
                                    
                                }, secondaryButton: .cancel())
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
    
}

struct OrderView_Previews: PreviewProvider {
    static var previews: some View {
        //OrderView(order : PresentableOrder(name: "Placeholder"))
        OrderView()
    }
}
