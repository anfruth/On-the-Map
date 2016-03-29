//
//  StudentInformation.swift
//  On the Map
//
//  Created by Andrew Fruth on 12/6/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import MapKit

struct StudentInformation {
    
    init(individualStudentData: [String: AnyObject], containsError: Bool, errorMessage: String) {
        self.individualStudentData = individualStudentData
        self.containsError = containsError
        self.errorMessage = errorMessage
    } // init seems unnecessary here, but am using to meet requirements
    
    var individualStudentData: [String: AnyObject]
    var containsError: Bool
    var errorMessage: String

    func createMapAnnotation() -> MKPointAnnotation {
        // Here we create the annotation and set its coordiate, title, and subtitle properties
        let annotation = MKPointAnnotation()
        annotation.coordinate = getCoordinates()
        annotation.title = getFullName()
        annotation.subtitle = getMediaURL()
        return annotation
    }
    
    func getFullName() -> String {
        let first = individualStudentData["firstName"] as! String
        let last = individualStudentData["lastName"] as! String
        return first + " " + last
    }
    
    func getMediaURL() -> String {
        return individualStudentData["mediaURL"] as! String
    }
    
    private func getCoordinates() -> CLLocationCoordinate2D {
        // Notice that the float values are being used to create CLLocationDegree values.
        // This is a version of the Double type.
        let lat = CLLocationDegrees(individualStudentData["latitude"] as! Double)
        let long = CLLocationDegrees(individualStudentData["longitude"] as! Double)
        
        // The lat and long are used to create a CLLocationCoordinates2D instance.
        let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        return coordinates
    }
    
}
