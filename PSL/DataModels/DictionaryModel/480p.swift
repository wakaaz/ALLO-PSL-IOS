//
//  480p.swift
//  Model Generated using http://www.jsoncafe.com/ 
//  Created on March 24, 2021

import Foundation

struct 480p : Codable {

        let filesize : String?
        let url : String?

        enum CodingKeys: String, CodingKey {
                case filesize = "filesize"
                case url = "url"
        }
    
        init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                filesize = try values.decodeIfPresent(String.self, forKey: .filesize)
                url = try values.decodeIfPresent(String.self, forKey: .url)
        }

}
