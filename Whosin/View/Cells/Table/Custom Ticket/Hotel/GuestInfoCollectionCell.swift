import UIKit

class GuestInfoCollectionCell: UICollectionViewCell {

    @IBOutlet weak var _name: CustomLabel!
    @IBOutlet weak var _email: CustomLabel!
    @IBOutlet weak var _mobile: CustomLabel!
    @IBOutlet weak var _age: CustomLabel!
    @IBOutlet weak var sapratorView: UIView!
    @IBOutlet weak var _nationality: CustomLabel!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 120 }

    // --------------------------------------
    // MARK: LifeCycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func setupData(_ model: JPPassengerModel, lastRow: Bool = false) {
        sapratorView.isHidden = lastRow
        _name.text = "\(model.prefix) \(model.firstName) \(model.lastName)"
        _email.text = model.email
        _mobile.text = model.mobile
        _nationality.text = model.nationality
        _age.text = model.age
    }
    

}
