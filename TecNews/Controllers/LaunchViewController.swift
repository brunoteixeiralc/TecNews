//
//  LauchViewController.swift
//  TecNews
//
//  Created by Bruno Corrêa on 15/02/2018.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import UIKit
import Lottie

class LaunchViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let animationView = LOTAnimationView(name: "launchScreen")
        animationView.contentMode = .scaleAspectFill
        animationView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 250)
        animationView.center =  self.view.center
        self.view.addSubview(animationView)
        animationView.play(fromProgress: 0, toProgress: 0.68) { (finished) in
            let dispatchTime = DispatchTime.now() + 1.0
             DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                    self.performSegue(withIdentifier: "toSourceVC", sender: nil)
            }
        }
    }
}
