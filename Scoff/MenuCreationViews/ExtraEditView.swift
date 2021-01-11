//
//  ExtraEditView.swift
//  Scoff
//
//  Created by Scott Brown on 05/01/2021.
//

import SwiftUI

struct ExtraEditView: View {
    
    var menu : menuRaw
    var item : itemRaw
    var extra : extraRaw
    
    
    var body: some View {
        List{
            Section(header: Text("Extra Details")){
            HStack{
                Text("ID:")
                Text(extra.id).foregroundColor(.gray)
            }
            HStack{
                Text("Name:")
                Text(extra.name).foregroundColor(.gray)
            }
            HStack{
                Text("Price:")
                Text("£\(String(extra.price))").foregroundColor(.gray)
            }
            HStack{
                Text("Vegetarian?")
                Text(String(extra.vegetarian)).foregroundColor(.gray)
            }
            HStack{
                Text("Vegan?")
                Text(String(extra.vegan)).foregroundColor(.gray)
            }
            HStack{
                Text("Gluten?")
                Text(String(extra.vegan)).foregroundColor(.gray)
            }
            }
        }
        .navigationTitle(Text("\(extra.name)"))
    }
}

struct ExtraEditView_Previews: PreviewProvider {
    static var previews: some View {
        ExtraEditView(menu: menuRaw(), item: itemRaw(), extra: extraRaw())
    }
}
