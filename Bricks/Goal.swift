//
//  Goal.swift
//  GoalsForRoles
//
//  Created by Benjamin Patch on 11/24/15.
//  Copyright © 2015 PatchWork. All rights reserved.
//

import Foundation

class Goal: Equatable {
    
    static let kRoleID = "roleID"
    static let kGoalID = "goalID"
    static let kTitle = "title"
    static let kDatesCompleted = "datesCompleted"
    static let kDateCreated = "dateCreated"
    static let kDateDeleted = "dateDeleted"
    static let kWeekdaysApplicable = "weekdaysApplicable"
    static let endpoint = "goals/"
    
    var roleID: String
    var goalID: String
    var title: String
    var datesCompleted: [NSDate] = [] // Place in a separate firebase section
    var weekdaysApplicable: [Weekday]
    var dateCreated: NSDate
    var dateDeleted: NSDate?
    
    static var dateConverterFormatter : NSDateFormatter {
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .FullStyle
        formatter.timeStyle = .FullStyle
        
        return formatter
    }
    
    init(roleID: String = "", goalID: String = "", title: String, datesCompleted: [NSDate], dateCreated: NSDate = NSDate(), dateDeleted: NSDate? = nil, weekdaysApplicable: [Weekday] = Weekday.getAllWeekdays()) {
        self.roleID = roleID
        self.goalID = goalID
        self.title = title
        self.datesCompleted = datesCompleted
        self.dateCreated = dateCreated
        self.weekdaysApplicable = weekdaysApplicable
        self.dateDeleted = dateDeleted
    }
    
    
    convenience init?(dictionary: [String: AnyObject]) {
        
        guard let roleID = dictionary[Goal.kRoleID] as? String,
            let goalID = dictionary[Goal.kGoalID] as? String,
            let title = dictionary[Goal.kTitle] as? String
            else { return nil }
        
        let weekdaysApplicable: [Weekday]
        if let intWekdaysApplicable = dictionary[Goal.kWeekdaysApplicable] as? [Int] {
            weekdaysApplicable = Weekday.convertIntsToWeekdays(intWekdaysApplicable)
        } else {
            weekdaysApplicable = Weekday.getAllWeekdays() // default value for pre-weekdaysApplicable Goals in the database
        }
        
        var dates: [NSDate] = []
        
        if let datesCompletedStrings = dictionary[Goal.kDatesCompleted] as? [String] {
            dates = Goal.stringsToDates(datesCompletedStrings)
        }
        
        
        let dateCreated: NSDate
        
        if let dateCreatedString = dictionary[Goal.kDateCreated] as? String, let convertedDateCreated: NSDate = dateCreatedString.dateValue {
            dateCreated = convertedDateCreated
        } else {
            // default value for pre-dateCreated Goals in the database
            
            if dates.count == 0 {
                dateCreated = NSDate()
            }
            else {
                
                dateCreated = dates.first! // set the dateCreated to the first date it was accomplished.
                
                // make sure the role and the downloadDate aren't after this date?
                let role = RoleController.roleByRoleID(roleID)!
                if DateController.dateIsLaterThanDate(role.dateCreated, secondDate: dateCreated) {
                    role.dateCreated = dateCreated
                }
                if DateController.dateIsLaterThanDate(DateController.downloadDate!, secondDate: dateCreated) {
                    DateController.downloadDate = dateCreated
                }
                
            }
            
        }
        
        var dateDeleted: NSDate? = nil
        if let stringDateDeleted = dictionary[Goal.kDateDeleted] as? String, convertedDateDeleted = stringDateDeleted.dateValue {
            dateDeleted = convertedDateDeleted
        }
        
        self.init(roleID: roleID, goalID: goalID, title: title, datesCompleted: dates, dateCreated: dateCreated, dateDeleted: dateDeleted, weekdaysApplicable: weekdaysApplicable)
    }
    
    /**
     Gets the weekdaysApplicable that are after the dateCreated and before the dateDeleted.
     */
    func weekdaysApplicable(week: (sunday: NSDate, saturday: NSDate) = DateController.weekOfDate()) -> [Weekday] {
        var weekdaysValid = [Weekday]()
        for date in self.weekdatesApplicable() {
            guard let weekday = Weekday(rawValue: DateController.dayOfWeek(date)) else { fatalError() }
            weekdaysValid.append(weekday)
        }
        return weekdaysValid
    }

    func validWeekdaysApplicable(week: (sunday: NSDate, saturday: NSDate) = DateController.weekOfDate()) -> [Weekday] {
        var validWeekdaysApplicable = [Weekday]()
        guard let weekdayToday = Weekday(rawValue: DateController.dayOfWeek(NSDate())) else { fatalError() }
        for weekday in weekdaysApplicable(week) {
            if weekday.rawValue <= weekdayToday.rawValue {
                validWeekdaysApplicable.append(weekday)
            }
        }
        return validWeekdaysApplicable
    }
    
