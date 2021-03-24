//
//  Subject.swift
//  Model Generated using http://www.jsoncafe.com/ 
//  Created on March 23, 2021

import Foundation

struct Subject : Decodable {

        let gradeId : Int?
        let icon : String?
        let id : Int?
        let title : String?
        let videos : Int?

        enum CodingKeys: String, CodingKey {
                case gradeId = "grade_id"
                case icon = "icon"
                case id = "id"
                case title = "title"
                case videos = "videos"
        }
    
        init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                gradeId = try values.decodeIfPresent(Int.self, forKey: .gradeId)
                icon = try values.decodeIfPresent(String.self, forKey: .icon)
                id = try values.decodeIfPresent(Int.self, forKey: .id)
                title = try values.decodeIfPresent(String.self, forKey: .title)
                videos = try values.decodeIfPresent(Int.self, forKey: .videos)
        }

}
