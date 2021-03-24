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
