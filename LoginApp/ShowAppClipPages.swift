//
//  ShowAppClipPages.swift
//  Taptok
//
//  Created by Mehul Nahar on 18/08/22.
//

import SwiftUI
import WebKit
import SafariServices

struct ShowAppClipPages: View {
   // @EnvironmentObject var manager: TaptokDataManager
    @EnvironmentObject var model : WebViewModel
    @State private var AppclipshowSafari = false

    @State var AppclipsafariURL : URL?
    let NC = NotificationCenter.default
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        
        ZStack {
            VStack {
                Button(action: {
                    
                    self.presentationMode.wrappedValue.dismiss()

                       // self.model.loadUrl(Method: "GET", contactID: nil)//webView.load(URLRequest(url: AppConfig.MyPhysicalProducts))
                }) {
                    Group {
                        Spacer().frame(width: 0, height:  36.0 , alignment: .topLeading)
                        HStack {
                            Image("Close")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)
                                .tint(.white)
                                .padding(.leading, 30.0)
                            Spacer()
                        }
                        
                    }
                }
                WebView(webView: model.webView, viewModel: model)
            }
      //  WebView(webView: model.webView, viewModel: model)
        }
        .onAppear(){
          
            NC.addObserver(forName: NSNotification.Name("AppclipshowSafari"), object: nil, queue: nil) { notification in
                let notificationURL = notification.object as? URL
                AppclipsafariURL = notificationURL
                AppclipshowSafari = true
               // UserDefaults.standard.set(notificationURL! as URL, forKey: "appClipUrl")
                    
              //  UIApplication.shared.open(AppclipsafariURL!)
            }
           
            /* NotificationCenter.default.post(name: NSNotification.Name("showBackButton"), object: nil,userInfo: nil)
             } else {
                 NotificationCenter.default.post(name: NSNotification.Name("hideBackButton"), object: nil,userInfo: nil)*/
           
        }
        .sheet(isPresented: $AppclipshowSafari) {
//            if UserDefaults.standard.value(forKey: "appClipUrl") != nil {
//                let url = UserDefaults.standard.value(forKey: "appClipUrl") as? URL
//                SFSafariViewWrapper(url:url!)
//            }
            if AppclipsafariURL != nil {
                SFSafariViewWrapper(url:AppclipsafariURL!)
            }
        }
        .foregroundColor(.white)
    }
}

struct ShowAppClipPages_Previews: PreviewProvider {
    static var previews: some View {
        ShowAppClipPages()
    }
}
