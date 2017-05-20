//
//  FightersDataModel.swift
//  OneMoreInstagramKFR
//
//  Created by Artem on 5/17/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseDatabase
import UIKit.UIImage
import UIKit.UIImageView
import Kingfisher

class FightersDataModel {
    
    fileprivate var questionStack = Stack<TheFightersQuestion>()
    fileprivate var questions = [TheFightersQuestion]()
    fileprivate let downloader = ImageDownloader(name: "DOWNLOADER")
    fileprivate let cache = ImageCache(name: "CACHE")
    
    //*************************************// complition handler
    var onGetQuestionStackComplete: ((_ questionStack: Stack<TheFightersQuestion>, _ questionArray: [TheFightersQuestion]) -> Void)?
    //************************************//  retrieving database destination
    var retrieveFrom: String = "fighters_test"
    //************************************//
    
    init() {
        downloader.downloadTimeout = 30
        cache.maxCachePeriodInSecond = -1
        cache.maxDiskCacheSize = 0
    }
    
    
    
    
    
    /*** PUBLIC *************************************************/// MARK: -PUBLIC
    
    func getQuestionStack() -> Stack<TheFightersQuestion> {
        return self.questionStack
    }
    
    func getQuestionsFromServerOrCache(fightersType: FighterType) {
        ref.child(retrieveFrom).child(fightersType.rawValue).queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let retrieved = snapshot.value as! [String : AnyObject]
            print("Fighters Type: \(fightersType.rawValue) ::: TOTAL COUNT * = \(retrieved.count)")
            self.retrieveOrDownloadQuestions(totalCount: retrieved.count, fightersType: fightersType)
        })
        ref.removeAllObservers()
    }
    /************************************************************/
    
    
    
    
    
    /*** PRIVATE ***/// MARK: -PRIVATE
    //supergame means all fihters types game mode
    fileprivate func retrieveOrDownloadQuestions(totalCount: Int, fightersType: FighterType) {
        print("TOTAL COUNT ** = \(totalCount)")
        var questionsCount = totalCount
        ref.child(retrieveFrom).child(fightersType.rawValue).queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let questions = snapshot.value as! [String : AnyObject]
            
            for(_, value) in questions {
                
                if let retrievedQuestion = value as? [String : Any] {
                    
                    if let questionLevel = retrievedQuestion["questionLevel"] as? String, let fighterType = retrievedQuestion["fighterType"] as? String, let firstName = retrievedQuestion["firstName"] as? String, let middleName = retrievedQuestion["middleName"] as? String, let lastName = retrievedQuestion["lastName"] as? String, let pathToImage = retrievedQuestion["pathToImage"] as? String {
                        print(pathToImage)
                        //url only latin symbols
                        let urlToImage = URL(string: pathToImage)
                        guard urlToImage != nil else {
                            print("BAD URL LINK !!!!!!!")
                            return }
                        /*** Try to retrieve from Cache ****/
                        self.cache.retrieveImage(forKey: pathToImage, options: nil, completionHandler: { (image_, cacheType) in
                            if let image_ = image_ {
                                print("EXIST in cache.")
                                /*** if image in Cach make new TheFightersQuestion object ****/
                                let questionLvlEnum = QuestionLevel(rawValue: questionLevel)
                                let fighterTypeEnum = FighterType(rawValue: fighterType)
                                let _middleName = middleName == "" ? nil : middleName
                                let _lastName = lastName == "" ? nil : lastName
                                let question = TheFightersQuestion(questionLVL: questionLvlEnum!, type: fighterTypeEnum!, image: image_, firstName: firstName, middleName: _middleName, lastName: _lastName)
                                self.questions.append(question)
                                self.questionStack.push(question)
                                //if question more than one
                                questionsCount > 1 ? questionsCount -= 1 : self.cacheRetrieveComplete()
                            } else {    /*** No Cached ****/
                                print("NOT exist in cache.")
                                /*** if no in Cache we download ****/
                                self.downloader.downloadImage(with: urlToImage!, options: nil, progressBlock: nil, completionHandler: { (image, error, url, originalData) in
                                    if error != nil {
                                        print(error!.localizedDescription)
                                        self.noInternetConnectionError()
                                        /***/ //MARK: - !<esli zagruzit ne udalos to...>!
                                    }
                                    /*** if image download suceed cache it and make new TheFightersQuestion object ****/
                                    if let image = image {
                                        print("NEW IMAGE DOWNLOADED")
                                        self.cache.store(image, forKey: pathToImage)
                                        let questionLvlEnum = QuestionLevel(rawValue: questionLevel)
                                        let fighterTypeEnum = FighterType(rawValue: fighterType)
                                        let _middleName = middleName == "" ? nil : middleName
                                        let _lastName = lastName == "" ? nil : lastName
                                        let question = TheFightersQuestion(questionLVL: questionLvlEnum!, type: fighterTypeEnum!, image: image, firstName: firstName, middleName: _middleName, lastName: _lastName)
                                        
                                        self.questions.append(question)
                                        self.questionStack.push(question)
                                        //questionCount > 1 because there is default non-question value in database
                                        questionsCount > 2 ? questionsCount -= 1 : self.downLoadComplete()
                                    }
                                })
                            }
                        })
                    }
                }
            }
        })
        ref.removeAllObservers()
    }
    
    fileprivate func getQuestionsArray() -> [TheFightersQuestion] {
        return self.questions
    }
    
    fileprivate func getShuffledQuestionsArray() -> [TheFightersQuestion] {
        return questions.shuffled()
    }
    
    fileprivate func getShuffledQuestionStack() -> Stack<TheFightersQuestion>? {
        let shuffledArray = getShuffledQuestionsArray()
        var stack = Stack<TheFightersQuestion>()
        for question in shuffledArray {
            stack.push(question)
        }
        return stack.items.count > 0 ? stack : nil
    }
    
    fileprivate func noInternetConnectionError() {
        
    }
    
    fileprivate func downLoadComplete() {
        print("Download Questions DONE")
        if onGetQuestionStackComplete != nil {
            onGetQuestionStackComplete!(questionStack, questions)
        }
    }
    
    fileprivate func cacheRetrieveComplete() {
        print("Retrieve Questions DONE")
        if onGetQuestionStackComplete != nil {
            onGetQuestionStackComplete!(questionStack, questions)
        }
    }
}




