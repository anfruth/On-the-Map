//
//  LoginAPIClient.swift
//  On the Map
//
//  Created by Andrew Fruth on 12/20/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit

struct LoginAPIClient {
    
    var email: String?
    var password: String?
    
    func setupRequest(httpMethod: String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        // if post
        request.HTTPMethod = httpMethod
        if httpMethod == "POST" {
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = "{\"udacity\": {\"username\": \"\(email!)\", \"password\": \"\(password!)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        } else if httpMethod == "DELETE" {
            var xsrfCookie: NSHTTPCookie? = nil
            let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
            for cookie in sharedCookieStorage.cookies! {
                if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
            }
            if let xsrfCookie = xsrfCookie {
                request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
            }
        }
        
        return request
    }
    
    func getSessionValue() -> NSURLSession{
        return NSURLSession.sharedSession()
    }
    
    func makeLoginRequest(httpMethod: String, completionHandler: (error: AnyObject?, userID: String?) -> Void) {
        let request = setupRequest(httpMethod)
        let session = getSessionValue()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(error: error, userID: nil)
                return
            }
            if httpMethod == "POST" {
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                let parsedResult: AnyObject!
        
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
                } catch {
                    completionHandler(error: "JSONParse", userID: nil)
                    return
                }
        
                if (parsedResult["account"] as? NSDictionary) != nil {
                    let accountDict = parsedResult["account"] as? NSDictionary
                    let userID = accountDict!["key"] as! String
                    UdacityLoginViewController.userID = userID
                    completionHandler(error: nil, userID: userID)
                } else if (parsedResult["error"] as? String) != nil {
                    completionHandler(error: parsedResult["error"] as! String, userID: nil)
                }
            } else if httpMethod == "DELETE" {
                completionHandler(error: nil, userID: nil)
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            }
        }
        task.resume()
    }

    
    func getUserDetails(userID: String?, completionHandler: (error: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/" + userID!)!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                completionHandler(error: error!.localizedDescription)
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            let parsedResult: AnyObject!
            
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                completionHandler(error: "JSONParse")
                return
            }
            if (parsedResult["user"] as? NSDictionary != nil) {
                UdacityLoginViewController.firstName = (parsedResult["user"] as! NSDictionary)["first_name"] as! String
                UdacityLoginViewController.lastName = (parsedResult["user"] as! NSDictionary)["last_name"] as! String
                completionHandler(error: nil)
            } else {
                completionHandler(error: (parsedResult["error"] as! String))
            }
        }
        task.resume()
    }
    
    
    
}
