//
//  MenuCreationView.swift
//  Scoff
//
//  Created by Scott Brown on 04/01/2021.
//

import SwiftUI
import Firebase

let db = Firestore.firestore()

// Sheet displayed when user wishes to add new menu
struct addNewMenuSheet: View {
    
    @EnvironmentObject var session: SessionStore
    @Binding var data: [menuRaw]
    @Binding var isPresented: Bool
    @State var name : String = ""
    @State var description = ""
    
    var body: some View{
        NavigationView{
            Form{
                TextField("Enter name for menu:", text: $name)
                TextField("Enter description for menu:", text: $description)
                Button(action: {
                    addMenu(name: name)
                    
                }){
                    HStack{
                        Image(systemName: "plus.circle")
                        Text("Add menu")
                    }.foregroundColor(.blue)
                }
            }
            .navigationTitle("Add new menu")
            .navigationBarItems(trailing: Button(action: {
                isPresented = false
            }) {
                Text("Canel").bold()
            })
        }
    }
    
    func addMenu(name: String){
        // attempt to add new menu
        if let user = session.session{
            var ref: DocumentReference? = nil
            // add new document to firebase for menu
            ref = db.collection("restaurants").document(user.restaurantID!).collection("menus").addDocument(data: [
                "name" : name,
                "description" : description
            ]) {
                err in
                if let err = err {
                    print("Error adding menu: \(err)")
                } else {
                    // menu upload success
                    print("Menu added with ID: \(ref!.documentID)")
                    // append this menu to data to display
                    data.append(menuRaw(id: ref!.documentID, name: name, description: description))
                    self.isPresented = false
                }
            }
        }
    }
    
}

struct MenuCreationView: View {
    
    @EnvironmentObject var session: SessionStore
    @State var data : [menuRaw] = []
    @State var showingAddMenu = false

    @State var deleteWarning = false
    @State private var toBeDeleted: IndexSet?
    @State private var nameToBeDeleted : String?
    
    var body: some View {
        
        Form{
            ForEach(self.data){ menu in
                // show current menus
                NavigationLink(destination: MenuEditView(menu: menu)){
                    Text("\(menu.name)")
                }
            }.onDelete(perform: deleteMenu)
            // Button for adding new menus
            Button(action: {
                showingAddMenu = true
            }){
                HStack{
                    Image(systemName: "plus.circle")
                    Text("Add menu")
                }.foregroundColor(.blue)
            }.sheet(isPresented: $showingAddMenu){
                // Show add menu sheet
                addNewMenuSheet(data: $data, isPresented: self.$showingAddMenu)
            }
            // place edit button in navigation bar for menu deletion
            .navigationBarItems(trailing: EditButton())
            .navigationBarTitle("Edit Menus", displayMode: .inline)
        }.alert(isPresented:$deleteWarning){
            // display warning to ensure user wishes to delete
            Alert(title: Text("Delete"), message: Text("Are you sure you want to delete \(nameToBeDeleted!)? This wil delete this menu along with all it's items and their extras."), primaryButton: .destructive(Text("Delete")){
                // User wishes to delete
                for row in self.toBeDeleted!{
                    if let user = session.session{
                        // delet menu in firebase
                        db.collection("restaurants").document(user.restaurantID!).collection("menus").document(self.data[row].id).delete { err in
                            if let err = err {
                                print("Error removing menu: \(err)")
                            } else {
                                print("Menu successfully removed!")
                            }
                        }
                    }
                    // delete menu in data array at its index
                    print("Deleting", self.data[row].name)
                }
                data.remove(atOffsets: self.toBeDeleted!)
                self.toBeDeleted = nil

            }, secondaryButton: .cancel(){
                self.toBeDeleted = nil
            }
            )
        }
        
        .onAppear(perform: {
            self.data = []
            getMenus()
        })
    }
    
    func deleteMenu(at offsets: IndexSet) {
        // delete menu
        for row in offsets{
            // Get name of menu to show in alert
            self.nameToBeDeleted = self.data[row].name
        }
        self.toBeDeleted = offsets
        // Show warning alert
        self.deleteWarning = true
    }
    
    func getMenus() {
        // get Menu documents
        if let user = session.session{
            db.collection("restaurants").document(user.restaurantID!).collection("menus").getDocuments { (menuList, err) in
                
                
                if err != nil{
                    print((err?.localizedDescription)!)
                    return
                }
                
                // Loop through items in retrieved menus
                for newMenu in menuList!.documents{
                    
                    // construct new menu
                    let menu = menuRaw(id: newMenu.documentID, name: newMenu.get("name") as! String, description: newMenu.get("description") as! String)
                    
                    // append new menu to list of menus
                    self.data.append(menu)
                    
                }
            }
        }
    }
    
    
}

struct MenuCreationView_Previews: PreviewProvider {
    static var previews: some View {
        MenuCreationView()
    }
}
