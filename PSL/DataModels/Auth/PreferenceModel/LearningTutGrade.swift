//
//  LearningTutGrade.swift
//  Model Generated using http://www.jsoncafe.com/ 
//  Created on March 23, 2021

import Foundation

struct LearningTutGrade : Decodable {

        let grade : String?
        let icon : String?
        let id : Int?
        let subjects : [Subject]?

        enum CodingKeys: String, CodingKey {
                case grade = "grade"
                case icon = "icon"
                case id = "id"
                case subjects = "subjects"
        }
    
        init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                grade = try values.decodeIfPresent(String.self, forKey: .grade)
                icon = try values.decodeIfPresent(String.self, forKey: .icon)
                id = try values.decodeIfPresent(Int.self, forKey: .id)
                subjects = try values.decodeIfPresent([Subject].self, forKey: .subjects)
        }

}
