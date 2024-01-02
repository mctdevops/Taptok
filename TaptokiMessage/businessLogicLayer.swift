//
//  businessLogicLayer.swift
//  barberApp
//
//  Created by MindCrewTech on 05/12/17.
//  Copyright © 2017 test. All rights reserved.
//

import UIKit
@objc protocol businessLogicLayerDelegate {
    
    @objc optional func VCFAPICallFinished(_ dictTeamarr : NSDictionary , massge : String )
    @objc optional func VCFAPICallMessage(_ massge : String)
    @objc optional func VCFAPICallError(_ error: Error)
    
}

class businessLogicLayer: NSObject {
    let strBaseURL:String = "https://app.taptok.dev/api/"
    weak var delegate: businessLogicLayerDelegate?
    
    func VCFAPICallAPICall(_ dictParameter:NSDictionary)
    {
       // print(dictParameter)
        WebServiceHandler.shared.GetcallWebService(withData: dictParameter, strURL:"\(strBaseURL)imessage_vcards", success: { [self](_ json: [AnyHashable: Any]) -> Void in
           // print(self.strBaseURL)
            DispatchQueue.main.async(execute: {
                if (json as? [String : Any]) != nil{
                    print(json)
                    if let success = json["success"] as? Bool {
                        if success {
//                            let data = json["data"] as? NSArray
                            self.delegate?.VCFAPICallFinished?(json as NSDictionary, massge: "Success")
                        } else {
                            
                        }
                    }
                   
                }
            })
            
        }, failure: {(_ error: Error?) -> Void in
            
            DispatchQueue.main.async(execute: {
               // self.delegate?.VCFAPICallError!(error!)
            })
            // print(error?.localizedDescription ?? "No data found!")
        })
    }

    
}
