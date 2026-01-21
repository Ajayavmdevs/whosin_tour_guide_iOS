import UIKit

class YachButtonTableCell: UITableViewCell {

    @IBOutlet weak var _agentBtn: CustomActivityButton!
    @IBOutlet weak var _addToCartBtn: CustomActivityButton!
    @IBOutlet weak var _checkOutBtn: CustomActivityButton!
    @IBOutlet weak var _buyNowBtn: CustomActivityButton!
    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        _agentBtn.titleLabel?.font = FontBrand.SFboldFont(size: 15)
        _addToCartBtn.titleLabel?.font = FontBrand.SFboldFont(size: 15)
        _checkOutBtn.titleLabel?.font = FontBrand.SFboldFont(size: 15)
        _buyNowBtn.titleLabel?.font = FontBrand.SFboldFont(size: 15)

    }
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { UITableView.automaticDimension }

    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ model: YachtOfferDetailModel) {
        
    }
    
    @IBAction func _handleContactAgentEvent(_ sender: CustomActivityButton) {
        
    }
    
    @IBAction func _buyNowEvent(_ sender: CustomActivityButton) {
        let package = YachPackagesCell.selectedPackage
        let addOns = YachPackagesCell.selectedAddOns
        let duartion = YachHourlyPackageCell.selectedDuration
        let hourlypackage = YachHourlyPackageCell.selectedPackage

    }
}
