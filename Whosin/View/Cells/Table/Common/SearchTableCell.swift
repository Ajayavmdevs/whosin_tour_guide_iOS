import UIKit
import SwiftUI

class SearchTableCell: UITableViewCell {
    
    @IBOutlet private weak var _imgLocation: UIImageView!
    @IBOutlet private weak var _lblLocationName: UILabel!
    @IBOutlet private weak var _lblOfferTitle: UILabel!
    @IBOutlet private weak var _lblAddress: UILabel!
    @IBOutlet private weak var _btnFollow: UIButton!
    @IBOutlet private weak var _distanceLabel: UILabel!
    
    private var _tag: String = kEmptyString
    private var _businessDetail: StoryModel?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _setupUi()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        disableSelectEffect()
        _imgLocation.roundCorners(corners: [.topLeft], radius: 12.0)
    }
    
    private func requestFollow() {
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @objc private func _handleFollowEvent(_ sender: UIButton) {
        requestFollow()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
}
