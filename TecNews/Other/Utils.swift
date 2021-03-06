//
//  Utils.swift
//  TecNews
//
//  Created by Bruno Corrêa on 19/02/2018.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import Foundation
import UIKit

func showDialog(in view:UIViewController){
    let alert = UIAlertController(title: nil, message: NSLocalizedString("loading", comment: "Localized kind: Loading"), preferredStyle: .alert)
        
    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
    loadingIndicator.hidesWhenStopped = true
    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
    loadingIndicator.startAnimating();
        
    alert.view.addSubview(loadingIndicator)
    view.present(alert, animated: true, completion: nil)
}
    
func dismissDialog(in view:UIViewController){
     view.dismiss(animated: false, completion: nil)
}

func URLValid(urlString:String?) -> Bool{
    if let urlString = urlString{
        if let url = URL(string: urlString) {
            return UIApplication.shared.canOpenURL(url as URL)
        }
    }
    return false
}

