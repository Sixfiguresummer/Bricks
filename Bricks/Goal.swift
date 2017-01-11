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
    var datesCompleted: [Date] = [] // Place in a separate firebase section
    var weekdaysApplicable: [Weekday]
    var dateCreated: Date
    var dateDeleted: Date?
    
//    static var dateConverterFormatter : DateFormatter {
//        
//        let formatter = DateFormatter()
//        formatter.dateStyle = .full
//        formatter.timeStyle = .full
//        
//        return formatter
//    }
    
    init(roleID: String = "", goalID: String = "", title: String, datesCompleted: [Date], dateCreated: Date = Date(), dateDeleted: Date? = nil, weekdaysApplicable: [Weekday] = Weekday.getAllWeekdays()) {
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
        
        var dates: [Date] = []
        
        if let datesCompletedStrings = dictionary[Goal.kDatesCompleted] as? [String] {
            dates = Goal.stringsToDates(datesCompletedStrings)
        }
        
        
        let dateCreated: Date
        
        if let dateCreatedString = dictionary[Goal.kDateCreated] as? String, let convertedDateCreated: Date = dateCreatedString.dateValue as Date? {
            dateCreated = convertedDateCreated
        } else {
            // default value for pre-dateCreated Goals in the database
            
            if dates.count == 0 {
                dateCreated = Date()
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
        
        var dateDeleted: Date? = nil
        if let stringDateDeleted = dictionary[Goal.kDateDeleted] as? String, let convertedDateDeleted = stringDateDeleted.dateValue {
            dateDeleted = convertedDateDeleted as Date
        }
        
        self.init(roleID: roleID, goalID: goalID, title: title, datesCompleted: dates, dateCreated: dateCreated, dateDeleted: dateDeleted, weekdaysApplicable: weekdaysApplicable)
    }
    
    /**
     Gets the weekdaysApplicable that are after the dateCreated and before the dateDeleted.
     */
//    1.	While emitting SIL for 'weekdaysApplicable' at /Users/benpatch/Desktop/Bricks/Bricks/Goal.swift:109:5
    func weekdaysApplicable(_ week: (sunday: Date, saturday: Date) = DateController.weekOfDate()) -> [Weekday] {
        var weekdaysValid = [Weekday]()
        for date in self.weekdatesApplicable(DateController.weekOfDate()) {
            guard let weekday = Weekday(rawValue: DateController.dayOfWeek(date)) else { fatalError() }
            weekdaysValid.append(weekday)
        }
        return weekdaysValid
    }

    func validWeekdaysApplicable(_ week: (sunday: Date, saturday: Date) = DateController.weekOfDate()) -> [Weekday] {
        var validWeekdaysApplicable = [Weekday]()
        guard let weekdayToday = Weekday(rawValue: DateController.dayOfWeek(Date())) else { fatalError() }
        for weekday in weekdaysApplicable(week) {
            if weekday.rawValue <= weekdayToday.rawValue {
                validWeekdaysApplicable.append(weekday)
            }
        }
        return validWeekdaysApplicable
    }
    
    /** Returns the valid dates in a week that are after/on the creation date, before/on the deletion date, and that are not in the future. */
    func validWeekdatesApplicable(_ week: (sunday: Date, saturday: Date) = DateController.weekOfDate(), excludeFutureDates: Bool = true) -> [Date] {

        guard excludeFutureDates else {
            return weekdatesApplicable(week)
        }
        
        var validWeekdatesApplicable = [Date]()
        for date in weekdatesApplicable(week) {
            if DateController.dateIsLaterThanDate(Date(), secondDate: date) || DateController.dateEqualsDate(date) {
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
    func weekdatesApplicable(_ week: (sunday: Date, saturday: Date)) -> [Date] {
        
        var weekdatesApplicable = [Date]()
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
    static func stringsToDates(_ dateStrings: [String]) -> [Date] {
        
        var dates: [Date] = []
        
        dateStrings.forEach({ (dateString) -> () in
            
            dates.append(Date.DateConversionFormatter.date(from: dateString)!)
            
        })
        
        return dates
    }
    
    /** Converts an array of NSDate objects into an array of Strings */
    static func datesToStrings(_ dates: [Date]) -> [String] {
        
        let formatter = Date.DateConversionFormatter
        
        var stringDates = [String]()
        
        dates.forEach { (date) -> () in
            stringDates.append(formatter.string(from: date))
        }
        
        return stringDates
    }
    
    
    /*
     Converts this Goal object into a dictionary object: [String:AnyObject]
     */
    func toDictionary() -> [String: AnyObject] {
        
        var dictionary: [String: AnyObject] = [
            Goal.kRoleID : self.roleID as AnyObject,
            Goal.kGoalID : self.goalID as AnyObject,
            Goal.kTitle : self.title as AnyObject,
            Goal.kDatesCompleted : Goal.datesToStrings(self.datesCompleted) as AnyObject,
            Goal.kDateCreated : self.dateCreated.stringValue() as AnyObject,
            Goal.kWeekdaysApplicable : Weekday.convertWeekdaysToInts(self.weekdaysApplicable) as AnyObject
        ]
        
        if let dateDeleted = self.dateDeleted {
            dictionary[Goal.kDateDeleted] = dateDeleted.stringValue() as AnyObject?
        }
        
        return dictionary
    }
    
    func save() {
        
        guard let role = GoalController.getRoleForGoal(self) else {
            
            print("UNABLE TO FIND ROLE FOR GOAL WITH ID: \(self.goalID) AND ROLE ID: \(self.roleID))")
            return
        }
        
        var firebaseEndpoint = FirebaseController.base?.child(byAppendingPath: Goal.endpoint)
        
        guard role.roleID != ""  else { print("Cannot save Goal with no RoleID"); return }
        
        if roleID == "" { roleID = role.roleID }
        
        firebaseEndpoint = firebaseEndpoint?.child(byAppendingPath: roleID)
        
        if goalID == "" {
            firebaseEndpoint = firebaseEndpoint?.childByAutoId()
            goalID = (firebaseEndpoint?.key)!
        } else {
            firebaseEndpoint = firebaseEndpoint?.child(byAppendingPath: goalID)
        }
        
        firebaseEndpoint?.updateChildValues(toDictionary())
        
    }
    
}

func == (lhs: Goal, rhs: Goal) -> Bool {
    return lhs.title == rhs.title && lhs.roleID == rhs.roleID
}
