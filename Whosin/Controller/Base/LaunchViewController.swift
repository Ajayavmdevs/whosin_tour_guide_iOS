//
//  LaunchViewController.swift
//  Whosin
//
//  Created by Ronak Trambadiya on 27/10/23.
//

import UIKit

class LaunchViewController: UIViewController {
    
    @IBOutlet private weak var _imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let localURL = Bundle.main.url(forResource: "logo-animation", withExtension: "gif") {
            _imageView.sd_setImage(with: localURL, completed: nil)
        }

    }

}
