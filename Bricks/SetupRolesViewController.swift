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
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "UnwindToDayView", sender: self);
    }
    
    @IBAction func editButtonTapped(_ sender: AnyObject) {
        
        guard let storyboard = self.storyboard, let editRolesVC = storyboard.instantiateViewController(withIdentifier: "EditRolesAndGoals") as? EditTableViewController else { fatalError() }
        editRolesVC.setupTableView(EditingMode.editRolesOnboarding, savedCompletionClosure: { [weak self] () in
            guard let sSelf = self else { return }
            sSelf.updateRoles()
            sSelf.tableView.reloadData()
        })
        self.present(editRolesVC, animated: false, completion: nil)

        
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RoleCell") as? RoleTableViewCell else { fatalError() }
        
        cell.roleTitleLabel.text = roles[(indexPath as NSIndexPath).row].name
        
        return cell

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roles.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard (indexPath as NSIndexPath).row <= roles.count - 1 else { fatalError() }
        let role = roles[(indexPath as NSIndexPath).row]
        guard let newGoalVC = self.storyboard!.instantiateViewController(withIdentifier: "NewRoleGoalViewController") as? NewRoleGoalViewController else { fatalError() }
        newGoalVC.roleToAddGoalsTo = role
        newGoalVC.conclusionCompletionBlock = { (canceled) in
            if let indexPath = tableView.indexPathForSelectedRow {
                if !canceled {
                    self.roles.remove(at: (indexPath as NSIndexPath).row)
                    self.tableView.deleteRows(at: [indexPath], with: .right)
                } else {
                    self.tableView.deselectRow(at: indexPath, animated: false)
                }
                // dismiss viewcontroller if finished.
                if self.roles.count == 0 {
                    let newAlertController = UIAlertController(title: "Congradulations!", message: "You have setup goals for each dimension of your life!", preferredStyle: .alert)
                    
                    let cancelAlert =  UIAlertAction(title: "Complete", style: .cancel, handler: { (_) -> Void in
                        self.doneButtonTapped(self)
                    })
                    newAlertController.addAction(cancelAlert)
                    
                    self.present(newAlertController, animated: true, completion: nil)
                    
                }

            }
        }
        
        self.present(newGoalVC, animated: true, completion: nil)
    }
    
}






