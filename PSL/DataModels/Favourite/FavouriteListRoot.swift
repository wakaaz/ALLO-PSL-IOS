//
//  FavouriteListRoot.swift
//  Model Generated using http://www.jsoncafe.com/ 
//  Created on March 27, 2021

import Foundation

struct FavouriteListRoot : Decodable {

        let code : Int?
        let data : [Datum]?
        let message : String?
        let responseMsg : String?

        enum CodingKeys: String, CodingKey {
                case code = "code"
                case data = "data"
                case message = "message"
                case responseMsg = "response_msg"
        }
    
        init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                code = try values.decodeIfPresent(Int.self, forKey: .code)
                data = try values.decodeIfPresent([Datum].self, forKey: .data)
                message = try values.decodeIfPresent(String.self, forKey: .message)
                responseMsg = try values.decodeIfPresent(String.self, forKey: .responseMsg)
        }

}
