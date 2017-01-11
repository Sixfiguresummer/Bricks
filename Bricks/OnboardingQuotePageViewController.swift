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
        
        setViewControllers([orderedViewControllers[0]], direction: .forward, animated: true, completion: nil)

        self.didUpdatePageCountClosure?(orderedViewControllers.count)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var didUpdatePageCountClosure: ((_ count: Int) -> Void)?
    
    var didUpdatePageIndexClosure: ((_ index: Int) -> Void)?


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    fileprivate lazy var orderedViewControllers: [UIViewController] = [
        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Quote1"),
        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Quote2"),
//        UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Quote3"),
        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Quote4"),
        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Quote5")
    ]
    
}


extension OnboardingQuotePageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 && orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]

    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
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
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.index(of: firstViewController) {
            guard let closure = didUpdatePageIndexClosure else { return }
            closure(index)
        }
    }

}









