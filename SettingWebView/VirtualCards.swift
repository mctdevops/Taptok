//
//  VirtualCards.swift
//  TaptopDev
//
//  Created by Mehul Nahar on 20/07/22.
//

import SwiftUI
import WebKit
import SafariServices
import Contacts
import ContactsUI

struct VirtualCards: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @State private var showLoadingView: Bool = false
    @EnvironmentObject var manager: TaptokDataManager
    @StateObject var model = WebViewModel(requestURL: AppConfig.VirtualCards)
    @State private var isHidebottombar = false
    @State private var showSafari = false
    @State private var safariURL : URL? = nil
    @State private var isShowMessageController = false
    @State private var vcfLink = ""
    @State private var vcffileData : Data?
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
            CardLoadingView(isLoading: $showLoadingView)
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
            NotificationCenter.default.addObserver(forName: NSNotification.Name("showSafari"), object: nil, queue: nil) { notification in
                let notificationURL = notification.object as? URL
                safariURL = notificationURL
                showSafari = true
    
            }
            NotificationCenter.default.addObserver(forName: NSNotification.Name("ShowMessageController"), object: nil, queue: nil) { notification in
                vcfLink = notification.object as! String
                showLoadingView = true
                downloadAttachment()
            }

        }.onDisappear(){
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("settingsTapped"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("showSafari"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("ShowMessageController"), object: nil)

        }

        .sheet(isPresented: $showSafari) {
            if safariURL != nil {
                SFSafariViewWrapper(url:safariURL!)
            }
        }
        
        .sheet(isPresented: $isShowMessageController) {
            if vcffileData != nil {
                let contact = try? CNContactVCardSerialization.contacts(with: vcffileData!)
                let contactUrl = shareContacts(contacts: contact, data: vcffileData!)
                ActivityViewController(activityItems: [contactUrl as Any])

            }
        }
        
    }
    
    
    func downloadAttachment(){
        if vcfLink != "" {
            let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationFileUrl = documentsUrl.appendingPathComponent("downloadedFile.vcf")
            
            //Create URL to the source file you want to download
            let fileURL = URL(string: vcfLink)
         
            let session = URLSession.shared
            let task = session.dataTask(with: fileURL!) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                if let data = data {
                    vcffileData = data
                    isShowMessageController = true
                    showLoadingView = false
                }
            }
            task.resume()
            
        }
    }
    func shareContacts(contacts: [CNContact]?) -> URL? {
        if contacts != nil {
            guard let directoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
                return nil
            }

            var filename = NSUUID().uuidString

            // Create a human friendly file name if sharing a single contact.
            if let contact = contacts!.first, contacts!.count == 1 {

                if let fullname = CNContactFormatter().string(from: contact) {
                    filename = fullname.components(separatedBy: " ").joined(separator: "")//componentsSeparatedByString(" ").joinWithSeparator("")
                }
            }

            let fileURL = directoryURL.appendingPathComponent(filename).appendingPathExtension("vcf")

            do {
                let data = try CNContactVCardSerialization.data(with: contacts!)
                
               // print("filename: \(filename)")
                //print("contact: \(String(describing: String(data: data, encoding: .utf8)))")
                do {
                    try data.write(to: fileURL)//writeToURL(fileURL, options: [.AtomicWrite])
                }
                catch {
                   // print("writing contact failed")
                    return nil
                }
            }
            catch {
                //print("data conversion failed")
                return nil
            }
           // print(fileURL)
           return fileURL
        }
       return nil
    }
    
    func shareContacts(contacts: [CNContact]?, data : Data) -> URL? {
        if contacts != nil {
            guard let directoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
                return nil
            }

            var filename = NSUUID().uuidString

            // Create a human friendly file name if sharing a single contact.
            if let contact = contacts!.first, contacts!.count == 1 {

                if let fullname = CNContactFormatter().string(from: contact) {
                    filename = fullname.components(separatedBy: " ").joined(separator: "")//componentsSeparatedByString(" ").joinWithSeparator("")
                }
            }

            let fileURL = directoryURL.appendingPathComponent(filename).appendingPathExtension("vcf")

            do {
             //   let data = try CNContactVCardSerialization.data(with: contacts!)
                
               // print("filename: \(filename)")
               // print("contact: \(String(describing: String(data: data, encoding: .utf8)))")
                do {
                    try data.write(to: fileURL)//writeToURL(fileURL, options: [.AtomicWrite])
                }
                catch {
                    print("writing contact failed")
                    return nil
                }
            }
            catch {
                print("data conversion failed")
                return nil
            }
            //print(fileURL)
           return fileURL
        }
       return nil
    }
}

struct VirtualCards_Previews: PreviewProvider {
    static var previews: some View {
        VirtualCards().environmentObject(TaptokDataManager())
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
