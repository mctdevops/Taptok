//
//  AccountSettings.swift
//  TaptopDev
//
//  Created by Mehul Nahar on 27/07/22.
//

import SwiftUI
import WebKit

struct AccountSettings: View {
    @EnvironmentObject var manager: TaptokDataManager
    @StateObject var model = WebViewModel(requestURL: AppConfig.AccountSetting)
    @State private var isHidebottombar = false

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View {
        
        ZStack {
            VStack {
                Button(action: {
                    if isHidebottombar {
                        self.model.loadUrl(Method: "GET", contactID: nil)
                    } else {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Group {
                        Spacer().frame(width: 0, height: 36.0, alignment: .topLeading)
                        HStack {
                            Image("iconBack")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.black)
                                .padding(.leading, 30.0)
                            Spacer()
                        }
                        
                    }
                    
                }
                WebView(webView: model.webView, viewModel: model)
               
            }
            VStack{
                Spacer()
                CustomTabBarView()
                    .opacity(isHidebottombar ? 0 : 1)
            }.ignoresSafeArea()
            
        }.onAppear(){
        
            NotificationCenter.default.addObserver(forName: NSNotification.Name("settingsTapped"), object: nil, queue: nil) { notification in
                self.presentationMode.wrappedValue.dismiss()
            }
            NotificationCenter.default.addObserver(forName: NSNotification.Name("hideBottomBar"), object: nil, queue: nil) { notification in
               isHidebottombar = true
            }
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name("showBottomBar"), object: nil, queue: nil) { notification in
                isHidebottombar = false
            }
        }.onDisappear(){
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("settingsTapped"), object: nil)
        }
     
        
    }
}

struct AccountSettings_Previews: PreviewProvider {
    static var previews: some View {
        AccountSettings() .environmentObject(TaptokDataManager())
    }
}
