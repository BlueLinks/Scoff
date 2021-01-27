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
    @State var restaurant = restaurantRaw(id: "", name: "", picture: "")
    @EnvironmentObject var session: SessionStore
    @State private var imageToDisplay: Image?
    @State private var imageSelected = false
    @State private var image : UIImage?
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var uploadProgress : Double = 0.00
    @State private var showUploadProgress = false
    
    var body: some View {
        VStack{
            Form{
                if  let user = session.session{
                    Section(header: Text("Restaurant details")){
                        Text("\(restaurant.name)")
                        Button(action: {
                            self.showingImagePicker = true
                        }){
                            VStack{
                                Text("Select image")
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
                            }
                        }
                        HStack{
                            Button(action: {
                                uploadImage()
                            }){
                                Text("Upload!")
                            }
                            Spacer()
                            if self.showUploadProgress {
                                Text("\(uploadProgress)")
                            }
                        }
                        
                    }
                    Section(header: Text("User details")){
                        Text("\(user.firstName!)")
                        Text("\(user.lastName!)")
                        Text("\(user.email!)")
                        Text("\(user.dateOfBirth!)")
                    }
                }
                
            }.sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage)
            }
        }.onAppear(perform: getData)
    }
    
    
    func getData() {
        if let user = session.session{
            db.collection("restaurants").document(user.restaurantID!).getDocument { (document, err) in
                
                if err != nil{
                    print((err?.localizedDescription)!)
                    return
                }
                
                if let restaurant = document{
                    self.restaurant =  restaurantRaw(id: restaurant.documentID, name: restaurant.get("name") as! String, picture: restaurant.get("splash_image") as! String)
                }
                
            }
        }
        
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        imageToDisplay = Image(uiImage: inputImage)
        image = inputImage
        imageSelected = true
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
            // You can also access to download URL after upload.
            splashRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print("Error Occured")
                    // Uh-oh, an error occurred!
                    return
                }
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
