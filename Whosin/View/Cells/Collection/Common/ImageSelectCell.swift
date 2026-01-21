//
//  ImageSelectCell.swift
//  Whosin
//
//  Created by Samir Makadia on 17/10/24.
//

import UIKit

class ImageSelectCell: UICollectionViewCell {
    
    @IBOutlet weak var _image: UIImageView!
    @IBOutlet weak var _playIcon: UIImageView!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }


    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func setupData(_ image: String) {
        _image.loadWebImage(image)
    }
    

}
