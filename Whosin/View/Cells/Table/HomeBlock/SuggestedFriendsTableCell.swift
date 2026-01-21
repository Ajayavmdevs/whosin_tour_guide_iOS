import UIKit

class SuggestedFriendsTableCell: UITableViewCell {

    public var removeVenueCallBack: ((_ id: String) -> Void)?
    public var removeUserCallBack: ((_ id: String) -> Void)?

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ users: [UserDetailModel] = [], venues: [VenueDetailModel] = [],title: String, isBlock: Bool = true, isVenue: Bool = false) {
        self.contentView.subviews.forEach { $0.removeFromSuperview() }
        let view = SuggestedView.initFromNib()
        view.setupData(users, venues: venues, title: title,isBlock: isBlock, isVenue: isVenue)
        view.removeUserCallBack = { id in
            self.removeUserCallBack?(id)
        }
        view.removeVenueCallBack = { id in
            self.removeVenueCallBack?(id)
        }
        self.contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }

}
