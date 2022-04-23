//
//  UIContant.swift
//  AllomateAttendance
//
//  Created by MacBook on 22/12/2020.
//

import UIKit

class UIContant: NSObject {
    /*
     End point
     */
    // http://admin.aajkaadin.com/api/
    // debug http://psl.am7.studio/api/
    // live url https://admin.pslmonitoringserver.com/api/
    static let BASE_URL = "https://admin.aajkaadin.com/api/"
    static let SKIP =  BASE_URL+"GuestLogin"
    static let PREFERENCE = BASE_URL+"Preferences"
    static let DICTIONARY = BASE_URL+"Dictionary"
    static let TEACHER_TUTORIAL =  BASE_URL+"Tutorials"
    static let Stories = BASE_URL+"Stories"
    static let LEARNING = BASE_URL+"LearningTutorials"
    static let LESSONS =  BASE_URL+"Lessons"
    static let ADD_FAVOURITE =  BASE_URL+"AddToFavorites"
    static let REMOVE_FAVOURITE =  BASE_URL+"RemoveFromFavorites"
    static let FAVOURITE =  BASE_URL+"Favorites"
    static let RECOMMENDEDWORD   = BASE_URL+"RecommendAWord"
    
    
    /*
     User Type
     */
    
    static let GUEST_USER =  "guest"
    
    /*
     Screens Type
     */
    
    static let TYPE_DICTIONARY =  1
    static let TYPE_TEACHER =  2
    static let TYPE_STORIES =  3
    static let TYPE_LEARNING =  4
    static let TYPE_SKILL =  5


    static let imageSize = CGSize(width:400, height: 400)
    

}
