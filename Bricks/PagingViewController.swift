//
//  PagingViewController.swift
//  GoalsForRoles
//
//  Created by Benjamin Patch on 4/29/16.
//  Copyright © 2016 PatchWork. All rights reserved.
//

import UIKit

class PagingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        doneButton.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var pageControl: UIPageControl!

    @IBOutlet weak var skipButton: UIButton!
    
    @IBOutlet weak var doneButton: UIButton!
    
    
    var isTutorial = true
    var dayViewController: DayViewController?
    
    var superViewController: UIViewController?
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        finishWindow()
    }
    
    @IBAction func skipButtonTapped(sender: AnyObject) {
        finishWindow()
    }
    
    func finishWindow() {
        if isTutorial {
            
            guard let signUpVC = self.storyboard?.instantiateViewControllerWithIdentifier("SignUpViewController") as? SignUpViewController else { fatalError() }
            signUpVC.dayViewController = self.dayViewController
            self.presentViewController(signUpVC, animated: true, completion: nil)
            
        } else {
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let pageViewController = segue.destinationViewController as? OnboardingQuotePageViewController {
            
            pageViewController.didUpdatePageCountClosure = { [weak self] (count: Int) in
                self?.pageControl.numberOfPages = count
            }
            pageViewController.didUpdatePageIndexClosure = { [weak self] (index: Int) in
                self?.pageControl.currentPage = index
                if let pageControl = self?.pageControl where index == pageControl.numberOfPages - 1 {
                    self?.doneButton.hidden = false
//                    self?.skipButton.hidden = true
                } else {
                    self?.doneButton.hidden = true
//                    self?.skipButton.hidden = false
                }
            }
            
        }
    }

}