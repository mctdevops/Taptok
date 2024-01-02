//
//  MyPhysicalProducts.swift
//  TaptopDev
//
//  Created by Mehul Nahar on 20/07/22.
//

import SwiftUI
import WebKit
import UIKit

struct MyPhysicalProducts: View {
    
    @EnvironmentObject var manager: TaptokDataManager
    @StateObject var model = WebViewModel(requestURL: AppConfig.MyPhysicalProducts)
    @State private var isHidebottombar = false
    @State private var isShowMessageController = false
    @State private var vcfLink = ""
    @State private var showLoadingView: Bool = false
   // @State private var vcffileData : Data?
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
                
                
            }//.padding([.leading, .trailing])//.ignoresSafeArea()
            VStack{
                Spacer()
                CustomTabBarView()
                    .opacity(isHidebottombar ? 0 : 1)
                //  .disabled(isHidebottombar)
            }.ignoresSafeArea()
            
        }.sheet(isPresented: $isShowMessageController){
            if vcfLink != "" {
                ActivityViewController(activityItems: [URL(string: vcfLink)!])
            }
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
                isShowMessageController = true
            }
            
            
        }.onDisappear(){
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("settingsTapped"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("showBottomBar"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("hideBottomBar"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("ShowMiniPageMessageController"), object: nil)
            
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
                  //  vcffileData = data
                   
                    isShowMessageController = true
                   
                    //print(">>>>\(data)")
                    
                    // let json = JSON(data: data)
                }
            }
            
            task.resume()
            
        }
    }
    
    
}

struct MyPhysicalProducts_Previews: PreviewProvider {
    static var previews: some View {
        MyPhysicalProducts().environmentObject(TaptokDataManager())
    }
}

struct ViewControllerHolder {
    weak var value: UIViewController?
}

struct ViewControllerKey: EnvironmentKey {
    static var defaultValue: ViewControllerHolder {
        return ViewControllerHolder(value: UIApplication.shared.windows.first?.rootViewController)

    }
}

extension UIViewController {
    func present<Content: View>(style: UIModalPresentationStyle = .automatic, @ViewBuilder builder: () -> Content) {
        let toPresent = UIHostingController(rootView: AnyView(EmptyView()))
        toPresent.modalPresentationStyle = style
        toPresent.rootView = AnyView(
            builder()
                .environment(\.viewController, toPresent)
        )
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "dismissModal"), object: nil, queue: nil) { [weak toPresent] _ in
            toPresent?.dismiss(animated: true, completion: nil)
        }
        self.present(toPresent, animated: true, completion: nil)
    }
}

extension EnvironmentValues {
    var viewController: UIViewController? {
        get { return self[ViewControllerKey.self].value }
        set { self[ViewControllerKey.self].value = newValue }
    }
}
struct ActivityViewController: UIViewControllerRepresentable {

    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        controller.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            print(activityType as Any)
        self.presentationMode.wrappedValue.dismiss()
            
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {
        
    }

}
