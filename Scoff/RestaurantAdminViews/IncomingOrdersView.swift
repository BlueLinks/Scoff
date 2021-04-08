//
//  IncomingOrdersView.swift
//  Scoff
//
//  Created by Scott Brown on 18/01/2021.
//

import SwiftUI
import Firebase

// Object used to retrieve and store incoming orders
class IncomingOrderModel : ObservableObject {
    @Published var receipts = [receipt]()
    
    @EnvironmentObject var session: SessionStore
    private var db = Firestore.firestore()
    
    private var lastReceipt : DocumentSnapshot? = nil
    
    
    func getPastOrders(user : User){
        // Get previous orders and listen for new orders
        print("Attempting to download past orders for \(user.restaurantID!)")
        
        // Create dispatch group for each receipt
        let orderGroup = DispatchGroup()
        
        let orderRef = db.collection("restaurants").document(user.restaurantID!).collection("orders").order(by: "dateTime")
        
        // get receipts
        orderRef.addSnapshotListener { (receiptList, err) in
            // Begin listening
            
            if err != nil{
                // Error in receiving receipts
                print((err?.localizedDescription)!)
                return
            }
            
            receiptList?.documentChanges.forEach{ diff in
                if (diff.type == .added) {
                    
                    let receiptToBeAdded = diff.document
                    
                        // Loop through all received receipts
                        let receiptID = receiptToBeAdded.documentID
                        print("NEW RECEIPT \(receiptID)")
                        
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                        
                        print("--- Entering order Group for \(receiptID)")
                        // Enter group for receipt
                        orderGroup.enter()
                    
                        let extraGroup = DispatchGroup()
                        let itemGroup = DispatchGroup()
                        
                        var listOfItems : [receiptItem] = []
                        // get items in receipt
                        self.db.collection("restaurants").document(user.restaurantID!).collection("orders").document(receiptID).collection("items").getDocuments() { (itemsList, err) in
                            
                            if err != nil{
                                // error in receiving items
                                print((err?.localizedDescription)!)
                                return
                            }
                            
                            for itemToBeAdded in itemsList!.documents{
                                // loop through all received items
                                let itemID = itemToBeAdded.documentID
                                var listOfExtras : [receiptExtra] = []
                                
                                print("--- Entering item group for \(itemID)")
                                // Enter dispatch groups for item
                                itemGroup.enter()
                                extraGroup.enter()
                                
                                // get extras for item
                                self.db.collection("restaurants").document(user.restaurantID!).collection("orders").document(receiptID).collection("items").document(itemID).collection("extras").getDocuments() { (extraList, err) in
                                    if err != nil{
                                        // error in receiving extras
                                        print((err?.localizedDescription)!)
                                        extraGroup.leave()
                                        return
                                    }
                                    
                                    for extraToBeAdded in extraList!.documents{
                                        let extraID = extraToBeAdded.documentID
                                        // create new extra
                                        let newExtra = receiptExtra(id: extraID,name: extraToBeAdded.get("name") as! String, price: extraToBeAdded.get("price") as! Double)
                                        print("Adding new extra : \(newExtra.name)")
                                        // append to list of extras for item
                                        listOfExtras.append(newExtra)
                                    }
                                    // extra loaded so leave group
                                    extraGroup.leave()
                                }
                                extraGroup.notify(queue: DispatchQueue.global(qos: .background)) {
                                    // called when all extras are loaded for item
                                    print("Extras loaded, creating newItem")
                                    // create item with extras
                                    let newItem = receiptItem(id : itemID ,name: itemToBeAdded.get("name") as! String, quantity: itemToBeAdded.get("quantity") as! Int, notes: itemToBeAdded.get("notes") as! String, price: itemToBeAdded.get("price") as! Double, extras: listOfExtras)
                                    print("Adding new item : \(newItem.name)")
                                    if !listOfItems.lazy.map({$0.id}).contains(itemID){
                                        listOfItems.append(newItem)
                                    }
                                    
                                    print("--- Levaing item group for \(itemID)")
                                    // Item loaded so leave group
                                    itemGroup.leave()
                                }
                                
                            }
                            
                            
                            
                            itemGroup.notify(queue: DispatchQueue.global(qos: .background)) {
                                // called when item has been loaded
                                print("--- Leaving order Group for \(receiptID)")
                                orderGroup.leave()
                            }
                            orderGroup.notify(queue: DispatchQueue.global(qos: .background)) {
                                // called when all items in a receipt have been loaded
                                print("Items loaded, creating newReceipt")
                                // create new receipt
                                let newReceipt = receipt(id : receiptID,restaurantName: receiptToBeAdded["restaurantName"] as! String, tableNumber: receiptToBeAdded["tableNumber"] as! Int, dateTime: (receiptToBeAdded["dateTime"] as! Timestamp).dateValue(), items: listOfItems)
                                print("Adding new receipt from \(newReceipt.restaurantName)")
                                // append receipt to self.receipts in order to create views
                                DispatchQueue.main.async {
                                    if newReceipt.items.count > 0 {
                                        if !self.receipts.lazy.map({$0.id}).contains(receiptID){
                                            self.receipts.append(newReceipt)
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
    
}

struct IncomingOrdersView: View {
    
    @EnvironmentObject var session: SessionStore
    
    @ObservedObject var incomingOrdersViewModel = IncomingOrderModel()
    
    @State var firstLoad = true
    let db = Firestore.firestore()
    
    
    var body: some View {
        List{
            // Show each receipt
            ForEach(incomingOrdersViewModel.receipts) {receipt in
                // show restaurant name in section header
                Section(header: headerView(receipt : receipt)){
                    ForEach(receipt.items){item in
                        VStack(alignment: .leading, spacing: 5){
                            HStack{
                                Text("\(item.quantity) * \(item.name)")
                                Spacer()
                                Text("\(item.quantity) *  £\(item.price, specifier: "%.2f")")
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
                    HStack{
                        Text("Total: £\(receipt.bill, specifier: "%.2f")")
                    }
                }
            }
            Button(action : {
                // Attempt to manually check for more orders
                if let user = session.session{
                    print("Get More button pressed")
                    incomingOrdersViewModel.receipts = []
                    self.incomingOrdersViewModel.getPastOrders(user : user)
                }
            }){
                HStack{
                Text("Refresh").frame(maxWidth: .infinity)
                }
            }
        }.listStyle(GroupedListStyle())
        .navigationBarTitle("Receipts")
        .onAppear(){
            if firstLoad {
                if let user = session.session{
                    incomingOrdersViewModel.receipts = []
                    print("User is signed in")
                    // Begin listening for orders
                    self.incomingOrdersViewModel.getPastOrders(user : user)
                }
                self.firstLoad = false
            }
        }
    }
    
    
}

struct IncomingOrdersView_Previews: PreviewProvider {
    static var previews: some View {
        IncomingOrdersView()
    }
}
