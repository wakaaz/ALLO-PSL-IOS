//
//  DashboardTabBarViewController.swift
//  PSL
//
//  Created by MacBook on 04/03/2021.
//

import UIKit
import Alamofire
class DashboardTabBarViewController: UITabBarController,UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        requestAuth()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func requestAuth(){
        let login :Parameters = [:]
        AF.request(UIContant.SKIP, method: .post, parameters: login, encoding: URLEncoding(destination: .methodDependent)).responseDecodable(of: RootClass.self)  { response in
            print(response)
           
            switch response.result {

            case .success:
                guard let model = response.value else { return }
                guard let innermodel = model.object else { return }
                 AuthenticationPreference.saveAuth(model: innermodel)
            case .failure(let error):
                print(error)
                 AuthenticationPreference.removeAuth()

              //  UICommonMethods.showAlert(title: "Error",message: "Invalid Credential", viewController: self)

            }
        }
    }

}
extension UITabBar{
     func setTransparentTabbar(){
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().clipsToBounds = true


    }
}
extension UIImage {
 class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
