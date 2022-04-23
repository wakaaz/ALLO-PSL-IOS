//
//  Datum.swift
//  Model Generated using http://www.jsoncafe.com/ 
//  Created on March 27, 2021

import Foundation

struct Datum : Decodable {

        let createdAt : String?
        let dictVideoId : Int?
        let dictionary : DictionaryDatum?
        let guestId : Int?
        let id : Int?
        let learningTutVideoId : Int?
        let lessonVideoId : Int?
        let story : DictionaryDatum?
        let storyVideoId : Int?
        let tutVideoId : Int?
        let tutorial : DictionaryDatum?
        let watchedTill : String?
        let learningTutorial : DictionaryDatum?
        let lesson : DictionaryDatum?
        enum CodingKeys: String, CodingKey {
                case createdAt = "created_at"
                case dictVideoId = "dict_video_id"
                case dictionary = "dictionary"
                case guestId = "guest_id"
                case id = "id"
                case learningTutVideoId = "learning_tut_video_id"
                case lessonVideoId = "lesson_video_id"
                case story = "story"
                case storyVideoId = "story_video_id"
                case tutVideoId = "tut_video_id"
                case tutorial = "tutorial"
                case watchedTill = "watched_till"
                case learningTutorial = "learning_tutorial"
                case lesson = "lesson"
        }
    
        init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
                
                dictVideoId = try values.decodeIfPresent(Int.self, forKey: .dictVideoId)
                dictionary = try values.decodeIfPresent(DictionaryDatum.self, forKey: .dictionary)

                guestId = try values.decodeIfPresent(Int.self, forKey: .guestId)
                id = try values.decodeIfPresent(Int.self, forKey: .id)
                learningTutVideoId = try values.decodeIfPresent(Int.self, forKey: .learningTutVideoId)
                lessonVideoId = try values.decodeIfPresent(Int.self, forKey: .lessonVideoId)
            story = try values.decodeIfPresent(DictionaryDatum.self, forKey: .story)
                storyVideoId = try values.decodeIfPresent(Int.self, forKey: .storyVideoId)
                tutVideoId = try values.decodeIfPresent(Int.self, forKey: .tutVideoId)
                    tutorial = try values.decodeIfPresent(DictionaryDatum.self, forKey: .tutorial)

                watchedTill = try values.decodeIfPresent(String.self, forKey: .watchedTill)
            learningTutorial = try values.decodeIfPresent(DictionaryDatum.self, forKey: .learningTutorial)
            lesson = try values.decodeIfPresent(DictionaryDatum.self, forKey: .lesson)

            
        }

}
