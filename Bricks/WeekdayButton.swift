//
//  WeekdayButton.swift
//  GoalsForRoles
//
//  Created by Benjamin Arthur Patch on 4/15/16.
//  Copyright © 2016 PatchWork. All rights reserved.
//

import UIKit

protocol WeekdayButtonDelegate {
    func buttonTapped(_ weekdayButton: WeekdayButton)
}

class WeekdayButton: UIView {
    
    // MARK: Class Methods
    
    class func makeForAllWeekdaysInWeek(_ week: (sunday: Date, saturday: Date), disableFutureDates: Bool = true, weekdaysApplicable: [Weekday] = Weekday.getAllWeekdays(), settingsEditMode: Bool = false, delegate: WeekdayButtonDelegate? = nil, goal: Goal?) -> [WeekdayButton] {
        var weekdayButtons = [WeekdayButton]()
        
        for weekday in Weekday.getAllWeekdays() {
            let date: Date = DateController.dateForDayOfWeek(weekday.rawValue, weekStartDate: week.sunday)
            let weekdayButton = WeekdayButton.make(date, disableIfFutureDate: disableFutureDates, weekdaysApplicable: weekdaysApplicable, settingsEditMode: settingsEditMode, delegate: delegate, goal: goal)
            weekdayButtons.append(weekdayButton)
        }
        
        return weekdayButtons
    }
    
    class func make(_ date: Date, isSelected: Bool = false, disableIfFutureDate: Bool, weekdaysApplicable: [Weekday], settingsEditMode: Bool, delegate: WeekdayButtonDelegate? = nil, goal: Goal?) -> WeekdayButton {
        guard let weekdayButton = Bundle.main.loadNibNamed("WeekdayButton", owner: self, options: nil)?[0] as? WeekdayButton else { fatalError() }
        
        weekdayButton.setupButton(date, isSelected: isSelected, disableIfFutureDate: disableIfFutureDate, weekdaysApplicable: weekdaysApplicable, settingsEditMode: settingsEditMode, delegate: delegate, goal: goal)
        
        return weekdayButton
        
    }
    
    // MARK: - Outlets
    // private outlets to reduce confusion and from the button getting into a bad state.
    @IBOutlet weak fileprivate var button: UIButton!
    @IBOutlet weak fileprivate var imageView: UIImageView!
    
    
    // MARK: - Variables
    var isSelected: Bool = false
    var disableIfFutureDate = false
    var settingsEditMode = true
    var delegate: WeekdayButtonDelegate?
    var date: Date = Date()
    var goal: Goal?
    var weekdaysApplicable = [Weekday]()
    var weekday: Weekday {
        let dayOfWeek = DateController.dayOfWeek(date)
        guard let weekday = Weekday(rawValue: dayOfWeek) else { fatalError() }
        return weekday
    }
    var dateIsInFuture: Bool {
        let week = DateController.weekOfDate(self.date)
        return DateController.datesInFuture(week).contains(self.date)
    }
    var dateIsBeforeCreation: Bool {
        
        guard let goal = self.goal else { return false }
        return !DateController.dateIsLaterThanDate(date, secondDate: goal.dateCreated) && !DateController.dateEqualsDate(date, secondDate: goal.dateCreated)
        
    }
    
    // MARK: - Actions
    @IBAction func buttonTapped(_ sender: UIButton) {
        self.switchChecked()
    }
    
    // MARK: - Methods
    func setupButton(_ date: Date, isSelected: Bool, disableIfFutureDate: Bool, weekdaysApplicable: [Weekday], settingsEditMode: Bool, delegate: WeekdayButtonDelegate?, goal: Goal?) {
        self.disableIfFutureDate = disableIfFutureDate
        self.settingsEditMode = settingsEditMode
        self.date = date
        self.goal = goal
        self.delegate = delegate
        self.weekdaysApplicable = weekdaysApplicable
        if settingsEditMode {
            // if editMode, the cell is "selected" if it is one of the weekdaysApplicable.
            self.switchChecked(weekdaysApplicable.contains(self.weekday))// must be called after self.date is set.
        } else {
            self.switchChecked(isSelected)
        }
        self.disableButtonIfInFutureOrUnapplicable()
        
        
    }
    
    func disableButtonIfInFutureOrUnapplicable() {
        self.button.isHidden = false
        self.imageView.isHidden = false
        
        if (disableIfFutureDate && (dateIsInFuture || dateIsBeforeCreation)) || (!self.settingsEditMode && !weekdaysApplicable.contains(self.weekday)) {
            if disableIfFutureDate && dateIsInFuture {
                self.button.setTitleColor(UIColor.lightGray, for: UIControlState())
            } else if disableIfFutureDate && dateIsBeforeCreation {
                self.button.isHidden = true
                self.imageView.isHidden = true
            }
            assert(self.isSelected == false)
            self.button.isEnabled = false
            self.imageView.alpha = 0
        } else {
            self.button.isEnabled = true
            self.button.setTitleColor(UIColor.black, for: UIControlState())
            self.imageView.alpha = 1.0
        }
        
    }
    
    func switchChecked(_ isSelected: Bool? = nil) {
        
        self.isSelected = isSelected ?? !self.isSelected
        delegate?.buttonTapped(self)
        updateButtonAndImage()
    }
    
    func updateButtonAndImage() {
        guard let unselectedImage = UIImage(named: "uncheckedBox"), let selectedImage = UIImage(named: "checkedBox") else { fatalError() }
        
        if isSelected {
            
            imageView.image = selectedImage
            button.setTitle("", for: UIControlState())
            
        } else {
            
            imageView.image = unselectedImage
            button.setTitle(weekday.getInitialsString(), for: UIControlState())
            
        }
    }
    
}
