//
//  WebServiceHandler.swift
//  SSUserApp
//
//  Created by MindCrew Technologies on 07/04/17.
//  Copyright © 2017 mahendra. All rights reserved.
//

import UIKit


class WebServiceHandler: NSObject {
    
    static let shared = WebServiceHandler() //lazy init, and it only runs once
    var window: UIWindow?
    var SharedUser = UserDefaults(suiteName: SharedUserDefults.suiteName)

    func GetcallWebService(withData dictData: NSDictionary, strURL: String, success: @escaping (_ responseDict: [AnyHashable: Any]) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        
        let todoEndpoint: String = strURL
        guard let url = URL(string: todoEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        guard let sharetoken = SharedUser?.string(forKey: SharedUserDefults.Values.token) else {
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Authorization": "Bearer \(sharetoken)"]
        let session = URLSession(configuration: config)
        
        // make the request
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("error calling GET on /todos/1")
                //print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as? [String: Any] {
                    let strData : NSString = NSString(data: responseData, encoding: String.Encoding.utf8.rawValue)!
                    DispatchQueue.main.async(execute: {
                        if (json as? NSDictionary) != nil{
                            success(json);
                        }
                        else if (json as? NSArray) != nil{
                            success(json);
                        }
                        
                    })
                }
                else
                {
                    failure(error)
                }
            }catch  {
                print("error trying to convert data to JSON")
                return
            }
            
        }
        task.resume()
        
        
    }
    
    func callWebService(withURL strURL: String, success: @escaping (_ responseDict: [AnyHashable: Any]) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        let url = URL(string: strURL)
        URLSession.shared.dataTask(with:url!) { (data, response, error) in
            if error != nil {
                failure(error)
            } else {
                do {
                    
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                    success(parsedData);
                    
                } catch let error as NSError {
                    //  print(error)
                    failure(error)
                }
            }
            
        }.resume()
    }
    
}
