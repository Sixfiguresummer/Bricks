//
//  SettingsViewController.swift
//  GoalsForRoles
//
//  Created by Benjamin Patch on 12/16/15.
//  Copyright © 2015 PatchWork. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Variables
    
    
    
    
    // MARK: Functions
    
    
    
    
    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    // MARK: Actions


    @IBAction func backButtonTapped(sender: UIButton) {
    
        self.dismissViewControllerAnimated(true, completion: nil)
    
    }

    
    
    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ToEditPersonalInformation" {
            
            //            let personalInformationVC = segue.destinationViewController as! PersonalInformationViewController
            
        }
        
        else if segue.identifier == "ToEditGoals" {
            
            let editGoalsVC = segue.destinationViewController as! EditTableViewController
            editGoalsVC.setupTableView(EditingMode.EditGoals)
            
            
        }
            
        else if segue.identifier == "ToEditRoles" {
            
            let editRolesVC = segue.destinationViewController as! EditTableViewController
            editRolesVC.setupTableView(EditingMode.EditRoles)
            
        }
            
        else { }
        
    }
    
}


//MARK: TableView Delegate and Datasource
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return MFMailComposeViewController.canSendMail() ? 3 : 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            
        case 0:
            return 1
        case 1:
            return 2
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("settingsCell")!
        
        switch indexPath.section {
            
        case 0:
            if indexPath.row == 0 {
                cell.textLabel?.text = "Profile"
            }
        case 1:
            if indexPath.row == 0 {
                
                cell.textLabel?.text = "Dimensions"
                
            } else if indexPath.row == 1 {
                
                cell.textLabel?.text = "Bricks"
                
            }
        case 2:
            
            cell.textLabel?.text = "Questions or Feedback"
            
        default:
            cell.textLabel?.text = "Error. There should not be an option (cell) here..."
        }
        
        
        cell.selectionStyle = .None
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
            
        case 0:
            return "Edit your personal information."
        case 1:
            return "Edit/Delete your Dimensions or Bricks"
        case 2:
            return "Feedback"
        default:
            return ""
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        switch indexPath.section {
            
        case 0:
            
            performSegueWithIdentifier("ToPersonalInformation", sender: self)
            
        case 1:
            
            if indexPath.row == 0 {
                
                performSegueWithIdentifier("ToEditRoles", sender: self)
                
            } else if indexPath.row == 1 {
                
                performSegueWithIdentifier("ToEditGoals", sender: self)
                
            }

        case 2:
            // present the mailViewController
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            
            // Configure the fields of the interface.
            composeVC.setToRecipients(["sixfiguresummer@gmail.com"])
            composeVC.setSubject("Six Figure Summer Feedback")
            
            // Present the view controller modally.
            self.presentViewController(composeVC, animated: true, completion: nil)

        default:
            break
        }
    }

}


extension SettingsViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(controller: MFMailComposeViewController,
                               didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        // Check the result or perform other tasks.
        
        // Dismiss the mail compose view controller.
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

}

















