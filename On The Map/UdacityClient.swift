//
//  UdacityClient.swift
//  On The Map
//
//  Created by Candice Reese on 3/13/17.
//  Copyright © 2017 Kevin Reese. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {
    
    
    var session = URLSession.shared
    var appDelegate: AppDelegate!
    
    override init() {
        super.init()
        
    }
    
    func getUserData(userID: String, completionHandlerForUserData: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        let urlString = Constants.UdacityAPI.BaseURL + Constants.UdacityParameters.Users + "/" + self.appDelegate.userID!
        let request = NSMutableURLRequest(url: URL(string: urlString)!)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
        
            guard (error == nil) else {
                completionHandlerForUserData(false, error as NSError?)
                print("Error in Error = nil")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandlerForUserData(false, error as NSError?)
                print("Error in StatusCode")
                return
            }
            
            guard let data = data else {
                completionHandlerForUserData(false, error as NSError?)
                print("Error in data = data")
                return
            }
            
            let range = Range(5 ..< data.count)
            let newData = data.subdata(in: range)
            
            //print(NSString(data: newData, encoding: String.Encoding.utf8.rawValue)!)
            
            var parsedResult: AnyObject! = nil
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as AnyObject
            } catch {
                _ = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
                print("Error in parse data")
            }
            
            print(parsedResult)
        
        }
        
        task.resume()
        //return task
        
    }
    
  
    
    func logInToUdacity (email: String, password: String, completionHandlerAuth: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        let urlString = Constants.UdacityAPI.BaseURL + Constants.UdacityAPI.ApiPath + "/" + Constants.UdacityParameters.SessionID
        //print(urlString)
        let request = NSMutableURLRequest(url: URL(string: urlString)!)
        //print(request)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard (error == nil) else {
                completionHandlerAuth(false, error as NSError?)
                print("Error in Error = nil")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandlerAuth(false, error as NSError?)
                print("Error in StatusCode")
                return
            }
            
            guard let data = data else {
                completionHandlerAuth(false, error as NSError?)
                print("Error in data = data")
                return
            }
            
            let range = Range(5 ..< data.count)
            let newData = data.subdata(in: range) /* subset response data! */
            //print(NSString(data: newData, encoding: String.Encoding.utf8.rawValue)!)
            
            //Parse the data from Login to the Udacity API
            
            var parsedResult: AnyObject! = nil
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as AnyObject
            } catch {
                _ = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
                print("Error in parse data")
            }
            
            guard let account = parsedResult["account"] as? [String:AnyObject] else {
                print("Error with Account info")
                return
            }
            
            guard let userID = account["key"] as? String else {
                print("Error with Key info")
                return
            }
            
            guard let sessionDict = parsedResult["session"] as? [String:AnyObject] else {
                print("Error with Session info")
                return
            }
            
            guard let session = sessionDict["id"] as? String else {
                print("Error with session id")
                return
            }
            
            
            self.appDelegate?.userID = userID
            self.appDelegate?.session = session
          
            self.getUserData(userID: self.appDelegate.userID!) {(success, errorString) in
                
                if success {
                    print("success")
                } else {
                    print("not successful")
                }
            }
 
            completionHandlerAuth(true, nil)
        }
        task.resume()
        
    }

    
    
    func logoutSession() {
        
        let urlString = Constants.UdacityAPI.BaseURL + Constants.UdacityAPI.ApiPath + "/" + Constants.UdacityParameters.SessionID
        
        let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL)
        
        request.httpMethod = "DELETE"
        
        var xsrfCookie: HTTPCookie? = nil
        
        let sharedCookieStorage = HTTPCookieStorage.shared
        
        for cookie in sharedCookieStorage.cookies! {
            
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
            
        }
        
        if let xsrfCookie = xsrfCookie {
            
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
            
        }
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            if error != nil { // Handle error…
                
                return
            }
    
            let newData = data?.subdata(in: 5..<(data?.count)!)
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue) as Any)
        }
        
        task.resume()
    }
    
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ results: AnyObject?, _ error: NSError?) -> Void) {
        
        //Parse data to get user info
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        completionHandlerForConvertData(parsedResult, nil)
        
    }
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
            
        }
        return Singleton.sharedInstance
        
    }
}



