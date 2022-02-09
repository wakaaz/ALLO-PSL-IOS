//
//  UICommonMethods.swift
//  PSL
//
//  Created by MacBook on 23/03/2021.
//

import UIKit
import Alamofire
class UICommonMethods: NSObject {
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    static func requestServerWithParamsAuthFree(requestCall:String, requestMehtod:String, params:Parameters, completionHandler: ((NSDictionary?, NSError?) -> Void)?)
    {
        let requestURL =  requestCall + ""
        
        var apiMethod : HTTPMethod = .post
        if(requestMehtod.lowercased() == "get") {
            apiMethod = .get
        }
        else if(requestMehtod.lowercased() == "put") {
            apiMethod = .put
        }
        else if(requestMehtod.lowercased() == "post") {
            apiMethod = .post
        }
        
        
        let headers:HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded; charset=utf-8"
        ]
        
        AF.request(requestURL, method: apiMethod, parameters: params, encoding: URLEncoding.httpBody, headers:headers)
            .responseJSON { response in
                
                switch response.result {
                case .success(let JSON):
                    let response = JSON as! NSDictionary
                
                    print(response)
                    
                    
                    
                case .failure(let error):
                    print(error)
                    
                }
            }
    }
    
    
   
    
    static func showAlert(title:String, message:String, viewController:UIViewController){
            let alert = UIAlertController.init(title: NSLocalizedString(title, comment: ""), message: NSLocalizedString(message, comment: ""), preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: UIAlertAction.Style.default)
            { action -> Void in
                // Put your code here
            })
            viewController.present(alert, animated: true, completion: nil)
     }
    static func AddToFavourite(type:Int,id:Int)->Int
    {
        var statusCode:Int = 0
        
        
        var dict_video_id:Int = 0
        var tut_video_id:Int = 0
        var lesson_video_id:Int = 0
        var story_video_id:Int = 0
        var learning_video_id:Int = 0

        if type == UIContant.TYPE_DICTIONARY{
            dict_video_id  =  id
        }else if type == UIContant.TYPE_TEACHER{
            tut_video_id  =  id

        }else if type == UIContant.TYPE_STORIES{
            story_video_id  =  id

        }else if type == UIContant.TYPE_LEARNING{
            learning_video_id  =  id

        }else if type == UIContant.TYPE_SKILL{
            lesson_video_id =  id

        }
        let headers: HTTPHeaders = [
            "session": AuthenticationPreference.getSession(),
            "userType": UIContant.GUEST_USER
        ]
        let parameter:  Parameters = ["dict_video_id":dict_video_id,"tut_video_id":tut_video_id,"lesson_video_id":lesson_video_id,"story_video_id":story_video_id,"learning_tut_video_id":learning_video_id]
        print(parameter)
        
        AF.request(UIContant.ADD_FAVOURITE, method: .post, parameters: parameter, encoding: URLEncoding(destination: .methodDependent),headers: headers).responseDecodable(of: FavouriteRoot.self)  { response in
            print(response)
            switch response.result {
            
            case .success:
                guard let model = response.value else { return }
                if let responseCode = model.code {
                    statusCode = responseCode

                }
            case .failure(let error):
                print(error)
                
                
            }
        }
        return statusCode
    }
    static func RemoveToFavourite(type:Int,id:Int)->Int
    {
        var statusCode:Int = 0
        
        
        
        
        var dict_video_id:Int = 0
        var tut_video_id:Int = 0
        var lesson_video_id:Int = 0
        var story_video_id:Int = 0
        var learning_video_id:Int = 0

        if type == UIContant.TYPE_DICTIONARY{
            dict_video_id  =  id
        }else if type == UIContant.TYPE_TEACHER{
            tut_video_id  =  id

        }else if type == UIContant.TYPE_STORIES{
            story_video_id  =  id

        }else if type == UIContant.TYPE_LEARNING{
            learning_video_id  =  id

        }else if type == UIContant.TYPE_SKILL{
            lesson_video_id =  id

        }
        let headers: HTTPHeaders = [
            "session": AuthenticationPreference.getSession(),
            "userType": UIContant.GUEST_USER
        ]
        let parameter:  Parameters = ["dict_video_id":dict_video_id,"tut_video_id":tut_video_id,"lesson_video_id":lesson_video_id,"story_video_id":story_video_id,"learning_tut_video_id":learning_video_id]
        print(parameter)
        
        AF.request(UIContant.REMOVE_FAVOURITE, method: .post, parameters: parameter, encoding: URLEncoding(destination: .methodDependent),headers: headers).responseDecodable(of: FavouriteRoot.self)  { response in
            print(response)
            switch response.result {
            
            case .success:
                guard let model = response.value else { return }
                if let responseCode = model.code {
                    statusCode = responseCode

                }
            case .failure(let error):
                print(error)
                
                
            }
        }
        return statusCode
    }
}

extension UITableView {
    
    @IBInspectable
    var isEmptyRowsHidden: Bool {
        get {
            return tableFooterView != nil
        }
        set {
            if newValue {
                tableFooterView = UIView(frame: .zero)
            } else {
                tableFooterView = nil
            }
        }
    }
}
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
extension UIColor {
    
    /// Easily define two colors for both light and dark mode.
    /// - Parameters:
    ///   - lightMode: The color to use in light mode.
    ///   - darkMode: The color to use in dark mode.
    /// - Returns: A dynamic color that uses both given colors respectively for the given user interface style.
    static func bothColor (lightMode: UIColor, darkMode: UIColor) -> UIColor {
        guard #available(iOS 13.0, *) else { return lightMode }
            
        return UIColor { (traitCollection) -> UIColor in
            return traitCollection.userInterfaceStyle == .light ? lightMode : darkMode
        }
    }
}
extension NSString {
    private static let slugSafeCharacters = CharacterSet(charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-")

    public func convertedToSlug() -> NSString? {
        if let latin = self.applyingTransform(StringTransform("Any-Latin; Latin-ASCII; Lower;"), reverse: false) {
            let urlComponents = latin.components(separatedBy: NSString.slugSafeCharacters.inverted)
            let result = urlComponents.filter { $0 != "" }.joined(separator: "-")

            if result.count > 0 {
                return result as NSString
            }
        }

        return nil
    }
    
   
}
extension String {
    private static let slugSafeCharacters = CharacterSet(charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-")

    func firstCharacterUpperCase() -> String? {
        guard !isEmpty else { return nil }
        let lowerCasedString = self.lowercased()
        return lowerCasedString.replacingCharacters(in: lowerCasedString.startIndex...lowerCasedString.startIndex, with: String(lowerCasedString[lowerCasedString.startIndex]).uppercased())
    }
   
    
    func doStringContainsNumber( _string : String) -> Bool{

        var containsNumber: Bool =  false
        //    let numberRegEx  = "[0-9]"
          //  let testCase = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
         // var containsNumber = testCase.evaluate(with: _string)
        if let number = Int(_string)
         {
           containsNumber =  true

         }
         else
         {
            containsNumber =  false
         }
        return containsNumber
    }
     
   
}
protocol dataloaded {
    func dataisLoad(load:Bool) -> String
}



