//
//  DocumentContentView.swift
//  PDFScanner
//
//  Created by Apps4World on 10/2/21.
//

import SwiftUI

/// Main document viewer with images from scanned items
struct DocumentContentView: View {
    
    @EnvironmentObject var manager: TaptokDataManager
    @Environment(\.presentationMode) var presentation
    @State private var didShowAds: Bool = false
    @State private var showLoadingView: Bool = false
    @State private var selectedIndex: Int = 0
    @State private var showRedirecttoOpenContact = false
    @State private var isAlert = false
    @State private var setmessage = ""
    
    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            VStack(spacing: 10) {
                /// Header view
                HeaderTitleView
                
                /// Scanned item preview
                CurrentDocumentPagePreview
                
                /// List of scanned pages
                Divider().padding(.top)
                DocumentPagesScrollView
                
                /// Bottom actions tab bar
                CustomBottomTabBarView
            }
            
            /// Show loading view while deleting/saving document
            LoadingView(isLoading: $showLoadingView)
            
        }
        
        
        /// Register the data manager as environment object
        .environmentObject(manager)
        /// Show ads after the document preview appears
        .onAppear() {
            if didShowAds == false {
                didShowAds = true
            }
            
        }.onDisappear(perform: {
           // print("ContentView disappeared!")
            if UserDefaults.standard.string(forKey: "IsOpenVC") == "YES"{
                UserDefaults.standard.set("NO", forKey: "IsOpenVC")
                
                NotificationCenter.default.post(name: NSNotification.Name("open_contact_url"), object: nil,userInfo: ["setmessage" : setmessage])
            }else {
               // print("Set Nor")
                UserDefaults.standard.set("NO", forKey: "IsOpenVC")
            }
        })
         
    }
    
    /// Header title view
    private var HeaderTitleView: some View {
        HStack {
            Text("\(manager.documentPreviewMode ? "" : "Convert ")Paper Card").bold().font(.largeTitle)
            Spacer()
            if manager.documentPreviewMode {
                Button {
                    UIImpactFeedbackGenerator().impactOccurred()
                    presentation.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 25, weight: .bold))
                }
            }
            
        }
        .padding(.top).padding([.leading, .trailing])
        .foregroundColor(Color("ExtraDarkGrayColor"))
        
    }
    
    /// Document image preview
    private var CurrentDocumentPagePreview: some View {
        let previewHeight = UIScreen.main.bounds.height/2
        return HStack {
            Spacer()
            GeometryReader { _ in
                Image(uiImage: manager.scannedImagesArray[selectedIndex])
                    .resizable().aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.width - 40)
                    .contentShape(Rectangle()).clipShape(Rectangle())
                    .shadow(color: Color.black.opacity(0.2), radius: 5)
            }
            .frame(width: UIScreen.main.bounds.width - 40)
            .frame(height: previewHeight)
            Spacer()
        }.padding(.top)
    }
    
    /// Pages scroll view
    private var DocumentPagesScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false, content: {
            HStack(spacing: 25) {
                Spacer(minLength: 1)
                ForEach(0..<manager.scannedImagesArray.count, id: \.self) { id in
                    Image(uiImage: manager.scannedImagesArray[id])
                        .resizable().aspectRatio(contentMode: .fill)
                        .frame(width: 70, height: 90, alignment: .center)
                        .overlay(
                            ZStack {
                                if id == selectedIndex {
                                    Rectangle().stroke(Color.accentColor, lineWidth: 3)
                                }
                            }
                        )
                        .contentShape(Rectangle()).clipShape(Rectangle())
                        .overlay(
                            ZStack {
                                if manager.documentPreviewMode == false {
                                    DeletePageButton(atIndex: id)
                                }
                            }
                        ).onTapGesture {
                            selectedIndex = id
                        }
                }.frame(height: 110)
                Spacer(minLength: 1)
            }
        }).frame(height: 110)
    }
    
    /// Delete page button
    private func DeletePageButton(atIndex index: Int) -> some View {
        HStack {
            Spacer()
            VStack {
                Image(systemName: "xmark.circle.fill")
                    .background(Circle().foregroundColor(.white))
                    .foregroundColor(.black).font(.system(size: 22))
                    .onTapGesture {
                        UIImpactFeedbackGenerator().impactOccurred()
                        if manager.scannedImagesArray.count == 1 {
                            presentation.wrappedValue.dismiss()
                        } else {
                            if selectedIndex > 0 { selectedIndex -= 1 }
                            manager.deleteScannedFile(manager.scannedImagesArray[index])
                        }
                    }
                Spacer()
            }
        }.offset(x: 10, y: -10)
    }
    
    /// Bottom tab bar view
    private var CustomBottomTabBarView: some View {
        VStack {
            Spacer()
            ZStack {
                Rectangle().foregroundColor(Color("LightColor")).ignoresSafeArea()
                    .shadow(color: Color.black.opacity(0.2), radius: 5)
                HStack(spacing: 20) {
                    ActionButton(title: manager.documentPreviewMode ? "Delete" : "Cancel", color: .red) {
                        if manager.documentPreviewMode {
                            presentAlert(title: "Delete Document", message: "Are you sure you want to delete this document?", primaryAction: UIAlertAction(title: "Cancel", style: .cancel, handler: nil), secondaryAction: UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                                showLoadingView = true
                                manager.deleteDocument {
                                    showLoadingView = false
                                    presentation.wrappedValue.dismiss()
                                }
                            }))
                        } else {
                            presentation.wrappedValue.dismiss()
                        }
                    }
                    /// Show save button for pdf builder right after scanning
                    if manager.documentPreviewMode == false {
                        ActionButton(title: "Convert", color: .accentColor) {
                            showLoadingView = true
                            manager.saveDocument {contactId, message in
                                showLoadingView = false
                                if contactId != nil{
                                    UserDefaults.standard.set(contactId, forKey: "contact_id")
                                    UserDefaults.standard.set("YES", forKey: "IsOpenVC")
                                    setmessage = message
                                    
                                    
                                    presentation.wrappedValue.dismiss()
                                    
                                    
                                } else {
                                    setmessage = message
                                    
                                    UserDefaults.standard.set("YES", forKey: "IsOpenVC")
                                    presentation.wrappedValue.dismiss()
                                    
                                }
                            }
                        }
                    } else {
                        /// Convert document to PDF and share it
                        ActionButton(title: "Share", color: .accentColor) {
                            showLoadingView = true
                            manager.shareDocument { documentURL in
                                showLoadingView = false
                                UIApplication.shared.currentUIWindow()?.rootViewController?.presentedViewController?
                                    .present(UIActivityViewController(activityItems: [documentURL], applicationActivities: nil), animated: true, completion: nil)
                            }
                        }
                        
                        /// Convert document to text
                        ActionButton(title: "Text", color: Color("AccentLightColor")) {
                            showLoadingView = true
                            manager.extractText(fromImage: manager.scannedImagesArray[selectedIndex]) { success in
                                DispatchQueue.main.async {
                                    showLoadingView = false
                                    if success { manager.fullScreenType = .imageTextOCR }
                                }
                            }
                        }
                    }
                    
                }.padding([.leading, .trailing], 20)
            }
            
        }
        
    }
    
    /// Delete/Save buttons
    private func ActionButton(title: String, color: Color, action: @escaping() -> Void) -> some View {
        Button(action: {
            UIImpactFeedbackGenerator().impactOccurred()
            action()
        }, label: {
            ZStack {
                color.cornerRadius(40)
                Text(title).bold().font(.system(size: 18)).foregroundColor(.white)
            }
        }).frame(height: 48)
    }
}

// MARK: - Preview UI
struct CameraScannerContentView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = TaptokDataManager()
        manager.scannedImagesArray = [
            UIImage(named: "preview-doc-1")!,
            UIImage(named: "preview-doc-2")!,
            UIImage(named: "preview-doc-3")!
        ]
        return DocumentContentView().environmentObject(TaptokDataManager())
    }
}
