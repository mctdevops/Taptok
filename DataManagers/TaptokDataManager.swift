//
//  TaptokDataManager.swift
//  PDFScanner
//
//  Created by Apps4World on 9/30/21.
//

import PDFKit
import Vision
import SwiftUI
import VisionKit
import Foundation
import Alamofire
import NotificationCenter
import Foundation
import NetworkExtension

/// App full screen type
enum FullScreenType: Identifiable {
    case  documentView, imageTextOCR
    var id: Int { hashValue }
}

/// Main data manager class
class TaptokDataManager: NSObject, ObservableObject {
    /// Dynamic properties that the UI will react to
    @Published var selectedTab: CustomTabBarItem = .home
    @Published var showAddFolderView: Bool = false
    @Published var fullScreenType: FullScreenType?
    @Published var didEnterCorrectPasscode: Bool = false
    @Published var scannedImagesArray: [UIImage] = [UIImage]()
    @Published var showAppClipContain: Bool = false
    @Published var appClipUrl: URL?
    @EnvironmentObject var manager: TaptokDataManager
    
    /// Dynamic properties that the UI will react to AND store values in UserDefaults
   
    @AppStorage("saveAlert") var saveAlert: String = "" {
        didSet { objectWillChange.send() }
    }
    @AppStorage("totalScannedDocuments") var totalScannedDocuments: Int = 0 {
        didSet { objectWillChange.send() }
    }
    
    
    /// Properties which doesn't update the UI as these are changing
   // let adMobAds: Interstitial = Interstitial()
    var documentPreviewMode: Bool = false
    var textRecognitionString: String = ""
    
    /// Default init
    override init() {
        super.init()
     
    }
}

// MARK: - Folder actions
extension TaptokDataManager {
    /// Delete a given folder
    /// - Parameter folder: folder object

}

// MARK: - Camera scanner
extension TaptokDataManager: VNDocumentCameraViewControllerDelegate {
    /// Returns a document scanner view controller
    func documentCameraViewController() -> VNDocumentCameraViewController {
        scannedImagesArray.removeAll()
        let viewController = VNDocumentCameraViewController()
        viewController.delegate = self
        return viewController
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        scannedImagesArray.removeAll()
        controller.dismiss(animated: true, completion: nil)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        scannedImagesArray.removeAll()
        let errorMessage = error.localizedDescription
        presentAlert(title: "Oops!", message: errorMessage,
                     primaryAction: UIAlertAction(title: "OK", style: .cancel, handler: nil))
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                      didFinishWith scan: VNDocumentCameraScan) {
        let documentIdentifier = scannedDocumentIdentifier
        for index in 0..<scan.pageCount {
            let imageIdentifier = "\(documentIdentifier)page\(index)"
            let image = scan.imageOfPage(at: index)
            image.accessibilityIdentifier = imageIdentifier
            scannedImagesArray.removeAll()
            scannedImagesArray.append(image)
           // print(scannedImagesArray.count)
        }
        controller.dismiss(animated: true) {
            if self.scannedImagesArray.count > 0 {
                self.documentPreviewMode = false
                self.fullScreenType = .documentView
                self.totalScannedDocuments += 1
            } else {
                presentAlert(title: "Oops!", message: "Something went wrong\nLooks like scanned images couldn't be saved", primaryAction: UIAlertAction(title: "OK", style: .cancel, handler: nil))
            }
        }
    }
    
    private var scannedDocumentIdentifier: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH_mm_ss"
        return dateFormatter.string(from: Date())
    }
}

// MARK: - PDF Document builder
extension TaptokDataManager {
    /// Delete a specific image/scanned page based on the image identifier
    /// - Parameter image: image to be deleted
    func deleteScannedFile(_ image: UIImage) {
        scannedImagesArray.removeAll(where: { $0.accessibilityIdentifier == image.accessibilityIdentifier })
    }
    
    /// Delete current document
    func deleteDocument(completion: @escaping() -> Void) {
        if let documentName = scannedImagesArray[0].accessibilityIdentifier?.components(separatedBy: "page").first {
            //let documentUpdatedName = "\(documentName)pagesCount\(scannedImagesArray.count)"

            scannedImagesArray.enumerated().forEach { index, _ in
                FileManager.default.delete(fileName: "\(documentName)page\(index).jpg")
            }
            FileManager.default.delete(fileName: "PDF-\(documentName).pdf")
            completion()
        }
    }
    
