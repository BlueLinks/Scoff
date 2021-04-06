//
//  RestaurantDetailsView.swift
//  Scoff
//
//  Created by Scott Brown on 04/01/2021.
//

import SwiftUI
import Firebase
import URLImage

struct RestaurantDetailsView: View {
    
    let db = Firestore.firestore()
    @State var restaurant = restaurantRaw(id: "", name: "", picture: "", email: "")
    @EnvironmentObject var session: SessionStore
    @State private var imageToDisplay: Image?
    @State private var imageSelected = false
    @State private var image : UIImage?
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var uploadProgress : Double = 0.00
    @State private var showUploadProgress = false
    @State var name : String = ""
    @State var email : String = ""
    @State var detailsChanged = false
    @State var showSaveWarn = false
    
    var body: some View {
        VStack{
            Form{
                if  session.session != nil{
                    Section(header: Text("Restaurant details")){
                        HStack{
                            Text("Name:")
                            Spacer()
                            TextField("",text: $name).onChange(of: name, perform: { (value) in
                                if !(value == restaurant.name){
                                    print("name changed to \(value)")
                                    detailsChanged = true
                                } else {
                                    detailsChanged = false
                                }
                            })
                        }
                        HStack{
                            Text("Email:")
                            Spacer()
                            TextField("",text: $email).keyboardType(/*@START_MENU_TOKEN@*/.emailAddress/*@END_MENU_TOKEN@*/).onChange(of: email, perform: { (value) in
                                if !(value == restaurant.email){
                                    print("Email changed to \(value)")
                                    detailsChanged = true
                                } else {
                                    detailsChanged = false
                                }
                            })
                        }
                        Button(action: {
                            self.showingImagePicker = true
                        }){
                            HStack{
                                Text("Select image")
                                Spacer()
                                if !imageSelected{
                                    if restaurant.picture != ""{
                                        URLImage(url: URL(string: restaurant.picture)!){ image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                        }
                                    }
                                } else {
                                    if imageToDisplay != nil {
                                        imageToDisplay?
                                            .resizable()
                                            .scaledToFit()
                                        
                                    }
                                }
                            }.frame(height: 180)
                            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                                ImagePicker(image: self.$inputImage)
                            }
                        }
                    }
                    
                }
            }
            .alert(isPresented:$showSaveWarn){
                Alert(title: Text("Save?"), message: Text("Are you sure you want to Save?"), primaryButton: .destructive(Text("Save")){
                    if imageSelected{
                        uploadImage()
                    }
                    saveChanges()
                    
                }, secondaryButton: .cancel())
            }
            // Button for saving changes
            .navigationBarItems(trailing: Button(action: {
                showSaveWarn = true
            }) {
                Text("Save").bold()
            }.disabled(!detailsChanged))
            .navigationTitle("Restaurant Details")
        }.onAppear(perform: getData)
    }
    
    
    func saveChanges(){
        print("Attempting to save changes to user details")
        if session.session != nil {
            let userRef = db.collection("restaurants").document(restaurant.id)
            userRef.updateData([
                "name" : name,
                "email" : email
            ]){ err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                    detailsChanged = false
                    restaurant.name = name
                    restaurant.email = email
                }
            }
        }
    }
    
    func getData() {
        if let user = session.session{
            db.collection("restaurants").document(user.restaurantID!).getDocument { (document, err) in
                
                if err != nil{
                    print((err?.localizedDescription)!)
                    return
                }
                
                if let restaurant = document{
                    let name = restaurant.get("name") as! String
                    let email = restaurant.get("email") as! String
                    self.restaurant =  restaurantRaw(id: restaurant.documentID, name: name, picture: restaurant.get("splash_image") as! String, email: email)
                    self.name = name
                    self.email = email
                    self.detailsChanged = false
                }
                
            }
        }
        
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        imageToDisplay = Image(uiImage: inputImage)
        image = inputImage
        imageSelected = true
        detailsChanged = true
    }
    
    func uploadImage(){
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let splashRef = storageRef.child("restaurants/\(restaurant.id)/splash.jpg")
        let localImage = image!.jpegData(compressionQuality: 0.15)
        
        let uploadTask = splashRef.putData(localImage!, metadata: nil) { (metadata, error) in
            
            
            
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                print("Error Occured")
                return
            }
            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
            print("File size: \(size)")
            // You can also access to download URL after upload.
            splashRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print("Error Occured")
                    // Uh-oh, an error occurred!
                    return
                }
                print("downloadURL: \(downloadURL)")
            }
            
        }
        
        uploadTask.observe(.resume) { snapshot in
            showUploadProgress = true
        }
        
        uploadTask.observe(.progress) { snapshot in
            // Upload reported progress
            showUploadProgress = true
            self.uploadProgress = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            print(self.uploadProgress)
        }
        
        uploadTask.observe(.success) { snapshot in
            showUploadProgress = false
            
            if let user = session.session{
                splashRef.downloadURL{( url, error) in
                    guard let downloadURL = url else {
                        print("ERROR")
                        return
                    }
                    let splashImageUrlString = downloadURL.absoluteString
                    db.collection("restaurants").document(user.restaurantID!).updateData([
                        "splash_image" : splashImageUrlString
                    ]){ err in
                        if let err = err {
                            print("Error changing splash image url of firestore document: \(err)")
                        } else {
                            print("URL successfully updated")
                            self.imageSelected = false
                        }
                    }
                    
                }
                
            }
        }
        
        
        
        
        
        
        
        
        
        
    }
    
    struct RestaurantDetailsView_Previews: PreviewProvider {
        static var previews: some View {
            RestaurantDetailsView()
        }
    }
    
    
}
