//
//  Document.swift
//  Model Generated using http://www.jsoncafe.com/ 
//  Created on July 14, 2021

import Foundation

struct Document : Codable {

        let name : String?
        let url : String?

        enum CodingKeys: String, CodingKey {
                case name = "name"
                case url = "url"
        }
    
        init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                name = try values.decodeIfPresent(String.self, forKey: .name)
                url = try values.decodeIfPresent(String.self, forKey: .url)
        }

}
