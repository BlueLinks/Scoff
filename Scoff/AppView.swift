//
//  AppView.swift
//  Scoff
//
//  Created by Scott Brown on 11/11/2020.
//

import SwiftUI

struct AppView: View {
    private var badgePosition: CGFloat = 2
    private var tabsCount: CGFloat = 3
    @EnvironmentObject var order : Order
    
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading){
                
                TabView {
                    
                    // View of ordering
                    RestaurantView()
                        .tabItem {
                            Image(systemName: "magnifyingglass")
                            Text("Menu")
                        }
                    
                    // View for displaying current order and checkout
                    //ShoppingView(paymentContextDelegate: self.paymentContextDelegate)
                    OrderView()
                        .tabItem {
                            Image(systemName: "cart")
                            Text("Order")
                        }
                    // View for account settings
                    UserView()
                        .tabItem {
                            Image(systemName: "person")
                            Text("User")
                        }
                }.edgesIgnoringSafeArea(.top)
                // Check if order contains any items
                if (order.items.count > 0){
                    // if so then display red badge on order tab icon with number of items
                    ZStack {
                        Circle()
                            .foregroundColor(.red)
                        
                        Text("\(order.items.count)")
                            .foregroundColor(.white)
                            .font(Font.system(size: 12))
                    }                .frame(width: 15, height: 15)
                    .offset(x: ( ( 2 * self.badgePosition) - 0.95 ) * ( geometry.size.width / ( 2 * self.tabsCount ) ) + 2, y: -30)
                    .opacity(1.0)
                }
                
            }
        }.onAppear(perform: self.session.listen)
    }
    
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