    /// Save current scanned or edited document
    func saveDocument(completion: @escaping((NSInteger?, String)) -> Void) {
        if (scannedImagesArray[0].accessibilityIdentifier?.components(separatedBy: "page").first) != nil {
           // let documentUpdatedName = "\(documentName)pagesCount\(scannedImagesArray.count)"

            scannedImagesArray.enumerated().forEach { index, image in
                TaptokDataManager.callsendImageAPI( arrImage: [image], imageKey: "file", URlName: "\(AppConfig.DevURL)/api/convert_paper_card") { response in
                    if let responseData = response {
                        let status = responseData["success"] as? Bool ?? false
                        if status {
                            if let message = responseData["message"] as? String {
                                let filename = responseData["filename"] as? String ?? ""
                               // print(responseData)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                                    TaptokDataManager.callGetLayoutAPI(imageName: filename, operation_location: message, URlName: "\(AppConfig.DevURL)/api/get_layout_results") { layout_response in
                                    if let layoutResponse = layout_response {
                                        //print(layoutResponse)
                                        let status1 = layoutResponse["success"] as? Bool ?? false
                                        let message = layoutResponse["message"] as? String ?? ""
                                        
                                        if status1 /*&& message == "Successfully converted paper card"*/{
                                            let contact_id = layoutResponse["contact_id"] as? NSInteger ?? 0
                                          
                                            self.prepareHaptics()
                                            completion((contact_id,message))
                                        }else{
                                            if let rows = layoutResponse["errors"] as? [Any]{
                                                   if let firstRow = rows[0] as? String{
                                                       //print(firstRow)
                                                       
                                                       completion((nil,firstRow))
                                                       return
                                                   }
                                               }
                                            
                                            completion((nil,"This contact already exist"))
                                        }
                                    }else{
                                      
                                        completion((nil,"Something went wrong\nPlease delete the document and scan again"))
                                    }
                                }
                                }
                                
                            }else{
                           
                                completion((nil,"Something went wrong\nPlease delete the document and scan again"))
                            }
                        }else{
                            
                            completion((nil,"Something went wrong\nPlease delete the document and scan again"))
                        }
                    }else{
                        //print("completion 1")
                        completion((nil,"Something went wrong\nPlease delete the document and scan again"))
                    }
                    
                }

            }
            
        } else {
            presentAlert(title: "Oops!", message: "Something went wrong\nPlease delete the document and scan again", primaryAction: UIAlertAction(title: "OK", style: .cancel, handler: nil))
        }
    }
    func prepareHaptics() {
        let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
    }
    public class func callsendImageAPI(arrImage:[UIImage], imageKey:String, URlName:String, withblock:@escaping (_ response: [String : Any]?)->Void){
        let defaults = UserDefaults.standard
        var token = ""
        if (defaults.string(forKey: "token") != nil) {
            token = defaults.string(forKey: "token")!
        }
        let url = URL(string: URlName)
        let headers: HTTPHeaders
        headers = ["Content-type": "multipart/form-data",
                   "Content-Disposition" : "form-data",
                   "Authorization":"Bearer Token:\"\(token)\""]
 
        AF.upload(multipartFormData: { (multipartFormData) in
            for img in arrImage {
                guard let imgData = img.jpegData(compressionQuality: 1) else { return }
                multipartFormData.append(imgData, withName: imageKey, fileName: "\(Date())" + ".jpeg", mimeType: "image/jpeg")
            }
     
        },to: url!, usingThreshold: UInt64.init(),
          method: .post,
          headers: headers).response{ response in
            
            if((response.error == nil)){
                do{
                    if let jsonData = response.data{
                        let parsedData = try JSONSerialization.jsonObject(with: jsonData) as! Dictionary<String, AnyObject>
                        withblock(parsedData)
                    }
                }catch{
                    withblock(nil)
                   // print("error message")
                }
            }else{
                withblock(nil)
                 //print(response.error!.localizedDescription)
            }
        }
    }
  
    
    public class func callGetLayoutAPI(imageName:String, operation_location:String, URlName:String, withblock:@escaping (_ response: [String : Any]?)->Void){
        let defaults = UserDefaults.standard
        var token = ""
        if (defaults.string(forKey: "token") != nil) {
            token = defaults.string(forKey: "token")!
        }
        
        var user_id = 0
        user_id = UserDefaults.standard.integer(forKey: "user_id")
        
        let url = URL(string: URlName)


        let headers: HTTPHeaders
        headers = ["Authorization":"Bearer Token:\"\(token)\"","operation-location" : operation_location,"user-id" : "\(user_id)" , "X-Requested-With" : "XMLHttpRequest","filename" :"\(imageName)"]
        let all_cookies =  URLSession.shared.configuration.httpCookieStorage?.cookies
        if let cookies = all_cookies {
            for _ in cookies {

            }
        }

        AF.request(url!, method: HTTPMethod(rawValue: "POST"), parameters: nil, encoding: URLEncoding.default, headers: headers, interceptor: nil, requestModifier: nil).response { response in
            if((response.error == nil)){
                do{
                    if let jsonData = response.data{
                        let parsedData = try JSONSerialization.jsonObject(with: jsonData) as! Dictionary<String, AnyObject>
                        withblock(parsedData)
                     
                    }
                    
                }catch{
                  //  print("error message")
                }
            }else{
               // print(response.error!.localizedDescription)
           }
        }
      
    }
    /// Share the PDF for a scanned document
    func shareDocument(completion: @escaping(_ url: URL) -> Void) {
        let document = PDFDocument()
        scannedImagesArray.enumerated().forEach { index, image in
            if let page = PDFPage(image: image) {
                document.insert(page, at: index)
            }
        }
        if let pdfData = document.dataRepresentation(),
           let name = scannedImagesArray[0].accessibilityIdentifier?.components(separatedBy: "page").first {
            FileManager.default.save(data: pdfData, name: "PDF-\(name).pdf") { fileURL in
                completion(fileURL)
            }
        } else {
            presentAlert(title: "Oops!", message: "Something went wrong\nPlease try again", primaryAction: UIAlertAction(title: "OK", style: .cancel, handler: nil))
        }
    }
    
    /// Extract the text from a file/image
    func extractText(fromImage image: UIImage, completion: @escaping(_ success: Bool) -> Void) {
        textRecognitionString = ""
        
        guard let image = image.cgImage else {
            presentAlert(title: "Oops!", message: "Something went wrong\nPlease try again", primaryAction: UIAlertAction(title: "OK", style: .cancel, handler: nil))
            completion(false)
            return
        }
        
        /// Configure the text recognition request
        let request = VNRecognizeTextRequest { (request, error) in
            if let error = error?.localizedDescription {
                presentAlert(title: "Oops!", message: error, primaryAction: UIAlertAction(title: "OK", style: .cancel, handler: nil))
                completion(false)
            } else {
                guard let results = request.results, results.count > 0 else {
                    presentAlert(title: "Oops!", message: "We couldn't detect any text\nPlease try again", primaryAction: UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    completion(false)
                    return
                }
                
                /// Aggregate the text recognition result
                for result in results {
                    if let observation = result as? VNRecognizedTextObservation {
                        for text in observation.topCandidates(1) {
                            self.textRecognitionString.append("\(text.string)\n\n")
                        }
                    }
                }
                
                if self.textRecognitionString.count > 0 {
                    completion(true)
                } else {
                    presentAlert(title: "Oops!", message: "We couldn't detect any text\nPlease try again", primaryAction: UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    completion(false)
                }
            }
        }
        
        /// Text recognition language
        request.recognitionLanguages = ["en_US"]
        request.recognitionLevel = .accurate
        
        let requests = [request]
        let handler = VNImageRequestHandler(cgImage: image, orientation: .up, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform(requests)
            } catch let error as NSError {
                presentAlert(title: "Oops!", message: error.localizedDescription, primaryAction: UIAlertAction(title: "OK", style: .cancel, handler: nil))
                completion(false)
            }
        }
    }
}

// MARK: - Prepare PDF preview mode
extension TaptokDataManager {
    /// Load all PDF scanned files for the preview mode
    /// - Parameter fileName: file name
    func preparePreviewMode(fileName: String) {
        let fileComponents = fileName.components(separatedBy: "pagesCount")
        if let pagesCount = Int(fileComponents.last ?? ""), let name = fileComponents.first {
            scannedImagesArray.removeAll()
            for index in 0..<pagesCount {
                if let imageData = FileManager.default.loadData(fileName: "\(name)page\(index).jpg"),
                   let scannedImage = UIImage(data: imageData) {
                    scannedImage.accessibilityIdentifier = "\(name)page\(index)"
                    scannedImagesArray.append(scannedImage)
                }
            }
            if scannedImagesArray.count > 0 {
                documentPreviewMode = true
                fullScreenType = .documentView
            } else {
                presentAlert(title: "Oops!", message: "Something went wrong\nPlease try again", primaryAction: UIAlertAction(title: "OK", style: .cancel, handler: nil))
            }
        } else {
            presentAlert(title: "Oops!", message: "Something went wrong\nWe couldn't open this document", primaryAction: UIAlertAction(title: "OK", style: .cancel, handler: nil))
        }
    }
}
