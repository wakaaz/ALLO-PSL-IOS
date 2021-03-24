//
//  DictionaryCategory.swift
//  Model Generated using http://www.jsoncafe.com/ 
//  Created on March 23, 2021

import Foundation

struct DictionaryCategory : Decodable {

        let id : Int?
        let image : String?
        let title : String?
        let videos : Int?

        enum CodingKeys: String, CodingKey {
                case id = "id"
                case image = "image"
                case title = "title"
                case videos = "videos"
        }
    
        init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                id = try values.decodeIfPresent(Int.self, forKey: .id)
                image = try values.decodeIfPresent(String.self, forKey: .image)
                title = try values.decodeIfPresent(String.self, forKey: .title)
                videos = try values.decodeIfPresent(Int.self, forKey: .videos)
        }

}
