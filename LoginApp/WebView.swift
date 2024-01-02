//
//  WebView.swift
//  LoginApp
//
//  Created by Samir Castro on 14/07/22.
import SwiftUI
import WebKit
import CoreNFC
import MessageUI
import MobileCoreServices
import Contacts
import UniformTypeIdentifiers
import UIKit
import Foundation

struct WebView: UIViewRepresentable {
    typealias UIViewType = WKWebView
    @State var writer = NFCReader()
    let webView: WKWebView
    @ObservedObject var viewModel: WebViewModel
    func makeUIView(context: Context) -> WKWebView {

        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.configuration.dataDetectorTypes = .phoneNumber
        webView.configuration.dataDetectorTypes = .address
        webView.configuration.dataDetectorTypes = .all
        
        return self.webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler{
        private var viewModel: WebViewModel
        var previousPath = ""
        init(_ viewModel: WebViewModel) {
            self.viewModel = viewModel
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            //print("WebView: navigation finished")
            self.viewModel.isLoading = false
        }
        
      

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
            if let host = navigationAction.request.url?.host {
                //print(host)
                if host == "\(AppConfig.Host)" {
                    if let path = navigationAction.request.url?.path {
                        //print(path)
                        if path.contains("/v/") {
                            NotificationCenter.default.post(name: NSNotification.Name("showSafari"), object: navigationAction.request.url!,userInfo: nil)

                            decisionHandler(.cancel)
                            return
                        } else if path == "/login" {
                            NotificationCenter.default.post(name: AppConfig.logoutNotification, object: nil,userInfo: nil)
                            AppConfig.removeAllUserDefaults()

                        } else  if returnPath(path: path) {
                            previousPath = path
                            NotificationCenter.default.post(name: NSNotification.Name("hideBottomBar"), object: nil,userInfo: nil)
                            
                        } else {
                            NotificationCenter.default.post(name: NSNotification.Name("showBottomBar"), object: nil,userInfo: nil)
                            
                        }
                    }
                }else if  viewModel.isAppClip {
                    if let path = navigationAction.request.url?.path{
                       // print(path)
                        if path.contains("/v/") {
                            UserDefaults.standard.set(navigationAction.request.url! as URL, forKey: "appClipUrl")
                            NotificationCenter.default.post(name: NSNotification.Name("AppclipshowSafari"), object: navigationAction.request.url!,userInfo: nil)
                            decisionHandler(.cancel)
                            return
                        } else if path == viewModel.url.path {
                            NotificationCenter.default.post(name: NSNotification.Name("hideBackButton"), object: nil,userInfo: nil)
                        } else {
                            NotificationCenter.default.post(name: NSNotification.Name("showBackButton"), object: nil,userInfo: nil)
                        }
                    }
                }
                decisionHandler(.allow)
                
            }else if navigationAction.request.url?.scheme == "tel"{
                UIApplication.shared.open(navigationAction.request.url!, options: [:], completionHandler: nil)
               
                decisionHandler(.cancel)
            }else if (navigationAction.request.url?.scheme == "mailto") {
                UIApplication.shared.open(navigationAction.request.url!, options: [:], completionHandler: nil)

                decisionHandler(.cancel)
                return
            }else {
                decisionHandler(.allow)
            }

        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
                // TODO
           // print((navigationResponse))
             
                decisionHandler(.allow)
            }
        
        func returnPath(path : String) -> Bool {
            if path != "/physical-products" && path != "/my-audience" && path != "/my-contacts" && path != "/virtual-cards" && path != "/mini-pages" && path != "/settings" && path != "/support/home" && path != "/dashboard"  && path != "/organization/settings" && path != "/organization/members"{
                return true
            }
            return false
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print(error)
        }
        
        func webView(_: WKWebView, createWebViewWith _: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures _: WKWindowFeatures) -> WKWebView? {
            viewModel.webView.load(navigationAction.request)
           // self.webView?.load(navigationAction.request)
            return nil
        }
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
             // let messageBody = message.body as? String
               //print(messageBody as Any)
            }
    }
    
    func makeCoordinator() -> WebView.Coordinator {
        Coordinator(viewModel)
    }
}


