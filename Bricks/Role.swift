//
//  Role.swift
//  GoalsForRoles
//
//  Created by Benjamin Patch on 11/24/15.
//  Copyright © 2015 PatchWork. All rights reserved.
//

import Foundation

enum AccountabilityStatus: Int {
    
    case Pending = 0,
    Accepted = 1,
    Denied = 2
    
}

class Role: Equatable {
    
    static let kName = "name"
    static let kUserID = "userID"
    static let kAccountorID = "accountorID"
    static let kAccountorName = "accountorName"
    static let kGoals = "goals"
    static let kRoleID = "roleID"
    static let kDateCreated = "dateCreated"
    static let kDateDeleted = "dateDeleted"
    static let endPoint = "roles/"
    static let endPointSimple = "roles"
    
    static let accountabilityEndPoint = "accountabilityRequests/"
    static let kPending = "pendingResponse"
    static let kAccountabilityStatus = "accountabilityStatus"
    
    // Professional
    
    var name: String
    var userID: String // for saving purposes
    var accountorID: String?
    var accountorName: String?
    var roleID: String
    var accountabilityStatus: AccountabilityStatus
    var dateCreated: NSDate
    var dateDeleted: NSDate?
    var goals: [Goal]
    var allGoals: [Goal] {
        return self.goals
    }

    
  init(userID: String = UserController.sharedInstance.currentUser.userID, accountorID: String? = nil, accountorName: String? = "", name: String, goals: [Goal] = [], roleID: String = "", accountabilityStatus: AccountabilityStatus = AccountabilityStatus.Denied, dateCreated: NSDate = NSDate(), dateDeleted: NSDate? = nil) {
        self.name = name
        self.userID = userID
        self.goals = goals
        self.roleID = roleID
        self.accountorName = accountorName
        self.accountorID = accountorID
        self.accountabilityStatus = accountabilityStatus
        self.dateCreated = dateCreated
    self.dateDeleted = dateDeleted
    }
    

//     TODO: implement grabbing out Goals?
    convenience init?(dictionary: [String: AnyObject]) {
        guard let name = dictionary[Role.kName] as? String,
            let userID = dictionary[Role.kUserID] as? String,
            let roleID = dictionary[Role.kRoleID] as? String
            else { return nil }
    
        // AccountabilityStatus
        var accountabilityStatus: Int = 2 // denied
        if let status = dictionary[Role.kAccountabilityStatus] as? Int {
            accountabilityStatus = status
        }
        // DateCreated
        let dateCreated: NSDate
        if let dateCreatedString = dictionary[Role.kDateCreated] as? String {
            dateCreated = dateCreatedString.dateValue!
        } else {
            dateCreated = NSDate()
        }
      
      var dateDeleted: NSDate? = nil
      
      if let stringDateDeleted = dictionary[Role.kDateDeleted] as? String, convertedDateDeleted = stringDateDeleted.dateValue {
        dateDeleted = convertedDateDeleted
      }
      
        // AccountorID
        if let accountorID = dictionary[Role.kAccountorID] as? String,
            let accountorName = dictionary[Role.kAccountorName] as? String {
                
          self.init(userID: userID, accountorID: accountorID, accountorName: accountorName, name: name, roleID: roleID, accountabilityStatus: AccountabilityStatus(rawValue: accountabilityStatus)!, dateCreated: dateCreated, dateDeleted: dateDeleted)
        } else  {
            self.init(userID: userID, name: name, roleID: roleID, accountabilityStatus: AccountabilityStatus(rawValue: accountabilityStatus)!, dateCreated: dateCreated, dateDeleted: dateDeleted)
        }
        
    }
    
    
    // TODO: implement adding the goals variable to the dictionary.
    func toDictionary() -> [String: AnyObject] {
        
        var dictionary: [String: AnyObject] = [
            Role.kName : self.name,
            Role.kUserID : self.userID,
            Role.kRoleID : self.roleID,
            Role.kAccountabilityStatus : self.accountabilityStatus.rawValue,
            Role.kDateCreated : self.dateCreated.stringValue()
        ]
        
        if let accountorID = self.accountorID, let accountorName = self.accountorName {
            dictionary.updateValue(accountorID, forKey: Role.kAccountorID)
            dictionary.updateValue(accountorName, forKey: Role.kAccountorName)
        }
      
      if let dateDeleted = self.dateDeleted {
        dictionary[Role.kDateDeleted] = dateDeleted.stringValue()
      }
        
        return dictionary
    }
    
    
    func save() {
        
        var firebaseEndpoint = FirebaseController.base.childByAppendingPath(Role.endPointSimple)
        
        guard UserController.userID != ""  else { print("Cannot save Role with no UserID"); return }
        
        if userID == "" { userID = UserController.userID }
        
        firebaseEndpoint = firebaseEndpoint.childByAppendingPath(userID)
        
        if roleID == "" {
            firebaseEndpoint = firebaseEndpoint.childByAutoId()
            roleID = firebaseEndpoint.key
        } else {
            firebaseEndpoint = firebaseEndpoint.childByAppendingPath(roleID)
        }
        
        firebaseEndpoint.updateChildValues(toDictionary())
        
        goals.forEach { (goal) -> () in
            goal.save()
        }
        
    }
    
    
    func addGoal(goal: Goal) {
        self.goals.append(goal)
    }
    
    func getValidGoalsForWeek(week: (firstDay: NSDate, lastDay: NSDate)) -> [Goal]? {
        
        var existingGoals: [Goal]? = nil
        
        for goal in allGoals {
            if !DateController.dateIsLaterThanDate(goal.dateCreated, secondDate: week.lastDay) || DateController.dateEqualsDate(goal.dateCreated, secondDate: week.lastDay) {
                guard let dateDeleted = goal.dateDeleted else {
                    if existingGoals != nil  {
                        existingGoals!.append(goal)
                    } else {
                        existingGoals = [goal]
                    }
                    continue
                }
                if DateController.dateIsLaterThanDate(dateDeleted, secondDate: week.lastDay) {
                    if existingGoals != nil  {
                        existingGoals!.append(goal)
                    } else {
                        existingGoals = [goal]
                    }
                }
            }
        }
        return existingGoals
    }
    
    func getValidGoalsForWeekStartingOnDate(startDate: NSDate) -> [Goal]? {
        let week = DateController.weekStartingOnDate(startDate)
        return getValidGoalsForWeek(week)
    }
    
    func getValidGoalsForDate(date: NSDate = NSDate()) -> [Goal]? {
        var goalsForDate: [Goal]? = nil
        for goal in allGoals {
            guard let weekday = Weekday(rawValue: DateController.dayOfWeek(date)) where goal.weekdaysApplicable.contains(weekday) else { continue }
            if !DateController.dateIsLaterThanDate(goal.dateCreated, secondDate: date) || DateController.dateEqualsDate(goal.dateCreated, secondDate: date) {
                guard let dateDeleted = goal.dateDeleted else {
                    if goalsForDate != nil  {
                        goalsForDate!.append(goal)
                    } else {
                        goalsForDate = [goal]
                    }
                    continue
                }
                if DateController.dateIsLaterThanDate(dateDeleted, secondDate: date) && !DateController.dateEqualsDate(dateDeleted, secondDate: date) {
                    if goalsForDate != nil  {
                        goalsForDate!.append(goal)
                    } else {
                        goalsForDate = [goal]
                    }
                }
            }
        }
        return goalsForDate
    }
        
    func setGoals(goals: [Goal]) {
        self.goals = goals
    }
    
}

func == (lhs: Role, rhs: Role) -> Bool {
    return lhs.roleID == rhs.roleID
}