    /** Returns the valid dates in a week that are after/on the creation date, before/on the deletion date, and that are not in the future. */
    func validWeekdatesApplicable(week: (sunday: NSDate, saturday: NSDate) = DateController.weekOfDate(), excludeFutureDates: Bool = true) -> [NSDate] {

        guard excludeFutureDates else {
            return weekdatesApplicable(week)
        }
        
        var validWeekdatesApplicable = [NSDate]()
        for date in weekdatesApplicable(week) {
            if DateController.dateIsLaterThanDate(NSDate(), secondDate: date) || DateController.dateEqualsDate(date) {
                validWeekdatesApplicable.append(date)
            }
        }
        return validWeekdatesApplicable
//        let dateIsAWeekdayApplicable: (date: NSDate) -> Bool = { [weak self] (date) in
//            guard let sSelf = self, weekdayForDate = Weekday(rawValue: DateController.dayOfWeek(date)) else { return false }
//            
//            return sSelf.weekdaysApplicable.contains(weekdayForDate)
//        }
//        
//        var datesInWeek = [NSDate]()
//        for weekdayValue in 0...6 {
//            let dateInWeek = DateController.dateForDayOfWeek(weekdayValue, weekStartDate: week.sunday)
//            if (DateController.dateIsLaterThanDate(NSDate(), secondDate: dateInWeek) || DateController.dateEqualsDate(dateInWeek)) //the dateInWeek is not in the future.
//                && (DateController.dateIsLaterThanDate(dateCreated, secondDate: dateInWeek) || DateController.dateEqualsDate(dateCreated, secondDate: dateInWeek)) // the dateInWeek is after or on the date it was created
//            {
//                guard let dateDeleted = dateDeleted else {
//                    if dateIsAWeekdayApplicable(date: dateInWeek) {
//                        datesInWeek.append(dateInWeek)
//                    }
//                    continue
//                }
//                if DateController.dateIsLaterThanDate(dateDeleted, secondDate: dateInWeek) || DateController.dateEqualsDate(dateInWeek, secondDate: dateDeleted) // the dateInWeek is before it was deleted.
//                {
//                    if dateIsAWeekdayApplicable(date: dateInWeek) {
//                        datesInWeek.append(dateInWeek)
//                    }
//                }
//            }
//        }
//        
//        return datesInWeek
    }
    
    /**
     Gets the weekdaysApplicable that are after the dateCreated and before the dateDeleted.
     */
    func weekdatesApplicable(week: (sunday: NSDate, saturday: NSDate) = DateController.weekOfDate()) -> [NSDate] {
        
        var weekdatesApplicable = [NSDate]()
        for weekday in self.weekdaysApplicable {
            let date = DateController.dateForDayOfWeek(weekday.rawValue, weekStartDate: week.sunday)
            if DateController.dateIsLaterThanDate(date, secondDate: self.dateCreated) || DateController.dateEqualsDate(date, secondDate: self.dateCreated) {
                // Date is after or on Created Date.
                // Now check if it is before the deletedDate
                guard let dateDeleted = self.dateDeleted else {
                    // No deletedDate, so it is applicable.
                    weekdatesApplicable.append(date)
                    continue
                }
                if DateController.dateIsLaterThanDate(dateDeleted, secondDate: date) {
                    // date is before the dateDeleted, so it is applicable.
                    weekdatesApplicable.append(date)
                }
                
            }
        }
        return weekdatesApplicable
    }

    /** Converts an array of Strings in the correct format into an array of NSDates */
    static func stringsToDates(dateStrings: [String]) -> [NSDate] {
        
        var dates: [NSDate] = []
        
        dateStrings.forEach({ (dateString) -> () in
            
            dates.append(Goal.dateConverterFormatter.dateFromString(dateString)!)
            
        })
        
        return dates
    }
    
    /** Converts an array of NSDate objects into an array of Strings */
    static func datesToStrings(dates: [NSDate]) -> [String] {
        
        let formatter = Goal.dateConverterFormatter
        
        var stringDates = [String]()
        
        dates.forEach { (date) -> () in
            stringDates.append(formatter.stringFromDate(date))
        }
        
        return stringDates
    }
    
    
    /*
     Converts this Goal object into a dictionary object: [String:AnyObject]
     */
    func toDictionary() -> [String: AnyObject] {
        
        var dictionary: [String: AnyObject] = [
            Goal.kRoleID : self.roleID,
            Goal.kGoalID : self.goalID,
            Goal.kTitle : self.title,
            Goal.kDatesCompleted : Goal.datesToStrings(self.datesCompleted),
            Goal.kDateCreated : self.dateCreated.stringValue(),
            Goal.kWeekdaysApplicable : Weekday.convertWeekdaysToInts(self.weekdaysApplicable)
        ]
        
        if let dateDeleted = self.dateDeleted {
            dictionary[Goal.kDateDeleted] = dateDeleted.stringValue()
        }
        
        return dictionary
    }
    
    func save() {
        
        guard let role = GoalController.getRoleForGoal(self) else {
            
            print("UNABLE TO FIND ROLE FOR GOAL WITH ID: \(self.goalID) AND ROLE ID: \(self.roleID))")
            return
        }
        
        var firebaseEndpoint = FirebaseController.base.childByAppendingPath(Goal.endpoint)
        
        guard role.roleID != ""  else { print("Cannot save Goal with no RoleID"); return }
        
        if roleID == "" { roleID = role.roleID }
        
        firebaseEndpoint = firebaseEndpoint.childByAppendingPath(roleID)
        
        if goalID == "" {
            firebaseEndpoint = firebaseEndpoint.childByAutoId()
            goalID = firebaseEndpoint.key
        } else {
            firebaseEndpoint = firebaseEndpoint.childByAppendingPath(goalID)
        }
        
        firebaseEndpoint.updateChildValues(toDictionary())
        
    }
    
}

func == (lhs: Goal, rhs: Goal) -> Bool {
    return lhs.title == rhs.title && lhs.roleID == rhs.roleID
}