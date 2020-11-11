//
//  AppView.swift
//  Scoff
//
//  Created by Scott Brown on 11/11/2020.
//

import SwiftUI

struct AppView: View {
    var body: some View {
        TabView {
            RestaurantView()
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("Menu")
                }

            OrderView()
                .tabItem {
                    Image(systemName: "square.and.pencil")
                    Text("Order")
                }
            UserView()
                .tabItem {
                    Image(systemName: "person")
                    Text("User")
                }
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
