//
//  SelectTypeOfFighterViewController.swift
//  OneMoreInstagramKFR
//
//  Created by Artem on 5/18/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import UIKit

class SelectTypeOfFighterViewController: UIViewController {
    
    fileprivate var questionType: FighterType = FighterType.MMA
    fileprivate var isSupergame: Bool = false
    fileprivate let gradient = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.instance().setupGradient(gradient: self.gradient, viewForGradient: self.view, color: UIColor.black)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // bez etogo budet bag pri kotorom posle superigri drugie rezhimi zapuskayutsya kak superigra
        self.isSupergame = false
    }
    
    @IBAction func MMAButtonPressed(_ sender: Any) {
        questionType = FighterType.MMA
        self.performSegue(withIdentifier: "showFighters", sender: self)
    }
    
    @IBAction func BoxingButtonPressed(_ sender: Any) {
        questionType = FighterType.Boxing
        self.performSegue(withIdentifier: "showFighters", sender: self)
    }
    
    @IBAction func K1ButtonPressed(_ sender: Any) {
        questionType = FighterType.K1
        self.performSegue(withIdentifier: "showFighters", sender: self)
    }
    
    @IBAction func supergameButtonPressed(_ sender: Any) {
        isSupergame = true
        self.performSegue(withIdentifier: "showFighters", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFighters", let fightersController = segue.destination as? FightersViewController {
            fightersController.fightersType = questionType
            fightersController.isSupergame = isSupergame
        }
    }
    
    
    
    
}
