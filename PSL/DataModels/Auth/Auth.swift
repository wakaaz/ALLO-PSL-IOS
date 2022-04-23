//
//  Object.swift
//  Model Generated using http://www.jsoncafe.com/ 
//  Created on March 23, 2021

import Foundation


struct Auth : Decodable {

        let id : Int?
        let session : String?

        enum CodingKeys: String, CodingKey {
                case id = "id"
                case session = "session"
        }
    
        init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                id = try values.decodeIfPresent(Int.self, forKey: .id)
                session = try values.decodeIfPresent(String.self, forKey: .session)
        }

}
