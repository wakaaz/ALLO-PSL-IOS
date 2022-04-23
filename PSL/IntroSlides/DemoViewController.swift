//
//  DemoViewController.swift
//  PSL
//
//  Created by MacBook on 31/03/2021.
//

import UIKit

class DemoViewController: UIViewController,UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    private var pageController: UIPageViewController?
    var pageImages = ["intro1","intro2","intro3"]
    private var currentIndex: Int = 0
    
    @IBOutlet weak var pagerView: UIView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var btnNext: UIButton!
    
    @IBOutlet weak var btnPervious: UIButton!
    
    
    
    
    var viewControllerList = [UIViewController]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnNext.backgroundColor = .clear
        btnNext.layer.cornerRadius = 10
        btnNext.layer.borderWidth = 1
        btnNext.layer.borderColor = UIColor.white.cgColor
        btnNext.titleEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 10,right: 10)
        
        btnPervious.backgroundColor = .clear
        btnPervious.layer.cornerRadius = 10
        btnPervious.layer.borderWidth = 1
        btnPervious.layer.borderColor = UIColor.white.cgColor
        btnPervious.titleEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 10,right: 10)
        btnPervious.isHidden = true
        viewControllerList.removeAll()
        let vc1 = contentViewController(index: 0)
       

        let vc2 = contentViewController(index: 1)
        
        let vc3 = contentViewController(index: 2)
       
        viewControllerList.append(vc1!)
        viewControllerList.append(vc2!)
        viewControllerList.append(vc3!)

        setupPageController()
        // Do any additional setup after loading the view.
    }
    func contentViewController(index:Int)->IntroContentViewController?{
        if index < 0 || index >= pageImages.count{
            return nil
        }
        
        // self.currentIndex =  index
        let storyboard = UIStoryboard(name: "Main",bundle: nil)
        if #available(iOS 13.0, *) {
            if let pageContentViewController = storyboard.instantiateViewController(identifier: "IntroContentViewController") as? IntroContentViewController{
                pageContentViewController.index = index
                
                return pageContentViewController
            }
        } else {
            // Fallback on earlier versions
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let pageContentViewController = storyboard.instantiateViewController(withIdentifier: "IntroContentViewController") as? IntroContentViewController{
                pageContentViewController.index = index
                
                return pageContentViewController
            }
        }
        return nil
    }
    
    
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! IntroContentViewController
        var index = vc.index as Int
        index =  index-1
        print(index)
        if (index == NSNotFound || index < 0){
            return nil
        }
       // return contentViewController(index: index)
        var controller:IntroContentViewController =  viewControllerList[index] as! IntroContentViewController
        
        
        return controller
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! IntroContentViewController
        var index = vc.index as Int
        
        if (index == NSNotFound) {
            return nil
        }
        
        index = index + 1
        
        if (index == self.pageImages.count) {
            //self.btnNext.setTitle("Finish", for: .normal)
            return nil
        } else {
            //self.btnNext.setTitle("Next", for: .normal)
        }
       // return contentViewController(index: index)
        var controller:IntroContentViewController =  viewControllerList[index] as! IntroContentViewController
        
        
        return controller
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.pageImages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool)
    {
        if (!completed)
        {
            return
            
        }
        if let currentViewController = pageViewController.viewControllers![0] as? IntroContentViewController {
            pageControl.currentPage = currentViewController.index//Page Index
            self.currentIndex = currentViewController.index
            if currentIndex <= 0{
                btnPervious.isHidden =  true
            }else{
                btnPervious.isHidden =  false
                
            }
        }
        //   print(pageViewControllercurrentIndex)
        
    }
    
    private func setupPageController() {
        self.pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageController?.dataSource = self
        self.pageController?.delegate = self
        self.pageController?.view.backgroundColor = .clear
        print(UIScreen.main.bounds.width)
        
        var widthcount:Int = 0
        if screenType == .iPhones_5_5s_5c_SE || screenType == .iPhones_4_4S || screenType == .iPhones_6_6s_7_8{
            widthcount =  40
        }
        
        self.pageController?.view.frame = CGRect(x: 0,y: 0,width: self.view.frame.width+CGFloat(widthcount),height: self.view.frame.height)
        self.addChild(self.pageController!)
        self.pagerView.addSubview(self.pageController!.view)
        pageControl.numberOfPages  = pageImages.count
        self.pageController?.didMove(toParent: self)
        
       // if let startViewController =  contentViewController(index: 0){
            self.pageController?.setViewControllers([viewControllerList[0]], direction: .forward, animated: false, completion: nil)
       // }
    }
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func onTappedNext(_ sender: Any) {
        
        var index =  currentIndex
        index =  index+1
        print(index)
        if (index == NSNotFound) {
            return
        }
        if index >= pageImages.count{
            
            
            
            
            AuthenticationPreference.setintroApp(value: true)
            let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewcontroller:DashboardTabBarViewController  = mainstoryboard.instantiateViewController(withIdentifier: "DashboardTabBarViewController") as! DashboardTabBarViewController
            self.navigationController?.pushViewController(newViewcontroller, animated: true)
            
            
            
        }else{
           
           displayPageForwardForIndex(index: index)
            pageControl.currentPage = index//Page Index
            self.currentIndex = index
            if currentIndex <= 0{
                btnPervious.isHidden =  true
            }else{
                btnPervious.isHidden =  false
                
            }
        }
        
        
        
        
    }
    
    @IBAction func onTappedPervious(_ sender: Any) {
        var index =  currentIndex
        
        
        index =  index-1
        print(index)
        if (index == NSNotFound) {
            return
        }
        if index < 0{
            
        }else{
            
            pageControl.currentPage = index//Page Index
            self.currentIndex = index
            if currentIndex <= 0{
                btnPervious.isHidden =  true
            }else{
                btnPervious.isHidden =  false
                
            }
           displayPageBackwardForIndex(index: index)
        }
        
    }
    
    
    func displayPageForwardForIndex(index: Int, animated: Bool = true) {
       // if let thirdViewController = viewControllerList.last {
        self.pageController?.setViewControllers([viewControllerList[index]], direction: .forward, animated: false, completion: nil)
           //}
        // nop if index == self.currentPageIndex
       // let viewcontroller:IntroContentViewController = contentViewController(index: index)  as! IntroContentViewController
        
       // self.pageController?.setViewControllers([viewcontroller], direction: .forward, animated: true, completion: nil)
        //self.pageController.displayPageForIndex(index)
        //self.pageController?.next
    }
    
    func displayPageBackwardForIndex(index: Int, animated: Bool = true) {
        
        // nop if index == self.currentPageIndex
        self.pageController?.setViewControllers([viewControllerList[index]], direction: .reverse, animated: false, completion: nil)

        
        
        
        
    }
    enum ScreenType: String {
           case iPhones_4_4S = "iPhone 4 or iPhone 4S"
           case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
           case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
           case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
           case iPhones_X_XS = "iPhone X or iPhone XS"
           case iPhone_XR = "iPhone XR"
           case iPhone_XSMax = "iPhone XS Max"
           case unknown
       }

       var screenType: ScreenType {
           switch UIScreen.main.nativeBounds.height {
           case 960:
               return .iPhones_4_4S
           case 1136:
               return .iPhones_5_5s_5c_SE
           case 1334:
               return .iPhones_6_6s_7_8
           case 1792:
               return .iPhone_XR
           case 1920, 2208:
               return .iPhones_6Plus_6sPlus_7Plus_8Plus
           case 2436:
               return .iPhones_X_XS
           case 2688:
               return .iPhone_XSMax
           default:
               return .unknown
           }
       }
}
