//
//  Object.swift
//  Model Generated using http://www.jsoncafe.com/ 
//  Created on March 23, 2021

import Foundation

struct MainPreferences : Decodable {

        let dictionaryCategories : [DictionaryCategory]?
        let learningTutGrades : [LearningTutGrade]?
        let lifeSkills : [LifeSkill]?
        let storyTypes : [StoryType]?
        let tutGrades : [TutGrade]?

        enum CodingKeys: String, CodingKey {
                case dictionaryCategories = "dictionary_categories"
                case learningTutGrades = "learning_tut_grades"
                case lifeSkills = "life_skills"
                case storyTypes = "story_types"
                case tutGrades = "tut_grades"
        }
    
        init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                dictionaryCategories = try values.decodeIfPresent([DictionaryCategory].self, forKey: .dictionaryCategories)
                learningTutGrades = try values.decodeIfPresent([LearningTutGrade].self, forKey: .learningTutGrades)
                lifeSkills = try values.decodeIfPresent([LifeSkill].self, forKey: .lifeSkills)
                storyTypes = try values.decodeIfPresent([StoryType].self, forKey: .storyTypes)
                tutGrades = try values.decodeIfPresent([TutGrade].self, forKey: .tutGrades)
        }

}