class WebViewModel: ObservableObject {
    let webView: WKWebView
    var url: URL
    var isAppClip: Bool = false
    @State var SharedUser = UserDefaults(suiteName: SharedUserDefults.suiteName)

    @Published var isLoading: Bool = true
    var callBack: ((String) -> Void)? = nil
    init() {
        let config = WKWebViewConfiguration()
        config.userContentController.add(userContent(), name: "AdvanceHandshakeEvent")
        config.userContentController.add(userContent(), name: "OfflineEvent")
        config.userContentController.add(userContent(), name: "ShareVcfEvent")
        config.userContentController.add(userContent(), name: "ShareMiniPageEvent")

        config.dataDetectorTypes = [.all]
        webView = WKWebView(frame: .zero, configuration: config)
        url = URL(string: "\(AppConfig.DevURL)/dashboard")!
        loadUrl(Method: "GET", contactID: nil)
    }
    
    init(requestURL: URL) {
        let config = WKWebViewConfiguration()
        config.userContentController.add(userContent(), name: "AdvanceHandshakeEvent")
        config.userContentController.add(userContent(), name: "OfflineEvent")
        config.userContentController.add(userContent(), name: "ShareVcfEvent")
        config.userContentController.add(userContent(), name: "ShareMiniPageEvent")

        config.dataDetectorTypes = [.all]
        webView = WKWebView(frame: .zero, configuration: config)
        url = requestURL
        loadUrl(Method: "GET", contactID: nil)
    }
    
    init(requestURL: URL, contactID : NSInteger?, Method : String) {
        let config = WKWebViewConfiguration()
        config.userContentController.add(userContent(), name: "AdvanceHandshakeEvent")
        config.userContentController.add(userContent(), name: "OfflineEvent")
        config.userContentController.add(userContent(), name: "ShareVcfEvent")
        config.userContentController.add(userContent(), name: "ShareMiniPageEvent")

        config.dataDetectorTypes = [.all]
        webView = WKWebView(frame: .zero, configuration: config)
        if let contactID = UserDefaults.standard.value(forKey: "contact_id") as? NSInteger {
            let urlString = requestURL.absoluteString.appending("\(contactID)?convert=yes")
            url = URL(string: urlString)!//requestURL.appendingPathComponent("\(contactID)?convert=yes")
            loadUrl(Method: Method, contactID: contactID)
            
        }else {
            url = requestURL
            loadUrl(Method: Method, contactID: nil)
        }
        
    }
    func loadUrl(Method : String, contactID: NSInteger?) {
        
        var request = URLRequest(url: url)
        let defaults = UserDefaults.standard
        var token = ""
        if (defaults.string(forKey: "token") != nil) {
            token = defaults.string(forKey: "token")!
        }
        let all_cookies =  URLSession.shared.configuration.httpCookieStorage?.cookies
        if let cookies = all_cookies {
            for cookie in cookies {
               // print(cookie)
                webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
            }
        }
        do {
            let encodedData = try NSKeyedArchiver.archivedData(withRootObject: all_cookies as Any, requiringSecureCoding: false)

            self.SharedUser?.set(encodedData, forKey: SharedUserDefults.Values.cookiesKey)
            self.SharedUser?.synchronize()

        } catch {
            
        }
        request.httpMethod = Method
        if contactID == nil && url.path != "/support/home" && !isAppClip{
            request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
            request.setValue("Bearer Token:\"\(token)\"", forHTTPHeaderField: "Authorization")
            request.setValue("\(AppConfig.DevURL)/login", forHTTPHeaderField: "Referer")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("\(AppConfig.Host)", forHTTPHeaderField: "Host")
            request.setValue("application/xml, text/xml, */*; q=0.01", forHTTPHeaderField: "Accept")
            request.setValue("en-US,en;q=0.5", forHTTPHeaderField: "Accept-Language")
            request.setValue("gzip,deflate, br", forHTTPHeaderField: "accept-encoding")
            request.setValue("partial/ajax", forHTTPHeaderField: "faces-request")
        }else if url.path != "/support/home" {
           
        }
        
        webView.load(request);
    }
    
