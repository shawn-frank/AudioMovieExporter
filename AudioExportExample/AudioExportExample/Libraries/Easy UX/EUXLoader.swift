//
//  EUXLoader.swift
//  BYConnect
//
//  Created by Shawn Frank on 21/02/2021.
//

import UIKit

/// A lightweight class used to spin up a loader with a message in a few lines of code.
/// Ideally would be a UIAlertController subclass but this is not recommended by Apple
/// * **REF:** [Ajinkya's Stack Overflow Answer](https://stackoverflow.com/questions/27960556/loading-an-overlay-when-running-long-tasks-in-ios) to learn more
class EUXLoader {
  
  private(set) var loaderController = UIAlertController()
  
  /// Initializes EUXLoader with a UIAlertController and a UIActivityIndicatorView
  /// - Parameter title: The title displayed next to the UIActivityIndicatorView
  init(withTitle title: String) {
    loaderController = UIAlertController(title: nil, message: title, preferredStyle: .alert)
    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
    loadingIndicator.hidesWhenStopped = true
    loadingIndicator.style = UIActivityIndicatorView.Style.medium
    loadingIndicator.startAnimating();
    loaderController.view.addSubview(loadingIndicator)
  }
  
  
}
