//
//  User.swift
//  GoalsForRoles
//
//  Created by Benjamin Patch on 11/24/15.
//  Copyright © 2015 PatchWork. All rights reserved.
//

import Foundation


class User {
    
    static let kUserID = "userID"
    static let kFirstName = "firstName"
    static let kLastName = "lastName"
    static let kPhoneNumber = "phoneNumber"
    static let kRoles = "roles"
    static let endpoint = "user/"
    
    var userID: String
    let firstName: String
    let lastName: String
    let phoneNumber: String
    var name: String {
        if lastName.characters.count > 0 {
            if firstName != "" {
                return firstName + " " + lastName[0]
            }
            else {
                return lastName
            }
        } else {
            return firstName
        }
    }
    
    fileprivate var roles: [Role] = []
    var allRoles: [Role] {
        return self.roles
    }
    
    static var defaultRoles = [Role(name: "Physical"), Role(name: "Emotional"), Role(name: "Mental"), Role(name: "Spiritual"), Role(name: "Professional")]
    
    init(userID: String = "", firstName: String, lastName: String, phoneNumber: String, roles: [Role] = []) {
        
        self.userID = userID
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.roles = roles
        
    }
    
    convenience init?(dictionary: [String: AnyObject]) {
        
        guard let firstName = dictionary[User.kFirstName] as? String,
            let lastName = dictionary[User.kLastName] as? String,
            let userID = dictionary[User.kUserID] as? String,
            let phoneNumber = dictionary[User.kPhoneNumber] as? String
            else { return nil }
        
        self.init(userID: userID, firstName: firstName, lastName: lastName, phoneNumber: phoneNumber, roles: [])
        
        // TODO: Get Roles
    }
    
    func toDictionary() -> [String: AnyObject]{
        let dictionary: [String: AnyObject] = [
            User.kUserID : userID as AnyObject,
            User.kFirstName : firstName as AnyObject,
            User.kLastName : lastName as AnyObject,
            User.kPhoneNumber : phoneNumber as AnyObject
        ]
        
        return dictionary
    }
    
    
    func save() {
        
        // Does not account for the user not already being set up with a User ID. That is the responsibility of the FirebaseController.registerUser() method.
        
        var firebaseEndpoint = FirebaseController.base?.child(byAppendingPath: User.endpoint)
        
        guard userID != ""  else { print("Cannot save User with no UserID"); return }
        
        firebaseEndpoint = firebaseEndpoint?.child(byAppendingPath: userID)
        
        firebaseEndpoint?.updateChildValues(toDictionary())

        roles.forEach { (role) -> () in
            role.save()
        }

    }
    
    func addRole(_ role: Role) {
        self.roles.append(role)
    }
    
    func setRoles(_ roles: [Role]) {
        self.roles = roles
    }
    
    
    func getValidRolesForWeek(_ week: (firstDay: Date, lastDay: Date)) -> [Role]? {
        var validRoles = [Role]()
        for role in roles {
            if !DateController.dateIsLaterThanDate(role.dateCreated, secondDate: week.lastDay) {
                guard let dateDeleted = role.dateDeleted else {
                    // no date deleted. valid Role
                    validRoles.append(role)
                    continue
                }
                if DateController.dateIsLaterThanDate(dateDeleted, secondDate: week.firstDay) {
                    validRoles.append(role)
                }
            }
        }
        return validRoles.count > 0 ? validRoles : nil
    }
    
    func getValidRolesForWeekStartingOnDate(_ startDate: Date) -> [Role]? {
        let week = DateController.weekStartingOnDate(startDate)
        return self.getValidRolesForWeek(week)
    }
    
    func getValidRolesForDate(_ date: Date = Date()) -> [Role]? {
        var validRoles = [Role]()
        for role in roles {
            if !DateController.dateIsLaterThanDate(role.dateCreated, secondDate: date) || DateController.dateEqualsDate(role.dateCreated, secondDate: date) {
                guard let dateDeleted = role.dateDeleted else {
                    // no date deleted. valid Role
                    validRoles.append(role)
                    continue
                }
                if DateController.dateIsLaterThanDate(dateDeleted, secondDate: date) && !DateController.dateEqualsDate(date, secondDate: dateDeleted) {
                    validRoles.append(role)
                }
            }
        }
        return validRoles.count > 0 ? validRoles : nil
    }


}







// JUNKYARD:


//
//    // MARK: FirebaseType Protocol
////
////    var identifier: String {
////        get {
////            return self.userID
////        } set {
////            self.userID = newValue
////        }
////    }
//
//    var endpoint: String {
//        return "users/"
//    }
//    var jsonValue: [String: AnyObject] {
//        get{
//            let dictionary = [
//                User.kUserID : self.userID,
//                User.kFirstName : self.firstName,
//                User.kLastName : self.lastName,
//                User.kPhoneNumber : self.phoneNumber
//            ]
//            return dictionary
//        }
//    }
//
//
//    required init?(json: [String: AnyObject], identifier: String) {
//
//        guard let firstName = json[User.kFirstName] as? String,
//            let lastName = json[User.kLastName] as? String,
//            let userID = json[User.kUserID] as? String,
//            let phoneNumber = json[User.kPhoneNumber] as? String else { return nil }
//
//        FirebaseController.getRolesForUserID(userID) { (success, roles) -> Void in
//            if success {
//
//                self.init(userID: userID, firstName: firstName, lastName: lastName, phoneNumber: phoneNumber, roles: roles)
//
//            } else {
//                print("Error getting Roles from Firebase with userID: \"\(userID)\"")
//            }
//        }
//        return nil
//    }

