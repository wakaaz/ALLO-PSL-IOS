//
//  RootDictionary.swift
//  Model Generated using http://www.jsoncafe.com/ 
//  Created on March 24, 2021

import Foundation

struct RootDictionary : Decodable {

        let code : Int?
        let data : [DictionaryDatum]?
        let message : String?
       // let object : DictionaryObject?
        let responseMsg : String?

        enum CodingKeys: String, CodingKey {
                case code = "code"
                case data = "data"
                case message = "message"
                //case object = "object"
                case responseMsg = "response_msg"
        } 
    
        init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                code = try values.decodeIfPresent(Int.self, forKey: .code)
                data = try values.decodeIfPresent([DictionaryDatum].self, forKey: .data)
                message = try values.decodeIfPresent(String.self, forKey: .message)
               // object = Object(from: decoder)
                responseMsg = try values.decodeIfPresent(String.self, forKey: .responseMsg)
        }

}
