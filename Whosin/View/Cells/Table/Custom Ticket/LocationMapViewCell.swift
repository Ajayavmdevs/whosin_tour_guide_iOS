import UIKit

class LocationMapViewCell: UITableViewCell {

    @IBOutlet weak var _mapImage: UIImageView!
    @IBOutlet weak var _addressText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
    }
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------


    public func setupData(lat: Double, long: Double, address: String) {
        _addressText.text = address
        _mapImage.loadWebImage(Utils.getStaticMapURL(latitude: lat, longitude: long))
    }
    
}
