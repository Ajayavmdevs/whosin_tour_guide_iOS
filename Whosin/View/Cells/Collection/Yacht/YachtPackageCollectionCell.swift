import UIKit

class YachtPackageCollectionCell: UICollectionViewCell {

    @IBOutlet weak var _bgView: UIView!
    @IBOutlet weak var _tagView: UIView!
    @IBOutlet weak var _tagPrice: UILabel!
    @IBOutlet weak var _titileText: UILabel!
    @IBOutlet weak var _subTitle: UILabel!
    @IBOutlet weak var _conditionText: UILabel!
    private var packageModel: YachtPackgeModel?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

//    class var hourlyHeight: CGFloat { 103 }
    class var height: CGFloat { 72 }


    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        DISPATCH_ASYNC_MAIN_AFTER(0.01) {
            self._tagView.roundCorners(corners: [.bottomLeft, .topRight], radius: 10)
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupPackage(model: YachtPackgeModel, isHourly: Bool) {
        packageModel = model
        if isHourly {
            _titileText.text = model.title
            _subTitle.text = model.descriptions
            _tagPrice.text = "D\(model.pricePerHour)/hr"
            _conditionText.text = "💡 Min. \(model.minimumHour)hr - Max. \(model.maximumHour)hrs (check availability)"
            _conditionText.isHidden = false
            _tagView.isHidden = false
        } else {
            _titileText.text = model.title
            _subTitle.text = model.descriptions
            _tagPrice.text = "D\(model.amount)"
            _conditionText.isHidden = true
            _tagView.isHidden = false
        }
    }
    
    public func setupAddOns(model: AddOnsModel) {
        _titileText.text = model.title
        _subTitle.text = model.descriptions
        _tagPrice.text = "D\(model.price)"
        _conditionText.isHidden = true
        _tagView.isHidden = false
    }
    
    public func select(_ isAddOn: Bool) {
        if isAddOn {
            _bgView.backgroundColor = ColorBrand.brandSky
            _tagView.backgroundColor = ColorBrand.white
            _tagPrice.textColor = ColorBrand.brandSky
        } else {
            _bgView.backgroundColor = ColorBrand.brandPink
            _tagView.backgroundColor = ColorBrand.white
            _tagPrice.textColor = ColorBrand.brandPink
            _conditionText.textColor = ColorBrand.white
        }
    }
    
    public func unselect(_ isAddOn: Bool) {
       if isAddOn {
            _bgView.borderColor = ColorBrand.brandSky
            _bgView.borderWidth = 1
            _tagView.backgroundColor = ColorBrand.brandSky
           _tagPrice.textColor = ColorBrand.white
           _bgView.backgroundColor = ColorBrand.clear
        } else {
            _tagView.backgroundColor = ColorBrand.brandPink
            _tagPrice.textColor = ColorBrand.white
            _bgView.backgroundColor = UIColor(hexString: "#4D4D4D")
            _conditionText.textColor = ColorBrand.brandPink
        }
    }
        
    // --------------------------------------
    // MARK: Private
    // --------------------------------------


    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

}