    func setUserContentController() {
        let contentController = self.webView.configuration.userContentController
        contentController.add(userContent(), name: "toggleMessageHandler")
        let js = """
            var _selector = document.querySelector('input[name=myCheckbox]');
            _selector.addEventListener('change', function(event) {
                var message = (_selector.checked) ? "Toggle Switch is on" : "Toggle Switch is off";
                if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.toggleMessageHandler) {
                    window.webkit.messageHandlers.toggleMessageHandler.postMessage({
                        "message": message
                    });
                }
            });
        """
        let script = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        contentController.addUserScript(script)
    }
}


class userContent: NSObject, WKScriptMessageHandler {
    @State var writer = NFCReader()
    @State private var isShowMessageController = false
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        //print(message.name)
        //print(message.body)

        if message.name == "AdvanceHandshakeEvent" {
            guard let dic = message.body as? [String : AnyObject] else {
                return
            }
            print(message.body)
            
            let messagedic = dic["message"]
            let handshake = messagedic?.object(forKey: "handshake") as! String
            let url_handshake = messagedic?.object(forKey: "url_handshake") as! String
            let product_id = messagedic?.object(forKey: "product_id") as! String
            self.writer.product_id = product_id
            self.writer.handshake = handshake
            self.writer.scan(theactualdata: url_handshake)
        } else if  message.name == "OfflineEvent" {
            guard let dic = message.body as? [String : AnyObject] else {
                return
            }
          //  print(dic)
            let messagedic = dic["message"]
            let sms_link = dic["sms_link"]
            let vcf_link = dic["vcf_link"] as! String
            let vcf = dic["vcf"] as! String
            let size = vcf.utf8.count
            let sizesms_link = sms_link as! String
            let SMSsize = sizesms_link.utf8.count
           // print(SMSsize)
            //print(size)
            if (sms_link != nil) {
               // print(vcf_link)
                var handshake = ""
                if let hshake = (messagedic?.object(forKey: "handshake") as? String) {
                    handshake = hshake
                }
                let product_id = messagedic?.object(forKey: "product_id") as! String
                let status = messagedic?.object(forKey: "status") as! String

                var contactUrl : URL? = nil
                var contactStr : String? = nil
                self.writer.product_id = product_id
                self.writer.status = status
                self.writer.SMSlink = sms_link as! String
                self.writer.handshake = handshake
                if let offline_action = messagedic?.object(forKey: "offline_action") as? [String : AnyObject] {
                    self.writer.slug = offline_action["slug"] as! String
                }
                if let data = vcf.data(using: .utf8) {
                   do{
                     let contacts = try CNContactVCardSerialization.contacts(with: data)
                     let contact = contacts.first
                       if contact != nil {
                           contactStr = toVCardText(toCNContact: contact!)
                          // print("\(String(describing: contact?.familyName))")
                       }
                     //print(contacts)
                   }
                   catch{
                     // Error Handling
                     print(error.localizedDescription)
                   }
                 }
                self.writer.Smsscan(theactualdata: sms_link as! String, vcf_Text: vcf)//(contactStr != nil) ? contactStr! : vcf)
            }
            
        }else if  message.name == "ShareVcfEvent" {
            guard let vcfLink = message.body as? String else {
                return
            }
           // LoadingView(isLoading: $isShowMessageController)
            NotificationCenter.default.post(name: NSNotification.Name("ShowMessageController"), object: vcfLink,userInfo: nil)

        }else if  message.name == "ShareMiniPageEvent" {
            guard let vcfLink = message.body as? String else {
                return
            }
           // LoadingView(isLoading: $isShowMessageController)
            NotificationCenter.default.post(name: NSNotification.Name("ShowMiniPageMessageController"), object: vcfLink,userInfo: nil)

        }

    }
    
    func toVCardText(toCNContact : CNContact) -> String? {
        guard let data = try?  CNContactVCardSerialization.data(with: [toCNContact]) else {
            return nil
        }
        let text = String(data: data, encoding: .utf8)!
        return text
    }
    
    func shareContacts(contacts: [CNContact]) -> URL? {

        guard let directoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }

        var filename = NSUUID().uuidString

        // Create a human friendly file name if sharing a single contact.
        if let contact = contacts.first, contacts.count == 1 {

            if let fullname = CNContactFormatter().string(from: contact) {
                filename = fullname.components(separatedBy: " ").joined(separator: "")//componentsSeparatedByString(" ").joinWithSeparator("")
            }
        }

        let fileURL = directoryURL.appendingPathComponent(filename).appendingPathExtension("vcf")
        do {
            let data = try CNContactVCardSerialization.data(with: contacts)
            
           // print("filename: \(filename)")
           // print("contact: \(String(describing: String(data: data, encoding: .utf8)))")
            do {
                try data.write(to: fileURL, options: [.atomic])//writeToURL(fileURL, options: [.AtomicWrite])
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
       // print(fileURL)
       return fileURL
    }
  
}

