//
//  ReceiptsView.swift
//  Scoff
//
//  Created by Scott Brown on 03/01/2021.
//

import SwiftUI
import Firebase

struct receiptExtra : Identifiable {
    var id = UUID()
    var name : String
    var price : Double
    
    init(name : String, price : Double){
        self.name = name
        self.price = price
    }
}

struct receiptItem : Identifiable {
    var id = UUID()
    var name: String
    var price : Double
    var extras : [receiptExtra]
    
    init(name : String, price : Double, extras : [receiptExtra]){
        self.name = name
        self.price = price
        self.extras = extras
    }
    
}


struct receipt : Identifiable {
    var id = UUID()
    var restaurantName : String = ""
    var tableNumber : Int = 0
    var dateTime : Date = Date()
    var items : [receiptItem]
    
    init(restaurantName : String, tableNumber : Int, dateTime : Date, items : [receiptItem]){
        self.restaurantName = restaurantName
        self.tableNumber = tableNumber
        self.dateTime = dateTime
        self.items = items
    }
}

class ReceiptViewModel : ObservableObject {
    @Published var receipts = [receipt]()
    
    @EnvironmentObject var session: SessionStore
    private var db = Firestore.firestore()
    
    private var lastReceipt : DocumentSnapshot? = nil
    
    
    func getPastOrders(user : User){
        
        // Create dispatch group for each receipt
        let orderGroup = DispatchGroup()
        
        var orderRef = db.collection("users").document(user.uid).collection("orders").order(by: "dateTime")
        
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
                                    // create new extra
                                    let newExtra = receiptExtra(name: extraToBeAdded.get("name") as! String, price: extraToBeAdded.get("price") as! Double)
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
                                let newItem = receiptItem(name: itemToBeAdded.get("name") as! String, price: itemToBeAdded.get("price") as! Double, extras: listOfExtras)
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
                            let newReceipt = receipt(restaurantName: receiptToBeAdded["restaurantName"] as! String, tableNumber: receiptToBeAdded["tableNumber"] as! Int, dateTime: (receiptToBeAdded["dateTime"] as! Timestamp).dateValue(), items: listOfItems)
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
                
                self.lastReceipt = lastSnapshot
                
                
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
                Section(header: Text(receipt.restaurantName)){
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
                }
            }
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
            if firstLoad {
                if let user = session.session{
                    receiptViewModel.receipts = []
                    print("User is signed in")
                    self.receiptViewModel.getPastOrders(user : user)
                }
                self.firstLoad = false
            }
        }
    }
    
    
}

struct ReceiptsView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptsView()
    }
}
