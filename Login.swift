//
//  Login.swift
//  Tickme2
//
//  Created by Matala on 2025-12-19.
//

import SwiftUI

struct Login: View {
    @State private var username = ""
    @State private var password = ""
    @State private var wrongUsername = 0
    @State private var wrongPassword = 0
    @State private var showLoginScreen = false
     
     
     var body: some View {
         NavigationView{
             ZStack{
                 Color.green
                 .ignoresSafeArea()
                   Circle()
                     .scale(1.7)
                     .foregroundColor(.white.opacity(0.15))
                  
                 Circle()
                   .scale(1.35)
                   .foregroundColor(.white)
                  
                 VStack{
                      Text ("login")
                         .font(.largeTitle)
                         .bold()
                         .padding()
                     TextField ("Username", text: $username)
                         .padding()
                         .frame(width: 300, height: 50)
                         .background(Color.black.opacity(0.05))
                         .cornerRadius(10)
                         .border(.red, width: CGFloat(wrongUsername))
                     
                     SecureField ("Password", text: $password)
                         .padding()
                         .frame(width: 300, height: 50)
                         .background(Color.black.opacity(0.05))
                         .cornerRadius(10)
                         .border(.red, width: CGFloat(wrongPassword))
                         
                     Button("Login"){
                        // authenticate the user
                     }
                     .foregroundColor(.white)
                     .frame(width: 300, height: 50)
                     .background(Color.green)
                      
                     
                 }
             }
             .navigationBarHidden(true)
        }
          
         
    }

}

#Preview {
    Login()
}

