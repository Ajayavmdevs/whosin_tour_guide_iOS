//
//  RedeemSuccessAlertVC.swift
//  Whosin
//
//  Created by Creative Infoway on 01/02/24.
//

import UIKit

class RedeemSuccessAlertVC: ChildViewController {

    @IBOutlet private var descLbl: UILabel!
    public var descStr: NSMutableAttributedString?
    override func viewDidLoad() {
        super.viewDidLoad()
        descLbl.attributedText = descStr
        // Do any additional setup after loading the view.
    }

    @IBAction private func okButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}
