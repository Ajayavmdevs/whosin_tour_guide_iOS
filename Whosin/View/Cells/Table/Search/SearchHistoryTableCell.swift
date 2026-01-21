import UIKit

protocol SearchHistoryTableCellDelegate: AnyObject {
    func searchHistoryCellDidTapClose(_ cell: SearchHistoryTableCell)
}

class SearchHistoryTableCell: UITableViewCell {
    
    weak var delegate: SearchHistoryTableCellDelegate?
    @IBOutlet weak var _profileImageView: UIImageView!
    @IBOutlet private weak var _title: UILabel!
    @IBOutlet private weak var _subtitle: UILabel!
    @IBOutlet private weak var _type: UILabel!
    private var _historyModel: SearchHistoryModel?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        70
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        _profileImageView.image = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        _profileImageView.image = nil
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: SearchHistoryModel) {
        _historyModel = data
        _title.text = data.title
        _type.text = data.type.capitalized
        _profileImageView.cornerRadius = data.type == "user" ? 22 : 9
        _profileImageView.loadWebImage(data.image, name: data.title)
        print("image=========", data.image)
        print("title=========", data.title)
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        delegate?.searchHistoryCellDidTapClose(self)
    }
    
}
