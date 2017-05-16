//
//  ViewController.swift
//  OneMoreInstagramKFR
//
//  Created by Artem on 4/28/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var questionAnswer: UILabel!
    @IBOutlet weak var questionImage: UIImageView!
    
    var dataSource = DataSource()
    
    var questionStack = Stack<TheQuestion>()
    var questionArray = [TheQuestion]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.onGetQuestionStackComplete = {(stack: Stack<TheQuestion>, array: [TheQuestion]) in
            self.useStackAndArray(stack, array)
            if self.questionStack.items.count > 0 {
                let question = self.questionStack.pop()
                self.questionImage.image = question.image
                self.questionTitle.text = question.questionTitle
                self.questionAnswer.text = question.rightAnswer
            }
        }
        dataSource.getQuestionsFromServerOrCache()
    }

    fileprivate func refreshAndShuffleStack() -> Stack<TheQuestion>{
        let array = questionArray.shuffled()
        questionStack.items.removeAll()
        for question in array {
            questionStack.push(question)
        }
        return questionStack
    }
    
    fileprivate func useStackAndArray(_ stack: Stack<TheQuestion>, _ array: [TheQuestion]) {
        self.questionStack = stack
        self.questionArray = array
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func prevPressed(_ sender: Any) {
        questionStack = refreshAndShuffleStack()
    }
    @IBAction func nextPressed(_ sender: Any) {
        if questionStack.items.count > 0 {
            let question = questionStack.pop()
            questionImage.image  = question.image
            questionTitle.text = question.questionTitle
            questionAnswer.text = question.rightAnswer
        }
    }
    
}

