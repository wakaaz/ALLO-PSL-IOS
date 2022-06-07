//
//  AppDelegate.swift
//  PSL
//
//  Created by MacBook on 01/02/2021.
//

import UIKit
import CoreData
import FirebaseCore
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var backgroundSessionCompletionHandler : (() -> Void)?

    var window: UIWindow?
    var navController: UINavigationController?
    var coreDataManager:CoreDataManager?
    
    var orientationLock = UIInterfaceOrientationMask.all

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
       
        
         if #available(iOS 13.0, *) {
             window?.overrideUserInterfaceStyle = .light

             // In iOS 13 setup is done in SceneDelegate
         } else {
             self.window?.makeKeyAndVisible()
         }
      
        if #available(iOS 13.0, *) {
            // In iOS 13 setup is done in SceneDelegate
            // 
            
            
            
        } else {
            
            
            
           
            
          /*  let window = UIWindow(frame: UIScreen.main.bounds)
             self.window = window
            navController = UINavigationController()
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil) // this assumes your storyboard is titled "Main.storyboard"
            // Check Which Controller user Shoukld move ==================================================================
            if AuthenticationPreference.getIntroApp(){
               
                    let yourVC = mainStoryboard.instantiateViewController(withIdentifier: "IntroPageViewController") as! IntroPageViewController //
                    self.navController!.pushViewController(yourVC, animated: false)
                
                
            }
            else{
                let yourVC = mainStoryboard.instantiateViewController(withIdentifier: "DashboardTabBarViewController") as! DashboardTabBarViewController //
                self.navController!.pushViewController(yourVC, animated: false)
            }
            
            // UIApplication.shared.statusBarStyle = .lightContent
            navController?.isNavigationBarHidden = true
            self.window!.rootViewController = navController
            self.navController?.interactivePopGestureRecognizer?.isEnabled = true
            self.window!.backgroundColor = UIColor.white
            self.window!.makeKeyAndVisible()*/
            
            
        }
              
        
        FirebaseApp.configure()

        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if #available(iOS 13.0, *) {
            // In iOS 13 setup is done in SceneDelegate
        } else {
            /*let window = UIWindow(frame: UIScreen.main.bounds)
            self.window = window
            navController = UINavigationController()
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil) // this assumes your storyboard is titled "Main.storyboard"
            // Check Which Controller user Shoukld move ==================================================================
           /* if AuthenticationPreference.userLogin(){
                let yourVC = mainStoryboard.instantiateViewController(withIdentifier: "AttendanceViewController") as! AttendanceViewController //
                self.navController!.pushViewController(yourVC, animated: false)
            }else{*/
              /*  let yourVC = mainStoryboard.instantiateViewController(withIdentifier: "DashboardTabBarViewController") as! DashboardTabBarViewController //
                self.pushViewController(yourVC, animated: false)*/
         //   }
        
             
            // UIApplication.shared.statusBarStyle = .lightContent
            self.window!.rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "SplashViewController") as! SplashViewController
          //  self.navController?.interactivePopGestureRecognizer?.isEnabled = true
            self.window!.backgroundColor = UIColor.white
            self.window!.makeKeyAndVisible()
             
            */
          

        }
        
        return true
    }
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        backgroundSessionCompletionHandler = completionHandler
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0;

    }
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
            return self.orientationLock
    }
}

