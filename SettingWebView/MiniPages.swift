//
//  MiniPages.swift
//  TaptopDev
//
//  Created by Mehul Nahar on 20/07/22.
//

import SwiftUI
import WebKit
import JGProgressHUD


struct MiniPages: View {
    @EnvironmentObject var manager: TaptokDataManager
    @StateObject var model = WebViewModel(requestURL: AppConfig.MiniPages)
    @State private var isHidebottombar = false

    @State private var vcfLink = ""
    @State private var isShowMessageController = false
    @State private var vcffileData : Data?
    @State private var coordinator = JGProgressHUD()
    @State private var showLoadingView: Bool = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View {
        
        ZStack {
            VStack {
                Button(action: {
                    if isHidebottombar {
                        self.model.loadUrl(Method: "GET", contactID: nil)//webView.load(URLRequest(url: AppConfig.MyPhysicalProducts))
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
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name("ShowMiniPageMessageController"), object: nil, queue: nil) { notification in
                vcfLink = notification.object as! String
                showLoadingView = true
                downloadAttachment()
                // isShowMessageController = true
            }
        }.onDisappear(){
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("ShowMiniPageMessageController"), object: nil)
        }
     
        .sheet(isPresented: $isShowMessageController){
            
            if vcfLink != "" {
                ActivityViewController(activityItems: [URL(string: vcfLink)!])
            }
        }
    }
    
    func downloadAttachment(){
        if vcfLink != "" {
            let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationFileUrl = documentsUrl.appendingPathComponent("downloadedFile.vcf")
            
            //Create URL to the source file you want to download
            let fileURL = URL(string: vcfLink)
            
            //  let sessionConfig = URLSessionConfiguration.default
            //  let session = URLSession(configuration: sessionConfig)
            let session = URLSession.shared
            let task = session.dataTask(with: fileURL!) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                if let data = data {
                    vcffileData = data
                    isShowMessageController = true
                    showLoadingView = false
                    //print(">>>>\(data)")
                    
                    // let json = JSON(data: data)
                }
            }
            task.resume()
            
        }
    }
}


struct MiniPages_Previews: PreviewProvider {
    static var previews: some View {
        
        MiniPages()
            .environmentObject(TaptokDataManager())
    }
}

