//
//  UICommonMethods.swift
//  PSL
//
//  Created by MacBook on 23/03/2021.
//

import UIKit

class UICommonMethods: NSObject {

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
