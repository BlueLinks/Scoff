//
//  MenuCreationView.swift
//  Scoff
//
//  Created by Scott Brown on 04/01/2021.
//

import SwiftUI
import Firebase

let db = Firestore.firestore()

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
        if let user = session.session{
            var ref: DocumentReference? = nil
            ref = db.collection("restaurants").document(user.restaurantID!).collection("menus").addDocument(data: [
                "name" : name,
                "description" : description
            ]) {
                err in
                if let err = err {
                    print("Error adding menu: \(err)")
                } else {
                    print("Menu added with ID: \(ref!.documentID)")
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
                addNewMenuSheet(data: $data, isPresented: self.$showingAddMenu)
            }
            
            .navigationBarItems(trailing: EditButton())
            .navigationBarTitle("Edit Menus", displayMode: .inline)
        }.alert(isPresented:$deleteWarning){
            Alert(title: Text("Delete"), message: Text("Are you sure you want to delete \(nameToBeDeleted!)? This wil delete this menu along with all it's items and their extras."), primaryButton: .destructive(Text("Delete")){
                for row in self.toBeDeleted!{
                    print("Deleting", self.data[row].name)
                    if let user = session.session{
                        db.collection("restaurants").document(user.restaurantID!).collection("menus").document(self.data[row].id).delete { err in
                            if let err = err {
                                print("Error removing menu: \(err)")
                            } else {
                                print("Menu successfully removed!")
                            }
                        }
                    }
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
        for row in offsets{
            self.nameToBeDeleted = self.data[row].name
        }
        self.toBeDeleted = offsets
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
