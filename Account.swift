//
//  Account.swift
//  Tickme2
//
//  Created by Matala on 2025-12-19.
//

import SwiftUI

struct Account: View {
    var body: some View {
        ZStack {
               Color(.systemMint)
                   .ignoresSafeArea()
               
               VStack {
                   Image("Background")
                  
                   
           HStack {
               Spacer()
           Text("Welcome to TickMe")
           
                   .foregroundColor(.purple)

           .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
           .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
           Image(systemName: "star.fill")
                   .font(.caption)
       .foregroundColor(.orange)
           Image(systemName: "star.fill")
                   .font(.caption)
       .foregroundColor(.orange)
           Image(systemName: "star")
           .font(.caption)
       .foregroundColor(.orange)
               Spacer()
                   }

                  
           Text("Here you can track record all your daily activities")
                   
           .foregroundColor(.black)

              
                          .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
               }
               .padding()
               .background( Rectangle()
               .foregroundColor(.white)
               .cornerRadius(15)
               .shadow(radius: 15))
           }
           
           
           VStack(alignment: .leading, spacing:50){
                    
          
                }
    }
}

#Preview {
    Account()
}
