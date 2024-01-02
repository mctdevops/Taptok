//
//  HeaderProfileView.swift
//  SwiftUI_Experiment
//
//  Created by Patrick Mifsud on 13/6/19.
//  Copyright © 2019 Patrick Mifsud. All rights reserved.
//

import SwiftUI


struct Header: View {
    @AppStorage("rValue") var rValue = 17.0
    @AppStorage("gValue") var gValue = 37.0
    @AppStorage("bValue") var bValue = 74.0
    
    var body: some View {
        ZStack{
            Image("Circle Logo")
             .position(x: 100, y: 40)
            Spacer(minLength: 60)

        }.padding(.bottom, 110)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("App_BlueColor"))
 
    }
}


struct HeaderImage: View {
    @AppStorage("rValue") var rValue = 17.0
    @AppStorage("gValue") var gValue = 37.0
    @AppStorage("bValue") var bValue = 74.0
    
    var body: some View {
       
            
            VStack(spacing: 0) {
                
        
                
                let defaults = UserDefaults.standard
                let avatar = defaults.string(forKey: "avatar")!
                AsyncImage(url: URL(string: "\(AppConfig.DevURL)\(avatar)")) { image in
                    image.resizable()
                        .clipShape(Circle())
                        .foregroundColor(Color(red:17.0/255.0, green:37.0/255.0, blue:74.0/255.0))
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 130, maxHeight: 130)
                  
                    
                } placeholder: {
                    Image("user_115x108")
                        .clipShape(Circle())
                        .foregroundColor(Color(red:17.0/255.0, green:37.0/255.0, blue:74.0/255.0))
                        .frame(maxWidth: 130, maxHeight: 130 )
                  
                }
               
                .overlay(Image("Right")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 30, height: 30, alignment: .center)
                    .padding(.top, 110)
                    .padding(.leading, 65)
                )
   
            }
        }
        
        
    }

