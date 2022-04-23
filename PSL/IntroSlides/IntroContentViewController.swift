//
//  IntroContentViewController.swift
//  PSL
//
//  Created by MacBook on 02/02/2021.
//

import UIKit

class IntroContentViewController: UIViewController {
    @IBOutlet weak var lblTitleName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var imgMainContent: UIImageView!
    var imageName:String  = ""
    var index:Int =  0
    
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        if screenType == .iPhones_5_5s_5c_SE || screenType == .iPhones_4_4S || screenType == .iPhones_6_6s_7_8{
            imageHeight.constant =  350
        }else{
            imageHeight.constant =  450

        }
        
        if index == 0{
            imageName = "intro1"
            lblTitleName.text = "Online Dictionary"
            lblDescription.text = "Learn the words from the online dictionary."

        }else if index == 1{
            imageName = "intro2"
            lblTitleName.text = "Teacher Tutorials"
            lblDescription.text = "Online Teachers Tutorials of each grade."
        }else if index == 2{
            imageName = "intro3"
            lblTitleName.text = "Stories"
            lblDescription.text = "Engaging Stories for Children."
        }
        
        // Do any additional setup after loading the view.
        if let image: UIImage = UIImage(named: imageName){
            imgMainContent.image = image

        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
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
