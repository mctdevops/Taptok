//
//  MessagesViewController.swift
//  TaptokiMessage
//
//  Created by Mehul Nahar on 01/11/22.
//

import UIKit
import Messages
import WebKit
import SafariServices
import Contacts
import ContactsUI
import CoreNFC
import MessageUI
import MobileCoreServices
import UniformTypeIdentifiers
import SwiftUI
import Foundation


class MessagesViewController: MSMessagesAppViewController,WKNavigationDelegate,WKUIDelegate{
    @State private var showLoadingView: Bool = true
    static let storyboardIdentifier = "ImessageloadViewController"
    var SharedUser = UserDefaults(suiteName: SharedUserDefults.suiteName)
    
    @IBOutlet weak var message_lbl: UILabel!
    @IBOutlet weak var Activity_large: UIActivityIndicatorView!
    var checkviewsts = "compact"
    //expanded
    var controller: ImessageloadViewController?
    var arrayolist:NSArray = [] ;
    override func viewDidLoad() {
        super.viewDidLoad()
       
        guard let LOGIN = SharedUser?.string(forKey: SharedUserDefults.Values.LOGIN) else {
            return
        }
        if LOGIN == "YES"{
        Activity_large .isHidden  = false
        message_lbl .isHidden  = false
        message_lbl.text = "Please wait..."
        }else {
            Activity_large .isHidden  = false
            message_lbl .isHidden  = false
            message_lbl.text = "Please login with Taptok app."
        }
       
    }
    
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        let message = conversation.selectedMessage
       // print(message as Any)
        // Present the view controller appropriate for the conversation and presentation style.
        presentViewController(for: conversation, with: presentationStyle)
    }
  
   
    // MARK: MSMessagesAppViewController overrides
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.willTransition(to: presentationStyle)
        if (presentationStyle == .compact) {
            checkviewsts = "compact"
            // handle transition from .compact to .expanded here
            removeAllChildViewControllers()
        }else {
        
            checkviewsts = "expanded"
            removeAllChildViewControllers()
        }
        // Hide child view controllers during the transition.
       
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.didTransition(to: presentationStyle)
        
        // Present the view controller appropriate for the conversation and presentation style.
        guard let conversation = activeConversation else { fatalError("Expected an active converstation") }
        presentViewController(for: conversation, with: presentationStyle)
    }
   
    // MARK: Child view controller presentation
    
    /// - Tag: PresentViewController
     func presentViewController(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle) {
        // Remove any child view controllers that have been presented.
        removeAllChildViewControllers()
        controller = ImessageloadViewController()
         addChild(controller!)
        controller!.view.frame = view.bounds
        controller!.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller!.view)
        NSLayoutConstraint.activate([
            controller!.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            controller!.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            controller!.view.topAnchor.constraint(equalTo: view.topAnchor),
            controller!.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        controller!.didMove(toParent: self)
    }
    
    func ImessageloadViewController() -> ImessageloadViewController {
        let story:UIStoryboard = UIStoryboard(name: "MainInterface", bundle: nil)
        guard let controller:ImessageloadViewController = (story.instantiateViewController(withIdentifier: "ImessageloadViewController") as? ImessageloadViewController)!
            as? ImessageloadViewController
            else { fatalError("Unable to instantiate an IceCreamsViewController from the storyboard") }
        controller.checkviewsts = checkviewsts;
        controller.delegate = self
        return controller
    }
    // MARK: Convenience
    
    private func removeAllChildViewControllers() {
        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
   

}


/// Extends `MessagesViewController` to conform to the `IceCreamsViewControllerDelegate` protocol.

extension MessagesViewController: ImessageloadViewControllerDelegate {
    
    func iMessageLoadViewController(_ controller: ImessageloadViewController, didSelect VCFPart: VcfcardfPart) {
       // share(VCFPart)
       // print(VCFPart.share_link)
        
          /*  if let filepath = Bundle.main.path(forResource: "vcard", ofType: "vcf") {
                do {
                    let contents = try String(contentsOfFile: filepath)
                    let data = contents.data(using: .utf8)
                    let contact = try CNContactVCardSerialization.contacts(with: data!)
                    print(contents)

                    let contactUrl = self.shareContacts(contacts: contact)
                    if let convo = self.activeConversation {
                        
                        
                        convo.insertAttachment(contactUrl! , withAlternateFilename: "vcfcard"){ error in
                            if let error = error {
                                print(error)
                            }
                        }
                    }
                } catch {
                    // contents could not be loaded
                }
            } else {
                // example.txt not found!
            }
*/
        
        downloadAttachment(vcfLink: VCFPart.share_link)
    }
    
    func downloadAttachment(vcfLink : String){
        if vcfLink != "" {
            let fileURL = URL(string: vcfLink)
            let session = URLSession.shared
            let task = session.dataTask(with: fileURL!) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                if let data = data {
                     var vcardAsString = String(data: data, encoding: .utf8)
                     print(vcardAsString)
                    // vcardAsString = vcardAsString?.replacingOccurrences(of: "Manteiga;Jaime", with: "Manteiga Jaime")
                    //print(vcardAsString)
                    //
//                    let vcardAsString = String(data: data, encoding: .utf8)
//                    let photo = ""
//                     let vcardCleaned = vcardAsString?.replacingOccurrences(of: "END:VCARD", with: "\n")
//                    let vcardPhoto = "PHOTO;TYPE=JPEG;ENCODING=BASE64:".appending(photo)
//                     let vcardPhotoAppended = vcardAsString?.appending(vcardPhoto)
//                    let vcardEnd = "\nEND:VCARD"
//                    let vcardEndAppended = vcardAsString?.appending(vcardEnd)
                    let biopicdata = Data(vcardAsString!.utf8)
                    let contact = try? CNContactVCardSerialization.contacts(with: data)
                    let contactUrl = self.shareContacts(contacts: contact!, data: data)
                    print(contactUrl)
                    self.requestPresentationStyle(.compact)
                    DispatchQueue.main.async {
                        self.controller?.hideLoader()
                        self.controller?.Loder_top.constant = 80
                    }
                    if let convo = self.activeConversation {
                        convo.insertAttachment(contactUrl!, withAlternateFilename: "vcfcard"){ error in
                            if let error = error {
                                print(error)
                            }
                        }
                       
                           
                    }
                }
            }
            task.resume()
        }
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
          
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    func shareContacts(contacts: [CNContact], data : Data) -> URL? {
        
        guard let directoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        var filename = NSUUID().uuidString
        if let contact = contacts.first, contacts.count == 1 {
            print("image data \(contact.familyName)")
            print("image data available \(contact.imageDataAvailable)")

            if let fullname = CNContactFormatter().string(from: contact) {
                let contactName = CNContactFormatter.string(from: contact, style: .fullName)!
                let ontactPrefix = contact.namePrefix
                filename = fullname.components(separatedBy: " ").joined(separator: "")
                filename = fullname.components(separatedBy: "vCard Share").joined(separator: "")
               
                
            }
        }
        
        let fileURL = directoryURL.appendingPathComponent(filename).appendingPathExtension("vcf")
        do {
           
            var vcardAsString = String(data: data, encoding: .utf8)
      

            do {
                try data.write(to: fileURL, options: [.atomic])
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
        return fileURL
    }
    func shareContacts(contacts: [CNContact]) -> URL? {
        
        guard let directoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        var filename = NSUUID().uuidString
        if let contact = contacts.first, contacts.count == 1 {
           // print("image data \(contact.imageData)")
           // print("image data available \(contact.imageDataAvailable)")

            if let fullname = CNContactFormatter().string(from: contact) {
                filename = fullname.components(separatedBy: " ").joined(separator: "")
            }
        }
        let fileURL = directoryURL.appendingPathComponent(filename).appendingPathExtension("vcf")
        do {
            let data = try CNContactVCardSerialization.data(with: contacts)
           // var vcardAsString = String(data: data, encoding: .utf8)

            do {
                try data.write(to: fileURL, options: [.atomic])
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
        return fileURL
    }

}
extension CNContactVCardSerialization {
    class func dataWithExtraInformation(contacts: [CNContact]) throws -> Data {
        var text: String = ""
        for contact in contacts {
            let data = try CNContactVCardSerialization.data(with: [contact])
            var str = String(data: data, encoding: .utf8)!
            
            if let imageData = contact.imageData {
                let base64 = imageData.base64EncodedString()
                str = str.replacingOccurrences(of: "END:VCARD", with: "PHOTO;ENCODING=b;TYPE=JPEG:\(base64)\nEND:VCARD")
            }
            
            if !contact.note.isEmpty {
                str = str.replacingOccurrences(of: "END:VCARD", with: "NOTE:\(contact.note)\nEND:VCARD")
            }
            
            text = text.appending(str)
        }
        return text.data(using: .utf8)!
    }
}
