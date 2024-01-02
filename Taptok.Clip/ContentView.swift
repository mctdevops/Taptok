//
//  ContentView.swift
//  Taptok.Clip
//
//  Created by Mehul Nahar on 10/08/22.
//

import SwiftUI
import SafariServices

struct ContentView: View {
    @EnvironmentObject var model : WebViewModel
    @State private var AppclipshowSafari = false
    @State private var AppclipShowBackButton = false

    @State var AppclipsafariURL : URL?
    let NC = NotificationCenter.default

    var body: some View {
        
        ZStack {
            VStack {
                Button(action: {
                    if AppclipShowBackButton {
                        self.model.loadUrl(Method: "GET", contactID: nil)//webView.load(URLRequest(url: AppConfig.MyPhysicalProducts))
                    }
                }) {
                    Group {
                        Spacer().frame(width: 0, height: AppclipShowBackButton ? 36.0 : 0, alignment: .topLeading)
                        HStack {
                            Image("iconBack")
                                .resizable()
                                .frame(width: AppclipShowBackButton ? 24 : 0, height: AppclipShowBackButton ? 24 : 0)
                                .foregroundColor(.white)
                                .tint(.white)
                                .padding(.leading, 30.0)
                            Spacer()
                        }
                        
                    }
                }
                WebView(webView: model.webView, viewModel: model)
            }

        }.sheet(isPresented: $AppclipshowSafari) {
                        if AppclipsafariURL != nil {
                            SFSafariViewWrapper(url:AppclipsafariURL!)
                        } else  if UserDefaults.standard.value(forKey: "appClipUrl") != nil {
                            let url = UserDefaults.standard.url(forKey: "appClipUrl")
                            SFSafariViewWrapper(url:url!)
                        }
                    }
        .onAppear(){
          
            NC.addObserver(forName: NSNotification.Name("AppclipshowSafari"), object: nil, queue: nil) { notification in
                AppclipshowSafari = true
                let notificationURL = notification.object as? URL
                AppclipsafariURL = notificationURL
               // UserDefaults.standard.set(notificationURL! as URL, forKey: "appClipUrl")
                    
              //  UIApplication.shared.open(AppclipsafariURL!)
            }
            NC.addObserver(forName: NSNotification.Name("showBackButton"), object: nil, queue: nil) { notification in
               AppclipShowBackButton = true
            }
            
            NC.addObserver(forName: NSNotification.Name("hideBackButton"), object: nil, queue: nil) { notification in
                AppclipShowBackButton = false
            }
            let content = UNMutableNotificationContent()
            content.title = "Taptok"
            content.subtitle = "Engage With All Your Audiences Using A Single App. "
            content.sound = UNNotificationSound.default

            // show this notification five seconds from now
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)

            // choose a random identifier
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            // add our notification request
            UNUserNotificationCenter.current().add(request)
           
        }
        
        .foregroundColor(.white)
    }
}
struct SFSafariViewWrapper: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SFSafariViewWrapper>) {
        return
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
