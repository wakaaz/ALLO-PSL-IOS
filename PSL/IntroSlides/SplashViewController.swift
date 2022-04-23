//
//  SplashViewController.swift
//  PSL
//
//  Created by MacBook on 30/03/2021.
//

import UIKit
import SwiftQueue

class SplashViewController: UIViewController {

    @IBOutlet weak var modalView: SpringView!
    override func viewDidLoad() {
        super.viewDidLoad()
      //  self.view.backgroundColor = UIColor.red

        createJob()
        // Do any additional setup after loading the view.
       print("pri9nt")
       /* DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
           
            if  AuthenticationPreference.getIntroApp(){
               // self.performSegue(withIdentifier: "path1", sender: self)
                let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewcontroller:DashboardTabBarViewController  = mainstoryboard.instantiateViewController(withIdentifier: "DashboardTabBarViewController") as! DashboardTabBarViewController
                self.navigationController?.pushViewController(newViewcontroller, animated: true)
                
            }else{
               // self.performSegue(withIdentifier: "path2", sender: self)
                let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewcontroller:DemoViewController  = mainstoryboard.instantiateViewController(withIdentifier: "DemoViewController") as! DemoViewController
                self.navigationController?.pushViewController(newViewcontroller, animated: true)
                
            }
            
            
                }*/
        setOptions()
      
           
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.view.backgroundColor = .white

        self.navigationController?.isNavigationBarHidden = true

    }
    func createJob(){
        let jobmanager = SwiftQueueManagerBuilder(creator: AuthjobCreator()).build()
      
        JobBuilder(type: AuthJob.type)
                // Requires internet to run
                .internet(atLeast: .cellular)
                // params of my job
                .with(params: ["content": "Hello world"])
                // Add to queue manager
                .schedule(manager: jobmanager)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func setOptions() {
       modalView.force = 1.0
        modalView.duration = 2.0
        modalView.delay = 0.0
        
        modalView.damping = 0.7
        modalView.velocity = 0.7
        modalView.scaleX = 1.0
        modalView.scaleY = 1.0
        modalView.x = 0.0
        modalView.y = 0.0
        modalView.rotate = 0.0
        
        modalView.animation = "fadeInUp"
        modalView.curve = "easeIn"
        
        modalView.animate()
        //modalView.
        /*modalView.animateToNext(completion: {
          print("hello")
            if  AuthenticationPreference.getIntroApp(){
               // self.performSegue(withIdentifier: "path1", sender: self)
                let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewcontroller:DashboardTabBarViewController  = mainstoryboard.instantiateViewController(withIdentifier: "DashboardTabBarViewController") as! DashboardTabBarViewController
                self.navigationController?.pushViewController(newViewcontroller, animated: true)
                
            }else{
               // self.performSegue(withIdentifier: "path2", sender: self)
                let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewcontroller:DemoViewController  = mainstoryboard.instantiateViewController(withIdentifier: "DemoViewController") as! DemoViewController
                self.navigationController?.pushViewController(newViewcontroller, animated: true)
                
            }
        })*/
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            
             if  AuthenticationPreference.getIntroApp(){
                // self.performSegue(withIdentifier: "path1", sender: self)
                 let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                 let newViewcontroller:DashboardTabBarViewController  = mainstoryboard.instantiateViewController(withIdentifier: "DashboardTabBarViewController") as! DashboardTabBarViewController
                 self.navigationController?.pushViewController(newViewcontroller, animated: true)
                 
             }else{
                // self.performSegue(withIdentifier: "path2", sender: self)
                 let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                 let newViewcontroller:DemoViewController  = mainstoryboard.instantiateViewController(withIdentifier: "DemoViewController") as! DemoViewController
                 self.navigationController?.pushViewController(newViewcontroller, animated: true)
                 
             }
             
             
                 }
    }
}
