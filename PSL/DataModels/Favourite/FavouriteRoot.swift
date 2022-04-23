//
//  FavouriteRoot.swift
//  Model Generated using http://www.jsoncafe.com/ 
//  Created on March 27, 2021

import Foundation

struct FavouriteRoot : Decodable {

        let code : Int?
        let message : String?
        let responseMsg : String?

        enum CodingKeys: String, CodingKey {
                case code = "code"
                case message = "message"
               case responseMsg = "response_msg"
        }
    
        init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                code = try values.decodeIfPresent(Int.self, forKey: .code)
                message = try values.decodeIfPresent(String.self, forKey: .message)
                responseMsg = try values.decodeIfPresent(String.self, forKey: .responseMsg)
        }

}
