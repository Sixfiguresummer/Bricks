//
//  SetupRolesViewController.swift
//  GoalsForRoles
//
//  Created by Benjamin Patch on 4/29/16.
//  Copyright © 2016 PatchWork. All rights reserved.
//

import UIKit

class SetupRolesViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    lazy var roles = UserController.sharedInstance.currentUser.allRoles
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var doneButton: UIButton!
    
    
    func updateRoles() {
        self.roles = UserController.sharedInstance.currentUser.allRoles
    }
    
    
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("UnwindToDayView", sender: self);
    }
    
    @IBAction func editButtonTapped(sender: AnyObject) {
        
        guard let storyboard = self.storyboard, editRolesVC = storyboard.instantiateViewControllerWithIdentifier("EditRolesAndGoals") as? EditTableViewController else { fatalError() }
        editRolesVC.setupTableView(EditingMode.EditRolesOnboarding, savedCompletionClosure: { [weak self] () in
            guard let sSelf = self else { return }
            sSelf.updateRoles()
            sSelf.tableView.reloadData()
        })
        self.presentViewController(editRolesVC, animated: false, completion: nil)

        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
}


extension SetupRolesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("RoleCell") as? RoleTableViewCell else { fatalError() }
        
        cell.roleTitleLabel.text = roles[indexPath.row].name
        
        return cell

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roles.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard indexPath.row <= roles.count - 1 else { fatalError() }
        let role = roles[indexPath.row]
        guard let newGoalVC = self.storyboard!.instantiateViewControllerWithIdentifier("NewRoleGoalViewController") as? NewRoleGoalViewController else { fatalError() }
        newGoalVC.roleToAddGoalsTo = role
        newGoalVC.conclusionCompletionBlock = { (canceled) in
            if let indexPath = tableView.indexPathForSelectedRow {
                if !canceled {
                    self.roles.removeAtIndex(indexPath.row)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Right)
                } else {
                    self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
                }
                // dismiss viewcontroller if finished.
                if self.roles.count == 0 {
                    let newAlertController = UIAlertController(title: "Congradulations!", message: "You have setup goals for each dimension of your life!", preferredStyle: .Alert)
                    
                    let cancelAlert =  UIAlertAction(title: "Complete", style: .Cancel, handler: { (_) -> Void in
                        self.doneButtonTapped(self)
                    })
                    newAlertController.addAction(cancelAlert)
                    
                    self.presentViewController(newAlertController, animated: true, completion: nil)
                    
                }

            }
        }
        
        self.presentViewController(newGoalVC, animated: true, completion: nil)
    }
    
}






