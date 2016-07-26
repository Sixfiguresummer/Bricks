//
//  OnboadingQuoteViewController.swift
//  GoalsForRoles
//
//  Created by Benjamin Patch on 4/29/16.
//  Copyright © 2016 PatchWork. All rights reserved.
//

import UIKit

class OnboadingQuoteViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    let quoteImages: [UIImage] = [
        UIImage(named: "6 Figure App Quotes-14-13")!,
        UIImage(named: "6 Figure App Quotes-14")!,
        UIImage(named: "6 Figure App Quotes-15-15")!,
        UIImage(named: "6 Figure App Quotes-16")!,
        UIImage(named: "6 Figure App Quotes-17")!
    ]
    
}



extension OnboadingQuoteViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return quoteImages.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("QuoteCell", forIndexPath: indexPath) as? QuoteImageCollectionViewCell else { fatalError() }
        
        cell.imageView.image = quoteImages[indexPath.item]

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = self.view.frame.size.width
        let height = width * (751/1335) // aspect ratio of  image.
        return CGSize(width: width, height: height)
    }
    
}





