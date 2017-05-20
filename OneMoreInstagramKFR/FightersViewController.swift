//
//  FightersViewController.swift
//  OneMoreInstagramKFR
//
//  Created by Artem on 5/17/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import UIKit

class FightersViewController: UIViewController {
    
    @IBOutlet weak var fighterTypeLabel: UILabel!
    @IBOutlet weak var questionLevelLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var fighterFullName: UILabel!
    
    fileprivate let fightersDataModel = FightersDataModel()
    fileprivate var questionStack = Stack<TheFightersQuestion>()
    fileprivate var questionArray = [TheFightersQuestion]()
    fileprivate var isLabelsAndViewsAlreadyFilled: Bool = false

    fileprivate let gradient = CAGradientLayer()
    
    var fightersType: FighterType? //managed in SelectTypeOfFighterViewContr...
    var isSupergame: Bool = false //managed in SelectTypeOfFighterViewContr...
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.instance().setupGradient(gradient: gradient, viewForGradient: self.view, color: UIColor.red)
        //data model completion on retrieved
        fightersDataModel.onGetQuestionStackComplete = {(stack: Stack<TheFightersQuestion>, array: [TheFightersQuestion]) in
            self.useStackAndArray(stack, array, shuffle: false) // supergame shuffle doesnt work properly
            if self.questionStack.items.count > 0 {
                if !self.isLabelsAndViewsAlreadyFilled {
                    let question = self.questionStack.pop()
                    self.imageView.image = question.fighterImage
                    self.fighterFullName.text = question.fighterFullName
                    self.questionLevelLabel.text = question.fighterQuestionLevel.rawValue
                    self.fighterTypeLabel.text = question.fighterType.rawValue
                    self.isLabelsAndViewsAlreadyFilled = true
                    
                    AppDelegate.instance().dismissActivityIndicator()
                }
            }
        }
        
        if isSupergame {
            AppDelegate.instance().showActivityIndicator()
            fightersDataModel.getQuestionsFromServerOrCache(fightersType: FighterType.MMA)
            fightersDataModel.getQuestionsFromServerOrCache(fightersType: FighterType.Boxing)
            fightersDataModel.getQuestionsFromServerOrCache(fightersType: FighterType.K1)
            
        } else {
            if let fightersType = fightersType {
                AppDelegate.instance().showActivityIndicator()
                fightersDataModel.getQuestionsFromServerOrCache(fightersType: fightersType)
            } else { print("fightersType is NIL !!!") }
        }
    }
    
    fileprivate func useStackAndArray(_ stack: Stack<TheFightersQuestion>, _ array: [TheFightersQuestion], shuffle: Bool = false) {
        self.questionStack = stack
        self.questionArray = array
        if shuffle {
            self.questionStack = refreshAndShuffleStack()
        }
    }
    
    fileprivate func refreshAndShuffleStack() -> Stack<TheFightersQuestion> {
        let array = questionArray.shuffled()
        questionStack.items.removeAll()
        for question in array {
            questionStack.push(question)
        }
        return questionStack
    }
    
    @IBAction func refreshButtonPressed(_ sender: UIButton) {
        questionStack = refreshAndShuffleStack()
    }
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if questionStack.items.count > 0 {
            let question = questionStack.pop()
            imageView.image = question.fighterImage
            fighterFullName.text = question.fighterFullName
            questionLevelLabel.text = question.fighterQuestionLevel.rawValue
            fighterTypeLabel.text = question.fighterType.rawValue
        }
    }
}
