//
//  RootPreference.swift
//  Model Generated using http://www.jsoncafe.com/ 
//  Created on March 23, 2021

import Foundation

struct RootPreference : Decodable {

        let code : Int?
        let message : String?
        let object : MainPreferences?
        let responseMsg : String?

        enum CodingKeys: String, CodingKey {
                case code = "code"
                case message = "message"
                case object = "object"
                case responseMsg = "response_msg"
        }
    
        init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                code = try values.decodeIfPresent(Int.self, forKey: .code)
                message = try values.decodeIfPresent(String.self, forKey: .message)
                object = try values.decodeIfPresent(MainPreferences.self, forKey: .object)
                responseMsg = try values.decodeIfPresent(String.self, forKey: .responseMsg)
        }

}
