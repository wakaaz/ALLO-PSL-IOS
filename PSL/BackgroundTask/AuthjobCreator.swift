//
//  AuthjobCreator.swift
//  PSL
//
//  Created by MacBook on 26/03/2021.
//

import UIKit
import SwiftQueue
class AuthjobCreator: JobCreator {
    
    
    func create(type: String, params: [String: Any]?) -> Job {
            // check for job and params type
               print("job create")

            if type == AuthJob.type  {
                return AuthJob(params: params ?? ["hello":"hello"])
            }else if type == CategoriesJob.type  {
                return CategoriesJob(params: params ?? ["":""])
            }else {
                // Nothing match
                // You can use `fatalError` or create an empty job to report this issue.
                fatalError("No Job !")
            }
        }

}
