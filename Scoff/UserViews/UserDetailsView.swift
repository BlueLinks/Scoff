//
//  UserDetailsView.swift
//  Scoff
//
//  Created by Scott Brown on 03/01/2021.
//

import SwiftUI

struct UserDetailsView: View {
    
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        VStack{
            Form{
                if  let user = session.session{
                    Text("\(user.firstName!)")
                    Text("\(user.lastName!)")
                    Text("\(user.email!)")
                    Text("\(user.dateOfBirth!)")
                }

            }
        }
    }
}

struct UserDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        UserDetailsView()
    }
}
