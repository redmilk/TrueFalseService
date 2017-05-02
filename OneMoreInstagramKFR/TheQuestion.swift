//
//  TheQuestion.swift
//  FightersTrivia
//
//  Created by Artem on 2/24/17.
//  Copyright © 2017 apiqa. All rights reserved.
//

import Foundation
import UIKit.UIImage

class TheQuestion: NSObject {
    
    var image: UIImage
    var questionTitle: String
    let rightAnswer: String
    
    init(_ image: UIImage, _ questionTittle: String, _ rightAnswer: String) {
        self.image = image
        self.questionTitle = questionTittle
        self.rightAnswer = rightAnswer
    }
}
