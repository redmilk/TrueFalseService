//
//  TheFightersQuestion.swift
//  OneMoreInstagramKFR
//
//  Created by Artem on 5/17/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import Foundation
import UIKit.UIImage

enum FighterType : String {
    case Boxing = "Boxing"
    case MMA = "MMA"
    case K1 = "K-1"
}

enum QuestionLevel : String {
    case Easy = "Easy"
    case Normal = "Normal"
    case Hard = "Hard"
}

struct TheFightersQuestion {
    static var count: Int = 0
    //private
    fileprivate let fighterFirstName: String
    fileprivate let fighterMiddleName: String?
    fileprivate let fighterLastName: String?
    //public
    let fighterType: FighterType
    let fighterQuestionLevel: QuestionLevel
    let fighterImage: UIImage
    var fighterFullName: String {
        get {
            var fullName = fighterFirstName
            if let fighterMiddleName = fighterMiddleName {
                fullName += " " + fighterMiddleName
            }
            if let fighterLastName = fighterLastName {
                fullName += " " + fighterLastName
            }
            return fullName
        }
    }
    
    init(questionLVL: QuestionLevel, type: FighterType, image: UIImage, firstName: String, middleName: String?, lastName: String?) {
        self.fighterQuestionLevel = questionLVL
        self.fighterType = type
        self.fighterImage = image
        self.fighterFirstName = firstName
        self.fighterMiddleName = middleName
        self.fighterLastName = lastName
        TheFightersQuestion.count += 1
    }
}
