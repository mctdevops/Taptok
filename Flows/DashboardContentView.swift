//
//  DashboardContentView.swift
//  PDFScanner
//
//  Created by Apps4World on 9/29/21.
//

import SwiftUI
import NotificationCenter
import Foundation
import NetworkExtension
import Contacts
import ContactsUI

/// Main dashboard with folders and scanned recent files
struct DashboardContentView: View {
    @State private var showLoadingView: Bool = false
    @EnvironmentObject var manager: TaptokDataManager
    @State var managerdata = DataPost()
    @StateObject var model = WebViewModel()
    @State private var showRedirecttoOpenContact = false
    @State private var isShowAlert = false
    @State private var alertMesssage = ""
    @State private var isHidebottombar = false
    @State var showAppClipPage = false
    @State var showAppClipURL : URL?
    @State var  model2 : WebViewModel?
    @State private var product_id: String = ""
    @Environment(\.presentationMode) var presentation
    @State private var isShowMessageController = false
    @State private var isDashController = false
    @State private var vcffileData : Data?
    @State private var vcfLink = ""
    @State private var miniPageLink = ""

    let NC = NotificationCenter.default
    // MARK: - Main rendering function
    var body: some View {
        
        ZStack {
            
            Color("BackgroundColor").ignoresSafeArea()
            /// HOME TAB
            if manager.selectedTab == .home {
               
                VStack {
                    Button(action: {
                        if isHidebottombar {
                            self.model.loadUrl(Method: "GET", contactID: nil)
                        }
                    }) {
                        Group {
                            Spacer().frame(width: 0, height: isHidebottombar ? 36.0 : 0, alignment: .topLeading)
                            HStack {
                                Image("iconBack")
                                    .resizable()
                                    .frame(width: isHidebottombar ? 24 : 0, height: isHidebottombar ? 24 : 0)
                                    .foregroundColor(.black)
                                    .padding(.leading, 30.0)
                                Spacer()
                            }
                            
                        }
                    }
                    WebView(webView: model.webView, viewModel: model)
                }
            }
           
            /// SETTINGS TAB
            if manager.selectedTab == .settings {
                
                SettingsContentView().environmentObject(manager)
                
            }
            /// Tab Bar view
            VStack {
                Spacer()
                CustomTabBarView().opacity(isHidebottombar ? 0 : 1)
            }.ignoresSafeArea()
            
            /// Folder creation overlay
            
            if model2 != nil {
                NavigationLink(destination: ShowAppClipPages().environmentObject(model2!).navigationBarHidden(true), isActive: $showAppClipPage) {
                    
                }
            }
        }.ignoresSafeArea(.keyboard)
        
        /// Handle any full screen flows
            .fullScreenCover(item: $manager.fullScreenType) { flow in
                switch flow {
                case .documentView:
                    DocumentContentView().environmentObject(manager)
                case .imageTextOCR:
                    TextRecognitionContentView()
                }
            }
        VStack{
            Spacer()
            CustomTabBarView()
                .opacity(isHidebottombar ? 0 : 1)
        }.ignoresSafeArea()
        CardLoadingView(isLoading: $showLoadingView)
        
        
        /// Show the passcode view if the passcode was setup
            .onAppear() {
          
                isHidebottombar = false
                self.NC.addObserver(forName: NSNotification.Name("open_contact_url"), object: nil, queue: nil,
                                    using: self.OpenRedirectURL)
                NC.addObserver(forName: NSNotification.Name("HomeTapped"), object: nil, queue: nil) { notification in
                    self.model.webView.load(URLRequest(url: URL(string: "\(AppConfig.DevURL)/dashboard")!))
                }
                
                NC.addObserver(forName: NSNotification.Name("hideBottomBar"), object: nil, queue: nil) { notification in
                   isHidebottombar = true
                }
                
                NC.addObserver(forName: NSNotification.Name("LoadeWebview"), object: nil, queue: nil) { notification in
                  // isHidebottombar = true
                    isHidebottombar = true
                    self.model.webView.reload()
                }
                
                NC.addObserver(forName: NSNotification.Name("showBottomBar"), object: nil, queue: nil) { notification in
                    isHidebottombar = false
                }
                NotificationCenter.default.addObserver(forName: AppConfig.URLNotification, object: nil, queue: nil, using: { notification in
                    let notificationURL = notification.object as? URL
                                showAppClipPage = true
                    showAppClipURL = notificationURL!
                    model2 = WebViewModel(requestURL: showAppClipURL!)
                    model2?.isAppClip = true
                    model2?.loadUrl(Method: "GET", contactID: nil)
                    // create another view on notification and replace
                   
                })
                NotificationCenter.default.addObserver(forName: NSNotification.Name("ShowMiniPageMessageController"), object: nil, queue: nil) { notification in
                    miniPageLink = notification.object as! String
                    isShowMessageController = true
                    // isShowMessageController = true
                }
                
                NotificationCenter.default.addObserver(forName: NSNotification.Name("ShowMessageController"), object: nil, queue: nil) { notification in
                    vcfLink = notification.object as! String
                    showLoadingView = true
                    downloadAttachment()
                }
                //ShowMessageController
                
            } .onDisappear(){
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name("ShowMiniPageMessageController"), object: nil)
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name("ShowMessageController"), object: nil)

            }
            .sheet(isPresented: $isShowMessageController){
                
                if miniPageLink != "" {
                    ActivityViewController(activityItems: [URL(string: miniPageLink)!])
                }
            }
            .sheet(isPresented: $isDashController) {
                if vcffileData != nil {
//                    let contact = try? CNContactVCardSerialization.contacts(with: vcffileData!)
//                    let contactUrl = shareContacts(contacts: contact)
                    let contact = try? CNContactVCardSerialization.contacts(with: vcffileData!)
                    let contactUrl = shareContacts(contacts: contact, data: vcffileData!)
                    ActivityViewController(activityItems: [contactUrl as Any])

                }
            }
        NavigationLink(
            destination: RedirecttoOpenContact_().navigationBarHidden(true), isActive: $showRedirecttoOpenContact) {

            }
        
        
            .navigationBarHidden(true)
            .alert(alertMesssage, isPresented: $isShowAlert) {
                Button("OK", role: .cancel) {
                    isShowAlert = false
                    alertMesssage = ""
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
                    isDashController = true
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
               // print("contact: \(String(describing: String(data: data, encoding: .utf8)))")
                do {
                    try data.write(to: fileURL)//writeToURL(fileURL, options: [.AtomicWrite])
                }
                catch {
                   // print("writing contact failed")
                    return nil
                }
            }
            catch {
                print("data conversion failed")
                return nil
            }
          //  print(fileURL)
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
                   // print("writing contact failed")
                    return nil
                }
            }
            catch {
               // print("data conversion failed")
                return nil
            }
           // print(fileURL)
           return fileURL
        }
       return nil
    }

    func OpenRedirectURL(_ notification: Notification) {
        
        if let setmessage = (notification as NSNotification).userInfo?["setmessage"] as? String {
           // print(setmessage)
            if alertMesssage == "" {
                alertMesssage = setmessage
                if  setmessage == "Successfully converted paper card"{
                    showRedirecttoOpenContact = true
                    alertMesssage = ""
                    isShowAlert = false
                }else {
                    showRedirecttoOpenContact = false
                    isShowAlert = true
                    
                }
            }
            
        }
        
    }
    
}
// MARK: - Preview UI
struct DashboardContentView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardContentView()
            .environmentObject(TaptokDataManager())
    }
}

