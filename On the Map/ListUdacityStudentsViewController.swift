//
//  ListUdacityStudentsViewController.swift
//  On the Map
//
//  Created by Andrew Fruth on 11/22/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit

class ListUdacityStudentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
       super.viewDidLoad()
        tableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.hidden = false
        tableView.reloadData()
    }
    @IBAction func logout(sender: UIBarButtonItem) {
        let loginClient = LoginAPIClient(email: nil, password: nil)
        loginClient.makeLoginRequest("DELETE") { error, userID in
            let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("loginVC") as! UdacityLoginViewController
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                self.presentViewController(loginVC, animated: true, completion: nil)
            }
            
        }
    }
    
    @IBAction func segueToEnterLocation(sender: UIBarButtonItem) {
        performSegueWithIdentifier("listGetLocation", sender: self)
    }
    
    @IBAction func refreshData(sender: UIBarButtonItem) {
        let apiClient = StudentAPIClient(endpoint: "https://api.parse.com/1/classes/StudentLocation?order=-updatedAt", parseID: Config.parseID, parseAPIKey: Config.parseAPIKey)
        apiClient.getAllStudentData() { studentDataRaw in
            if studentDataRaw != nil && studentDataRaw![0]["error"] == nil {
                self.convertToStudentInformation(studentDataRaw!)
                StudentAPIClient.allStudents = StudentAPIClient.allStudents
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    self.tableView.reloadData()
                }
            } else {
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    let errorMessage = StudentAPIClient.allStudents[0].errorMessage
                    let alert = AlertBox.makeAlert("Data Error", message: errorMessage)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func convertToStudentInformation(studentDataRaw: [[String : AnyObject]]) {
        StudentAPIClient.allStudents = []
        for individualStudentData in studentDataRaw {
            var udacityStudent = StudentInformation(individualStudentData: individualStudentData, containsError: false, errorMessage: "")
            if individualStudentData["error"] != nil {
                udacityStudent.containsError = true
                udacityStudent.errorMessage = individualStudentData["error"] as! String
            }
            StudentAPIClient.allStudents.append(udacityStudent)
        }
    }
    
    // table data
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.delegate = self
        return StudentAPIClient.allStudents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("udacityStudent") as UITableViewCell!
        let student = StudentAPIClient.allStudents[indexPath.row]
        cell.textLabel?.text = student.getFullName()
        return cell
    }
    
    // delegate 
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let student = StudentAPIClient.allStudents[indexPath.row]
        let studentURL = student.getMediaURL()
        if NSURL(string: studentURL) != nil {
            UIApplication.sharedApplication().openURL(NSURL(string: studentURL)!)
        }
    }


}

