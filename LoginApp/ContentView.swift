//
//  ContentView.swift
//  LoginApp
//
//  Created by Samir Castro on 7/11/22.
//

import SwiftUI


struct ContentView: View {
    @StateObject private var manager = TaptokDataManager()
    
    var body: some View {
        NavigationView {
        VStack {
            if UserDefaults.standard.string(forKey: "LOGIN") == "YES"{
                
                DashboardContentView().environmentObject(TaptokDataManager())
            }else {
                SignInScreenView().environmentObject(TaptokDataManager())
            }
           
        }
        
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(TaptokDataManager())
    }
}

struct PrimaryButton: View {
    var title: String
    var body: some View {
        Text(title)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color("GreenColor"))
            .cornerRadius(50)
    }
}