class NFCReader: NSObject ,ObservableObject,NFCNDEFReaderSessionDelegate{
    var product_id = ""
    var SMSlink = ""
    var handshake = ""
    var status = ""
    var theactualData = ""
    var slug = ""
    var nfcSession: NFCNDEFReaderSession?
    var readbool:Bool = true
    var vcf_link = ""
    var vcf_url : URL?
    var vcfText : String?

    func scan(theactualdata:String) {
        theactualData = theactualdata
        readbool = true
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        nfcSession?.alertMessage = "Hold Your iPhone Near an NFC Card"
        nfcSession?.begin()
    }

    func Smsscan(theactualdata:String , vcf_link: String) {
        theactualData = theactualdata
        self.vcf_link = vcf_link
        self.vcf_url = URL(string: vcf_link)
        readbool = true
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.alertMessage = "Hold Your iPhone Near an NFC Card"
        nfcSession?.begin()
    }
    
    func Smsscan(theactualdata:String , vcf_URL: URL) {
        theactualData = theactualdata
        self.vcf_url = vcf_URL
        readbool = true
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.alertMessage = "Hold Your iPhone Near an NFC Card"
        nfcSession?.begin()
    }
    
    func Smsscan(theactualdata:String , vcf_Text: String) {
        theactualData = theactualdata
        self.vcfText = vcf_Text
        readbool = true
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        nfcSession?.alertMessage = "Hold Your iPhone Near an NFC Card"
        nfcSession?.begin()
    }
  
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        var Str:String = theactualData
       // print(Str)
        //print( self.vcf_link)
       
