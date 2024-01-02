//
//  RedirecttoOpenContact .swift
//  TaptopDev
//
//  Created by Mehul Nahar on 21/07/22.
//

import SwiftUI
import WebKit

struct RedirecttoOpenContact_: View {
    
    var model = WebViewModel(requestURL: AppConfig.RedirecttoOpenContact, contactID: nil, Method: "GET")
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View {
        
        ZStack {
            VStack {
                Button(action: { self.presentationMode.wrappedValue.dismiss()
                    UserDefaults.standard.removeObject(forKey: "contact_id")
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
            
        }.onAppear(){
        
            NotificationCenter.default.addObserver(forName: NSNotification.Name("HomeTapped"), object: nil, queue: nil) { notification in
                self.presentationMode.wrappedValue.dismiss()
            }

        }.onDisappear(){
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("HomeTapped"), object: nil)
        }
     
        
    }
}


struct RedirecttoOpenContact__Previews: PreviewProvider {
    static var previews: some View {
        RedirecttoOpenContact_()
    }
}
