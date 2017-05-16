//
//  TestMakeViewController.swift
//  OneMoreInstagramKFR
//
//  Created by Artem on 5/16/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

class TestMakeViewController: UIViewController {
    
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var titleAsAnswerTextfield: UITextField!
    @IBOutlet weak var imageLinkTextField: UITextField!
    
    var gradient: CAGradientLayer!
    
    var databaseDirection: String = "mult_test"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        destinationLabel.text = databaseDirection
        self.setupGradient()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        destinationLabel.layer.borderWidth = 0.5
        destinationLabel.layer.borderColor = UIColor.black.cgColor
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        AppDelegate.instance().showActivityIndicator()
        let key = ref.child(databaseDirection).childByAutoId().key
        guard imageLinkTextField.text != nil else {
            print("doneButtonPressed: imageLinkTextField.text == nil")
            return
        }
        guard titleAsAnswerTextfield.text != nil else {
            print("doneButtonPressed: titleAsAnswerTextfield.text == nil")
            return
        }
        
        guard (imageLinkTextField.text?.contains("https://"))! else {
            print("doneButtonPressed: imageLinkTextField doenst contain https://")
            return
        }
        
        //let url = URL(fileURLWithPath: imageLinkTextField.text!)
        let questionInfo = ["questionHeader" : self.titleAsAnswerTextfield.text!,
                            "questionAnswer" : self.titleAsAnswerTextfield.text!,
                            "pathToImage" : imageLinkTextField.text!,
                            "questionKey" : key] as [String : Any]
        let questionComplete = ["\(key)" : questionInfo]
        ref.child(self.databaseDirection).updateChildValues(questionComplete)
        AppDelegate.instance().dismissActivityIndicator()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func fightersTestDestinationPressed(_ sender: Any) {
        destinationLabel.text = "fighters_test"
        databaseDirection = "fighters_test"
    }
    @IBAction func multTestDestinationPressed(_ sender: Any) {
        destinationLabel.text = "mult_test"
        databaseDirection = "mult_test"
    }
    @IBAction func trueFalseDestinationPressed(_ sender: Any) {
        destinationLabel.text = "tf_test"
        databaseDirection = "tf_test"
    }
    
    func setupGradient() {
        gradient = CAGradientLayer()
        gradient.colors = [UIColor.red.cgColor, UIColor.white.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        gradient.zPosition = -10
        self.view.layer.addSublayer(gradient)
    }
    
}
