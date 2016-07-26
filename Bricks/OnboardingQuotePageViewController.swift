//
//  OnboardingQuotePageViewController.swift
//  GoalsForRoles
//
//  Created by Benjamin Patch on 4/29/16.
//  Copyright © 2016 PatchWork. All rights reserved.
//

import UIKit



class OnboardingQuotePageViewController: UIPageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dataSource = self
        delegate = self
        
        setViewControllers([orderedViewControllers[0]], direction: .Forward, animated: true, completion: nil)

        self.didUpdatePageCountClosure?(count: orderedViewControllers.count)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var didUpdatePageCountClosure: ((count: Int) -> Void)?
    
    var didUpdatePageIndexClosure: ((index: Int) -> Void)?


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    private lazy var orderedViewControllers: [UIViewController] = [
        UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Quote1"),
        UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Quote2"),
//        UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Quote3"),
        UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Quote4"),
        UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Quote5")
    ]
    
}


extension OnboardingQuotePageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 && orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]

    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.indexOf(firstViewController) {
            guard let closure = didUpdatePageIndexClosure else { return }
            closure(index: index)
        }
    }

}









