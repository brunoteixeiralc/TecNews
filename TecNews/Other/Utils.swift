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
    
    func getSearchTerms(text: String, language: String? = nil,block: (String) -> Void) {
        let tagger = NSLinguisticTagger(tagSchemes: [.lemma],options: 0)
        tagger.string = text
        let options: NSLinguisticTagger.Options = [.omitWhitespace,
                                                   .omitPunctuation,
                                                   .joinNames,
                                                   .omitOther]
        
        let range = NSRange(text.startIndex..., in: text)
        
        if let language = language {tagger.setOrthography(NSOrthography.defaultOrthography(forLanguage: language), range: range)
        }

        tagger.enumerateTags(in: range, unit: .word,scheme: .lemma, options: options)
        { tag, _, _ in
            guard let tag = tag else { return }
            block(tag.rawValue.lowercased())
        }
    }

