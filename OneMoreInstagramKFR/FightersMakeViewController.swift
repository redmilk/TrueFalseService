//
//  FightersMakeViewController.swift
//  OneMoreInstagramKFR
//
//  Created by Artem on 5/17/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import UIKit

class FightersMakeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var questionLevelSegmented: UISegmentedControl!
    @IBOutlet weak var fighterTypeSegmented: UISegmentedControl!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var middleNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var pictureLinkTextField: UITextField!
    @IBOutlet weak var fighterImage: UIImageView!
    
    fileprivate let gradient: CAGradientLayer = CAGradientLayer()
    fileprivate let databaseDirection = "fighters_test"
    fileprivate var databaseSubDirection: String!
    fileprivate var questionLevel = QuestionLevel.Easy
    fileprivate var fighterType = FighterType.MMA
    fileprivate let imagePicker = UIImagePickerController()
    fileprivate var photolibraryImageTaken: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.instance().setupGradient(gradient: gradient, viewForGradient: self.view, color: UIColor.cyan)
        imagePicker.delegate = self
        //let tapGestureRecognizer = UIGestureRecognizer(target: self, action: #selector(imageOneTapped(img:)))
        fighterImage.isUserInteractionEnabled = true
        self.fighterImage.layer.borderWidth = 0.5
        self.fighterImage.layer.borderColor = UIColor.black.cgColor
    }
    
    /*****************************************/
    @IBAction func donePressed(_ sender: Any) {
        AppDelegate.instance().showActivityIndicator()
        
        if let pictureLinkText = pictureLinkTextField.text {
            if pictureLinkText.contains("https://") {
                self.saveWithTheLink()
            }
        }
        if photolibraryImageTaken {
            self.saveWithImageUploading()
        }
    }
    /*****************************************/

    fileprivate func saveWithTheLink() {
        
        // like fighters_test --> MMA --> Conor, or fighters_test --> Boxing --> Mayweather
        databaseSubDirection = self.fighterType.rawValue
        //unused (get key of future database field)
        //let key = ref.child(databaseDirection).child(databaseSubDirection).childByAutoId().key
        guard firstNameTextField.text != nil else {
            print("doneButtonPressed: firstNameTextField == nil")
            //AppDelegate.instance().dismissActivityIndicator()
            return
        }
        
        guard (pictureLinkTextField.text?.contains("https://"))! else {
            print("doneButtonPressed: pictureLinkTextField doesn't contain https://")
            let alertController = UIAlertController(title: "ERROR", message: "link doesn't contain https://", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okButton)
            self.present(alertController, animated: true, completion: nil)
            //AppDelegate.instance().dismissActivityIndicator()
            return
        }
        
        
        let midName = self.middleNameTextField.text ?? "nil"
        let lastName = self.lastNameTextField.text ?? "nil"
        
        let fighterInfo = ["questionLevel" : self.questionLevel.rawValue,
                           "fighterType" : self.fighterType.rawValue,
                           "firstName" : self.firstNameTextField.text!,
                           "middleName" : midName,
                           "lastName" : lastName,
                           "pathToImage" : pictureLinkTextField.text!] as [String : Any]
        
        
        
        //vmesto klyucha budet imya + pristavka + familiya
        let _midName = midName == "nil" ? "" : " " + midName
        let _lastName = lastName == "nil" ? "" : " " + lastName
        let databaseFieldHeader = self.firstNameTextField.text! + _midName + _lastName
        
        let fighterQuestionComplete = [databaseFieldHeader : fighterInfo]
        
        ref.child(databaseDirection).child(databaseSubDirection).updateChildValues(fighterQuestionComplete)
        AppDelegate.instance().dismissActivityIndicator()
    }
    
    fileprivate func saveWithImageUploading() {
        databaseSubDirection = self.fighterType.rawValue
        guard firstNameTextField.text != nil else {
            print("doneButtonPressed: firstNameTextField == nil")
            return
        }
        
        let midName = self.middleNameTextField.text ?? "nil"
        let lastName = self.lastNameTextField.text ?? "nil"

        //vmesto klyucha budet imya + pristavka + familiya
        let _midName = midName == "nil" ? "" : " " + midName
        let _lastName = lastName == "nil" ? "" : " " + lastName
        let databaseFieldHeader = self.firstNameTextField.text! + _midName + _lastName
        
        let imageRef = storage.child(databaseDirection).child(databaseSubDirection).child("\(databaseFieldHeader).jpg")
        let data = UIImageJPEGRepresentation(self.fighterImage.image!, 0.1)
        
        //in image future adress we put our data
        let uploadTask = imageRef.put(data!, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            //if no error, we can take futher this img url
            imageRef.downloadURL(completion: { (url, err) in
                if err != nil {
                    print(err!.localizedDescription)
                    return
                }
                //if url exists
                if let url = url {
                    self.pictureLinkTextField.text = url.absoluteString
                    let fighterInfo = ["questionLevel" : self.questionLevel.rawValue,
                                       "fighterType" : self.fighterType.rawValue,
                                       "firstName" : self.firstNameTextField.text!,
                                       "middleName" : midName,
                                       "lastName" : lastName,
                                       "pathToImage" : url.absoluteString] as [String : Any]
                    
                    //post feed for database
                    let fighterQuestionComplete = [databaseFieldHeader : fighterInfo]
                    //insert in posts -> post feed
                    ref.child(self.databaseDirection).child(self.databaseSubDirection).updateChildValues(fighterQuestionComplete)
                    AppDelegate.instance().dismissActivityIndicator()
                }
            })
        })
        uploadTask.resume()
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            fighterImage.image = image
            self.photolibraryImageTaken = true
        } else{
            print("Something went wrong")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func questionLevelSegmentChanged(_ sender: UISegmentedControl) {
        switch questionLevelSegmented.selectedSegmentIndex
        {
        case 0:
            questionLevel = QuestionLevel.Easy
        case 1:
            questionLevel = QuestionLevel.Normal
        case 2:
            questionLevel = QuestionLevel.Hard
        default:
            break
        }
    }
    @IBAction func fighterTypeSegmentedChanged(_ sender: UISegmentedControl) {
        switch fighterTypeSegmented.selectedSegmentIndex
        {
        case 0:
            fighterType = FighterType.MMA
        case 1:
            fighterType = FighterType.Boxing
        case 2:
            fighterType = FighterType.K1
        default:
            break
        }
    }
    
    @IBAction func pickImageButton(_ sender: UIButton) {
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
        
    }
}
