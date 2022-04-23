//
//  Datum.swift
//  Model Generated using http://www.jsoncafe.com/ 
//  Created on March 24, 2021

import Foundation

struct DictionaryDatum : Decodable {

        let quality1080p : VideoQuality?
        let quality240p : VideoQuality?
        let quality360p : VideoQuality?
        let quality480p : VideoQuality?
        let quality720p : VideoQuality?
        let categoryId : Int?
        let duration : String?
        let englishWord : String?
        var favorite : Int?
        let filename : String?
        let id : Int?
        let poster : String?
        let urduWord : String?
        let vimeoLink : String?
        let youtubeLink : String?
        let title : String?
        let gradeId : Int?
        let parent : Int?
        let subjectId : Int?
        let shareablURL : String?
        let language : String?
        let documents : [Document]?


        enum CodingKeys: String, CodingKey {
                case quality1080p = "1080p"
                case quality240p = "240p"
                case quality360p = "360p"
                case quality480p = "480p"
                case quality720p = "720p"
                case categoryId = "category_id"
                case duration = "duration"
                case englishWord = "english_word"
                case favorite = "favorite"
                case filename = "filename"
                case id = "id"
                case poster = "poster"
                case urduWord = "urdu_word"
                case vimeoLink = "vimeo_link"
                case youtubeLink = "youtube_link"
                case title = "title"
                case gradeId = "grade_id"
                case subjectId = "subject_id"
                case shareablURL = "shareablURL"
                case language = "language"
                case documents = "documents"
                case parent = "parent"
        }
    
        init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                quality1080p = try values.decodeIfPresent(VideoQuality.self, forKey: .quality1080p)
                quality240p = try values.decodeIfPresent(VideoQuality.self, forKey: .quality240p)
                quality360p = try values.decodeIfPresent(VideoQuality.self, forKey: .quality360p)
                quality480p = try values.decodeIfPresent(VideoQuality.self, forKey: .quality480p)
                quality720p = try values.decodeIfPresent(VideoQuality.self, forKey: .quality720p)
                categoryId = try values.decodeIfPresent(Int.self, forKey: .categoryId)
                duration = try values.decodeIfPresent(String.self, forKey: .duration)
                englishWord = try values.decodeIfPresent(String.self, forKey: .englishWord)
                favorite = try values.decodeIfPresent(Int.self, forKey: .favorite)
                filename = try values.decodeIfPresent(String.self, forKey: .filename)
                id = try values.decodeIfPresent(Int.self, forKey: .id)
                poster = try values.decodeIfPresent(String.self, forKey: .poster)
                urduWord = try values.decodeIfPresent(String.self, forKey: .urduWord)
                vimeoLink = try values.decodeIfPresent(String.self, forKey: .vimeoLink)
                youtubeLink = try values.decodeIfPresent(String.self, forKey: .youtubeLink)
                title = try values.decodeIfPresent(String.self, forKey: .title)
                gradeId = try values.decodeIfPresent(Int.self, forKey: .gradeId)
                subjectId = try values.decodeIfPresent(Int.self, forKey: .subjectId)
                shareablURL = try values.decodeIfPresent(String.self, forKey: .shareablURL)
                language = try values.decodeIfPresent(String.self, forKey: .language)
                documents = try values.decodeIfPresent([Document].self, forKey: .documents)
                parent = try values.decodeIfPresent(Int.self, forKey: .parent)
    }

}
