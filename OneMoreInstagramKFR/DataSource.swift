 //
 //  DataSource.swift
 //  OneMoreInstagramKFR
 //
 //  Created by Artem on 4/29/17.
 //  Copyright © 2017 ApiqA. All rights reserved.
 //
 
 import Foundation
 import FirebaseStorage
 import FirebaseDatabase
 import UIKit.UIImage
 import UIKit.UIImageView
 import Kingfisher
 
 
 
 extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
 }
 
 // STACK
 struct Stack<Element> {
    var items = [Element]()
    mutating func push(_ item: Element) {
        items.append(item)
    }
    mutating func pop() -> Element {
        return items.removeLast()
    }
 }
 
 extension MutableCollection where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffle() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        for i in startIndex ..< endIndex - 1 {
            let j = Int(arc4random_uniform(UInt32(endIndex - i))) + i
            if i != j {
                swap(&self[i], &self[j])
            }
        }
    }
 }
 
 extension Collection {
    /// Return a copy of `self` with its elements shuffled
    func shuffled() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffle()
        return list
    }
 }

 ///////////////////////////////////////////////
 //*****************CLASS*********************//
 class DataSource {
    
    fileprivate var questionStack = Stack<TheQuestion>()
    fileprivate var questions = [TheQuestion]()
    fileprivate let downloader = ImageDownloader(name: "DOWNLOADER")
    fileprivate let cache = ImageCache(name: "CACHE")
    
    fileprivate var questionTypeDataBaseName = String()
    
    //*************************************// complition handler
    var onGetQuestionStackComplete: ((_ questionStack: Stack<TheQuestion>, _ questionArray: [TheQuestion]) -> Void)?
    //************************************//  retrieving source
    var retrieveFrom: String = "mult_test"
    //************************************//
    
    init() {
        downloader.downloadTimeout = 30
        cache.maxCachePeriodInSecond = -1
        cache.maxDiskCacheSize = 0
        AppDelegate.instance().showActivityIndicator()
    }
    
    func getQuestionsFromServerOrCache() {
        ref.child(retrieveFrom).queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let retrieved = snapshot.value as! [String : AnyObject]
            print("TOTAL COUNT * = \(retrieved.count)")
            self.retrieveOrDownloadQuestions(totalCount: retrieved.count)
        })
        ref.removeAllObservers()
    }
    
    fileprivate func retrieveOrDownloadQuestions(totalCount: Int) {
        print("TOTAL COUNT ** = \(totalCount)")
        var questionsCount = totalCount
        ref.child(retrieveFrom).queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            self.questions.removeAll()
            
            let questions = snapshot.value as! [String : AnyObject]
            
            for(_, value) in questions {
                
                if let retrievedQuestion = value as? [String : Any] {
                    
                    if let questionHeader = retrievedQuestion["questionHeader"] as? String, let questionAnswer = retrievedQuestion["questionAnswer"] as? String, let pathToImage = retrievedQuestion["pathToImage"] as? String, let _ = retrievedQuestion["questionKey"] as? String {
                        let urlToImage = URL(string: pathToImage)!
                        /*** Try to retrieve from Cache ****/
                        self.cache.retrieveImage(forKey: pathToImage, options: nil, completionHandler: { (image_, cacheType) in
                            if let image_ = image_ {
                                print("EXIST in cache.")
                                /*** if image in Cach make new TheQuestion object ****/
                                let question = TheQuestion(image_, questionHeader, questionAnswer)
                                self.questions.append(question)
                                self.questionStack.push(question)
                                questionsCount > 2 ? questionsCount -= 1 : self.cacheRetrieveComplete()
                            } else {    /*** No Cached ****/
                                print("NOT exist in cache.")
                                
                                /*** if no in Cache we download ****/
                                self.downloader.downloadImage(with: urlToImage, options: nil, progressBlock: nil, completionHandler: { (image, error, url, originalData) in
                                    if error != nil {
                                        print(error!.localizedDescription)
                                        self.noInternetConnectionError()
                                        /***/ //MARK: - !<esli zagruzit ne udalos to...>!
                                    }
                                    /*** if image download suceed cache it and make new TheQuestion object ****/
                                    if let image = image {
                                        print("NEW IMAGE DOWNLOADED")
                                        self.cache.store(image, forKey: pathToImage)
                                        let question = TheQuestion(image, questionHeader, questionAnswer)
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
    
    fileprivate func getQuestionsArray() -> [TheQuestion] {
        return self.questions
    }
    
    fileprivate func getShuffledQuestionsArray() -> [TheQuestion] {
        return questions.shuffled()
    }
    
    fileprivate func getShuffledQuestionStack() -> Stack<TheQuestion>? {
        let shuffledArray = getShuffledQuestionsArray()
        var stack = Stack<TheQuestion>()
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
        AppDelegate.instance().dismissActivityIndicator()
    }
    
    fileprivate func cacheRetrieveComplete() {
        print("Retrieve Questions DONE")
        if onGetQuestionStackComplete != nil {
            onGetQuestionStackComplete!(questionStack, questions)
        }
        AppDelegate.instance().dismissActivityIndicator()
    }
 
    /*** PUBLIC ***/// MARK: -PUBLIC
    
    func getQuestionStack() -> Stack<TheQuestion> {
        return self.questionStack
    }
    
    func debugPrintShuffledQuestionArray() {
        let questionArray = getShuffledQuestionsArray()
        for question in questionArray {
            print(question.image.debugDescription + ":::" + question.questionTitle + ":::")
        }
    }
 }
 
 
    
    
    

 