        if readbool == false{
            guard let tag = tags.first else {
                return
            }
            session.connect(to: tag) { (error) in
                guard error == nil else {
                    session.invalidate(errorMessage: "Unable To Connect to Tag")
                    session.invalidate()
                    return
                }
                switch session {
                case self.nfcSession:
                    
                    self.readTag(session, tag: tag)
                    
                default:
                    session.invalidate()
                }
            }
        }else {
            
            let tag = tags.first!
            if tags.count > 1{
                let retryInterval = DispatchTimeInterval.milliseconds(500)
                session.invalidate(errorMessage: "More than one Tag Detected,please try again.")
                DispatchQueue.global().asyncAfter(deadline: .now()+retryInterval, execute: {
                    session.restartPolling()
                })
                return
            }
            session.connect(to: tag, completionHandler: {(error: Error?) in
                if nil != error{
                    session.invalidate(errorMessage: "Unable To Connect to Tag")
                    session.invalidate()
                    return
                }
                tag.queryNDEFStatus(completionHandler:{(ndefStatus: NFCNDEFStatus, capacity:Int,error:Error?) in
                    guard error == nil else {
                        session.invalidate(errorMessage: "Unable To Connect to Tag")
                        session.invalidate()
                        return
                    }
                    switch ndefStatus {
                    case .notSupported :
                        session.invalidate(errorMessage: "Unable To Connect to Tag")
                        session.invalidate()
                    case.readOnly :
                        
                        session.invalidate(errorMessage: "Unable To Connect to Tag")
                        session.invalidate()
                    case .readWrite :
                        if self.status == "pending_online" || self.status == "pending_offline"{                            if self.vcfText != nil {
                                let vcfData = self.vcfText!.trimmingCharacters(in: .whitespaces).data(using: .utf8)!
                                let textPayload = NFCNDEFPayload.wellKnownTypeTextPayload(string: self.vcfText!, locale: .current)!
                                let mediaPayload = NFCNDEFPayload(format: .media, type: "text/vcard".data(using: .utf8)!, identifier: "text/vcard".data(using: .utf8)!, payload: vcfData)
                            if Str == "" {
                                Str = "sms:"
                            }
                                tag.writeNDEF(.init(records: [mediaPayload,NFCNDEFPayload.wellKnownTypeURIPayload(string: "\(Str)")!,]), completionHandler:  {(error:Error?) in
                                    if nil !=  error{
                                        session.invalidate(errorMessage: "Write NDEF  Message Failed ")
                                    }else {
//                                        if self.SMSlink.contains("sms:"){
                                            if self.status == "pending_online" || self.status == "pending_offline"{
                                                session.alertMessage = "Product Offline Activated"
                                                self.callSetProductStatusAPI()
                                            }
                                       // }
                                    }
                                    session.invalidate()
                                })
                            } else {
                                if Str == "" {
                                    Str = "sms:"
                                }
                                tag.writeNDEF(.init(records: [NFCNDEFPayload.wellKnownTypeURIPayload(string: self.vcf_link)!,NFCNDEFPayload.wellKnownTypeURIPayload(string: "\(Str)")!,]), completionHandler:  {(error:Error?) in
                                    if nil !=  error{
                                        session.invalidate(errorMessage: "Write NDEF  Message Failed ")//.alertMessage = "Write NDEF  Message Failed "
                                    }else {
                                        
                                     //   if self.SMSlink.contains("sms:"){
                                            if self.status == "pending_online" || self.status == "pending_offline"{
                                                session.alertMessage = "Product Offline Activated"
                                                self.callSetProductStatusAPI()
                                            }
                                      //  }
                                    }
                                    session.invalidate()
                                })
                            }
                            
                            
                        }else {
                            tag.writeNDEF(.init(records: [NFCNDEFPayload.wellKnownTypeURIPayload(string: "\(Str)")! ,]), completionHandler:  {(error:Error?) in
                                if nil !=  error{
                                    session.invalidate(errorMessage: "Write NDEF  Message Failed ")//.alertMessage = "Write NDEF  Message Failed "
                                }else {
                                    
                                    if self.handshake == "pending"{
                                        session.alertMessage = "Handshake Experience Activated"
                                        self.get_handshake_state(product_id: self.product_id) { response in

                                            guard let success = response["success"] else { return  }
                                            
                                            if success as! Bool == true {
                                                let data = response["message"] as! NSDictionary
                                               // print(" 3    \(data)")
                                          
                                            }else{
                                                guard let message = response["message"] else { return  }
                                                //print(message)
                                            }
                                        }
                                    }else {
                                        session.invalidate(errorMessage: "Handshake Experience deactivated")//.alertMessage = "Handshake Experience deactivated"
                                    }
                                   
                                }
                                session.invalidate()
                            })
                        }
                        
                        
                    @unknown default:
                        session.invalidate(errorMessage: "Unknown Error")//.alertMessage = "Unknown Error"
                        session.invalidate()
                    }
                })
            })
        }
  
    }
    
    func callSetProductStatusAPI() {
            self.get_handshake_state(product_id: self.product_id) { response in
                guard let success = response["success"] else { return  }
                if success as! Bool == true {
                  
                }else{
                    
                }
            }
        
    }
    
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
            print("readerSessionDidBecomeActive")
    }
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        
    }
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        print("didDetectTags")
    }
    private func readTag(_ session: NFCNDEFReaderSession, tag: NFCNDEFTag) {
        
        tag.readNDEF { (message, error) in
            guard error == nil else {
                session.alertMessage = "Unable To Connect to Tag"
                session.invalidate()
                return
            }
            guard let record = message?.records.first else {
                session.invalidate()
                return
            }
            let firstChar = String(data: record.payload, encoding: .utf8)?.first
            let payload: String
            
            if firstChar == "\u{02}" {
                payload = "\(String(data: record.payload, encoding: .utf8)?.dropFirst(3) ?? "<UNK>")"
            }
            else {
                payload = "\(String(data: record.payload, encoding: .utf8)?.dropFirst(1) ?? "<UNK>")"
            }

            if payload.contains(self.product_id){
                session.alertMessage = "NFC connected Successfully."
                session.invalidate()
                self.nfcSession?.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    self.scan(theactualdata: self.theactualData)
                }
            }else {
                session.alertMessage = "Unable to validate product. Ensure the token of the back of your product matches with this code \(self.product_id)"
                session.invalidate()
                
            }
       
        }
    }

    func get_handshake_state(product_id: String, completion:@escaping ([String : Any]) -> ()) {
        /*product_id = '408f92d2'
         
         status = 'enabled'

         handshake_type=3*/
        var body: [String: Any] = ["product_id": product_id,"status": "enabled", "handshake_type" : 3]
        var url = URL(string: "\(AppConfig.DevURL)/api/set_handshake_state")!
        if self.status == "pending_offline"{
            body  = ["product_id": product_id,"status": "offline", "vcard_slug" : self.slug]
            url = URL(string: "\(AppConfig.DevURL)/api/set_product_state")!
        } else if self.status == "pending_online"{
            body  = ["product_id": product_id,"status": "online"]
            url = URL(string: "\(AppConfig.DevURL)/api/set_product_state")!
        }
        //let data = ["team_id" : teamid as String,"player_id" : player_id as String,"player_type" : Player as String,"dt" : device_token as String] as! Dictionary <String ,NSObject>
        print(body)
        let jsonData = try? JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("\(String(describing: jsonData?.count))", forHTTPHeaderField: "Content-Length")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        //print(request as Any)
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.httpCookieAcceptPolicy = .never
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let dataStr = String(data: data, encoding: .utf8)
            print("\(dataStr)")
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                DispatchQueue.main.async(execute: {
                    completion(responseJSON)
                    print(responseJSON as AnyObject)
                    NotificationCenter.default.post(name: NSNotification.Name("LoadeWebview"), object: nil,userInfo: nil)
                    
                })
                
            }
        }
        
        task.resume()
    }
}


struct MessageView: UIViewControllerRepresentable {
   // var attachmentURLStr: String
    var attachmentData : Data
    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        var completion: () -> Void
        init(completion: @escaping ()->Void) {
            self.completion = completion
        }
        
        // delegate method
        func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                   didFinishWith result: MessageComposeResult) {
            switch (result) {
                    case .cancelled:
                        print("Message was cancelled")
                    case .failed:
                        print("Message failed")
                    case .sent:
                        print("Message was sent")
                    default:
                    break
                }
            controller.dismiss(animated: true, completion: nil)
            completion()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator() {} // not using completion handler
    }
    
    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let vc = MFMessageComposeViewController()
        vc.addAttachmentData(attachmentData, typeIdentifier: kUTTypeVCard as String, filename: "vcfCard.vcf")
        vc.messageComposeDelegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}
    
    typealias UIViewControllerType = MFMessageComposeViewController
}
