//
//  ReceiptsView.swift
//  Scoff
//
//  Created by Scott Brown on 03/01/2021.
//

import SwiftUI
import Firebase

struct receiptExtra : Identifiable {
    // Object to store extra belonging to item in receipt
    var id : String
    var name : String
    var price : Double
    
    init(id: String, name : String, price : Double){
        self.id = id
        self.name = name
        self.price = price
    }
}

struct receiptItem : Identifiable {
    // Object to store item belonging in a receipt
    var id : String
    var name: String
    var quantity : Int
    var notes : String
    var price : Double
    var totalPrice : Double
    var extras : [receiptExtra]
    
    init(id: String, name : String, quantity : Int, notes : String, price : Double, extras : [receiptExtra]){
        self.id = id
        self.name = name
        self.quantity = quantity
        self.notes = notes
        self.price = price
        self.extras = extras
        // Sum price of extras to find total price of item
        self.totalPrice = price + extras.lazy.map { $0.price}.reduce(0, +)
    }
    
}


struct receipt : Identifiable {
    // Object to store receipt
    var id : String = ""
    var restaurantName : String = ""
    var tableNumber : Int = 0
    var dateTime : Date = Date()
    var items : [receiptItem]
    var bill : Double
    
    init(id : String, restaurantName : String, tableNumber : Int, dateTime : Date, items : [receiptItem]){
        self.id = id
        self.restaurantName = restaurantName
        self.tableNumber = tableNumber
        self.dateTime = dateTime
        self.items = items
        // Sum price of items and their quantities to find total price of receipt
        self.bill = items.lazy.map { $0.totalPrice * Double($0.quantity) }.reduce(0, +)
    }
}


class ReceiptViewModel : ObservableObject {
    // Objecg used to store receipts as well as interface with firebase to retrive them
    @Published var receipts = [receipt]()
    
    @EnvironmentObject var session: SessionStore
    private var db = Firestore.firestore()
    
    var lastReceipt : DocumentSnapshot? = nil
    
    
    func getPastOrders(user : User){
        // Create dispatch group for each receipt
        let orderGroup = DispatchGroup()
        
        var orderRef = db.collection("users").document(user.uid).collection("orders").order(by: "dateTime")
        
        // Only download new receipts
        if let lastSnap = lastReceipt {
            orderRef = orderRef.start(afterDocument: lastSnap)
        }
        
        // get receipts
        orderRef.limit(to: 10).getDocuments() { (receiptList, err) in
            
            if err != nil{
                // Error in receiving receipts
                print((err?.localizedDescription)!)
                return
            }
            
            for receiptToBeAdded in receiptList!.documents{
                // Loop through all received receipts
                
                let receiptID = receiptToBeAdded.documentID
                print("--- Entering order Group for \(receiptID)")
                
                // Enter group for receipt
                orderGroup.enter()
                let extraGroup = DispatchGroup()
                let itemGroup = DispatchGroup()
                
                var listOfItems : [receiptItem] = []
                // get items in receipt
                self.db.collection("users").document(user.uid).collection("orders").document(receiptID).collection("items").getDocuments() { (itemsList, err) in
                    
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
                        self.db.collection("users").document(user.uid).collection("orders").document(receiptID).collection("items").document(itemID).collection("extras").getDocuments() { (extraList, err) in
                            
                            if err != nil{
                                // error in receiving extras
                                print((err?.localizedDescription)!)
                                extraGroup.leave()
                                return
                            }
                            
                            for extraToBeAdded in extraList!.documents{
                                let extraID = extraToBeAdded.documentID
                                
                                // create new extra
                                let newExtra = receiptExtra(id: extraID ,name: extraToBeAdded.get("name") as! String, price: extraToBeAdded.get("price") as! Double)
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
                            listOfItems.append(newItem)
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
                        let newReceipt = receipt(id: receiptID, restaurantName: receiptToBeAdded["restaurantName"] as! String, tableNumber: receiptToBeAdded["tableNumber"] as! Int, dateTime: (receiptToBeAdded["dateTime"] as! Timestamp).dateValue(), items: listOfItems)
                        
                        print("Adding new receipt from \(newReceipt.restaurantName)")
                        
                        // append receipt to self.receipts in order to create views
                        DispatchQueue.main.async {
                            self.receipts.append(newReceipt)
                        }
                    }
                }
            }
            guard let lastSnapshot = receiptList?.documents.last else {
                // The collection is empty
                return
            }
            // Record last receipt
            self.lastReceipt = lastSnapshot
        }
    }
}

struct headerView : View {
    // View to be shown atop each receipt
    var receipt : receipt
    
    var formatter : DateFormatter {
        let formatter = DateFormatter()
        // date format example 17:45, 02/01/21
        formatter.dateFormat = "HH:mm, d/MM/YY"
        return formatter
    }
    
    
    var body : some View {
        HStack{
            Text(receipt.restaurantName)

            Text("Table \(receipt.tableNumber)")
                .frame(maxWidth: .infinity)
            
            Text(formatter.string(from : receipt.dateTime))
            
        }
    }
}



struct ReceiptsView: View {
    
    @EnvironmentObject var session: SessionStore
    
    @State var receipts : [receipt] = []
    
    @ObservedObject var receiptViewModel = ReceiptViewModel()
    
    @State var firstLoad = true
    let db = Firestore.firestore()
    
    
    var body: some View {
        List{
            // Show each receipt
            ForEach(receiptViewModel.receipts) {receipt in
                // show restaurant name in section header
                Section(header: headerView(receipt : receipt)){
                    ForEach(receipt.items){item in
                        // Show item and price
                        HStack{
                            Text(item.name)
                            Spacer()
                            Text("£\(item.price, specifier: "%.2f")")
                        }
                        // check if item has any extras
                        if (item.extras.count > 0){
                            ForEach(item.extras){extra in
                                // Show each extra
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
                    }
                    HStack{
                        Text("Total: £\(receipt.bill, specifier: "%.2f")")
                    }
                }
            }
            // Button to allow a user to check for more receipts
            Button(action : {
                if let user = session.session{
                    self.receiptViewModel.getPastOrders(user : user)
                }
            }){
                Text("Get more")
            }
        }.listStyle(GroupedListStyle())
        .navigationBarTitle("Receipts")
        .onAppear(){
            // Check user is signed in and download receipts from firebase
            if let user = session.session{
                receiptViewModel.receipts = []
                print("User is signed in")
                self.receiptViewModel.lastReceipt = nil
                self.receiptViewModel.getPastOrders(user : user)
            }
            
            
        }
    }
    
    
}

struct ReceiptsView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptsView()
    }
}
