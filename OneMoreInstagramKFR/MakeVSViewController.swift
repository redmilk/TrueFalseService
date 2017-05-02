//
//  MakeVSViewController.swift
//  chatdpua
//
//  Created by Artem on 1/27/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

class MakeVSViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var headerTextField: UITextField!
    @IBOutlet weak var labelOne: UILabel!
    @IBOutlet weak var imageViewOne: UIImageView!
    @IBOutlet weak var textFieldOne: UITextField!
    @IBOutlet weak var buttonDone: UIButton!
    
    var imagePickerOne = UIImagePickerController()
    
    var gradient: CAGradientLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePickerOne.delegate = self
        
        let tapGestureRecognizerOne = UITapGestureRecognizer(target:self, action:#selector(imageOneTapped(img:)))

        imageViewOne.isUserInteractionEnabled = true
        imageViewOne.addGestureRecognizer(tapGestureRecognizerOne)
        
        gradient = CAGradientLayer()
        gradient.colors = [UIColor.blue.cgColor, UIColor.white.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        gradient.zPosition = -10
        self.view.layer.addSublayer(gradient)
        
    }
    
    func imageOneTapped(img: AnyObject) {
        print("image One tapped")
        imagePickerOne.sourceType = .photoLibrary
        self.present(imagePickerOne, animated: true, completion:  nil)
    }
    

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageViewOne.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        AppDelegate.instance().showActivityIndicator()
        // MARK: - done button (saving)
        //budushiy klyuch posta v baze
        let key = ref.child("questions").childByAutoId().key
        // v hranilishe pod Posts --> currentuser id --> klyuch nogo posta.jpg, eto budushyaya ssilka na kartinku
        let imageRef = storage.child("questions").child("\(key).jpg")
        //konvert image to data
        let data = UIImageJPEGRepresentation(self.imageViewOne.image!, 0.5)
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
                    let questionInfo = ["questionHeader" : self.headerTextField.text!,
                                      "questionAnswer" : self.textFieldOne.text!,
                                      "pathToImage" : url.absoluteString,
                                      "questionKey" : key] as [String : Any]
                    //post feed for database
                    let questionComplete = ["\(key)" : questionInfo]
                    //insert in posts -> post feed
                    ref.child("questions").updateChildValues(questionComplete)
                    AppDelegate.instance().dismissActivityIndicator()
                }
            })
        })
        uploadTask.resume()
    }
}
