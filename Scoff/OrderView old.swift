//
//  OrderView.swift
//  Scoff
//
//  Created by Scott Brown on 11/11/2020.
//

import SwiftUI
import Stripe

struct OrderView: View {
    
    @EnvironmentObject var settings: Order
    
    // STPCustomerContext retireves and updates a Stripe Customer using an ephemral key
    let customerContext = STPCustomerContext(keyProvider: MyAPIClient())
    
    init(){
        self.paymentContext = STPPaymentContext(customerContext: customerContext)
        super.init(nibName: nil, bundle: nil)
        self.paymentContext.delegate = self
        self.paymentContext.hostViewController = self
        self.paymentContext.paymentAmount = 5000 // This is in cents, i.e. $50 USD
    }
    
    

    
    
    var body: some View {
        NavigationView{
            VStack{
                List{
                    ForEach(self.settings.items){ items in
                        VStack(alignment: .leading, spacing: 5){
                            HStack{
                                Text("\(items.quantity) * \(items.item.name)")
                                Spacer()
                                Text("£\(items.item.price, specifier: "%.2f")")
                            }
                            if (items.extras.count > 0){
                                ForEach(items.extras){extra in
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
                    .onDelete(perform: delete)
                    .padding(.trailing)
                    .padding(.leading)
                }
                Text("\(self.settings.total, specifier: "%.2f")")
            }.navigationTitle("Checkout")
            .navigationBarItems(trailing: EditButton())
        }
    }
    
    func addToTotal(num1 : Double, num2 : Double) -> Double{
        return num1 + num2
    }
    
    func delete(at offsets: IndexSet) {
        settings.items.remove(atOffsets: offsets)
    }
    
}

struct OrderView_Previews: PreviewProvider {
    static var previews: some View {
        //OrderView(order : PresentableOrder(name: "Placeholder"))
        OrderView()
    }
}
