//
//  StudentAPIClient.swift
//  On the Map
//
//  Created by Andrew Fruth on 12/13/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import CoreLocation

struct StudentAPIClient {
    
    static var allStudents = [StudentInformation]()
    
    var endpoint: String
    var parseID: String
    var parseAPIKey: String
    
    func getAllStudentData(completionHandler: (studentData: [[String : AnyObject]]?) -> Void) {
        let request = getRequestValue("", mediaURL: "", latitude: 0.0, longitude: 0.0, httpMethod: "GET")
        let session = getSessionValue()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            let studentData = self.getParsedJSONData(data, error: error)
            completionHandler(studentData: studentData)
        }
        task.resume()

    }
    
    func getParsedJSONData(data: NSData?, error: NSError?) -> [[String: AnyObject]]? {
        if error != nil {
            return [["error": error!.localizedDescription + " Please restart app."]]
        }
        let parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
        } catch {
            return [["error": "Failed to parse JSON"]]
        }
        
        guard let studentData = parsedResult["results"] as? [[String: AnyObject]] else {
            return [["error": "Couldn't convertJSON to String"]]
        }
        
        return studentData
    }
    
    func postStudentLocation(locationString: String, mediaURL: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, completionHandler: (error: NSError?) -> Void) {
        let request = getRequestValue(locationString, mediaURL: mediaURL, latitude: latitude, longitude: longitude, httpMethod: "POST")
        let session = getSessionValue()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            completionHandler(error: error)
        }
        task.resume()
    }
    
    func getRequestValue(locationString: String, mediaURL: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, httpMethod: String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: endpoint)!)
        request.addValue(parseID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(parseAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        if httpMethod == "POST" {
            request.HTTPMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = "{\"uniqueKey\": \"\(UdacityLoginViewController.userID)\", \"firstName\": \"\(UdacityLoginViewController.firstName)\", \"lastName\": \"\(UdacityLoginViewController.lastName)\",\"mapString\": \"\(locationString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        }
        return request
    }
    
    func getSessionValue() -> NSURLSession{
        return NSURLSession.sharedSession()
    }
    
}