//
//  IntroPageViewController.swift
//  PSL
//
//  Created by MacBook on 02/02/2021.
//

import UIKit

class IntroPageViewController: UIPageViewController, UIPageViewControllerDataSource{
   
    

    var currentPageIndex:Int = 0
    var pageImages = ["intro1","intro2","intro3"]
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        // Do any additional setup after loading the view.
        if let startViewController =  contentViewController(index: 0){
            setViewControllers([startViewController], direction: .forward, animated: false, completion: nil)
        }
    }
    

    func contentViewController(index:Int)->IntroContentViewController?{
        if index < 0 || index >= pageImages.count{
            return nil
        }
        let storyboard = UIStoryboard(name: "Main",bundle: nil)
        if #available(iOS 13.0, *) {
            if let pageContentViewController = storyboard.instantiateViewController(identifier: "IntroContentViewController") as? IntroContentViewController{
                
                return pageContentViewController
            }
        } else {
            // Fallback on earlier versions
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! IntroContentViewController).index
        index = index - 1
        return contentViewController(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! IntroContentViewController).index
        index = index + 1
        return contentViewController(index: index)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
