import UIKit
import StripePaymentSheet
import CollectionViewPagingLayout

class CategoryHeaderTableCell: UITableViewCell {

    @IBOutlet weak var _collectionView: UICollectionView!
    private var _bannerList: [BannerModel] = []

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { 300 }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func setupUi() {
        disableSelectEffect()
        let layout = CollectionViewPagingLayout()
        layout.numberOfVisibleItems = 4
        layout.scrollDirection = .horizontal
        _collectionView.delegate = self
        _collectionView.dataSource = self
        _collectionView.collectionViewLayout = layout
        _collectionView.isPagingEnabled = true
        _collectionView.register(UINib(nibName: "BannerImageCollectionCell", bundle: nil), forCellWithReuseIdentifier: "BannerImageCollectionCell")
        _collectionView.reloadData()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: [BannerModel]) {
        _bannerList = data
        setupUi()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _openURL(urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func _openActivity(id: String, name: String) {
        let vc = INIT_CONTROLLER_XIB(ActivityInfoVC.self)
        vc.activityId = id
        vc.activityName = name
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }

    // --------------------------------------
    // MARK: Event
    // --------------------------------------

}

extension CategoryHeaderTableCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _bannerList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerImageCollectionCell", for: indexPath) as! BannerImageCollectionCell
        if _bannerList.count > indexPath.row {
            cell.setupData(_bannerList[indexPath.row].image)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if _bannerList[indexPath.row].type == "link" {
            _openURL(urlString: _bannerList[indexPath.row].link)
        } else if _bannerList[indexPath.row].type == "activity" {
            _openActivity(id: _bannerList[indexPath.row].activityId, name: "")
        } else if _bannerList[indexPath.row].type == "venue" {
            let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
            vc.venueId = _bannerList[indexPath.row].venueId
            parentViewController?.navigationController?.pushViewController(vc, animated: true)
        } else if _bannerList[indexPath.row].type == "offer" {
            let vc = INIT_CONTROLLER_XIB(OfferPackageDetailVC.self)
            vc.offerId = _bannerList[indexPath.row].offerId
            vc.modalPresentationStyle = .overFullScreen
            vc.vanueOpenCallBack = { venueId, venueModel in
                let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
                vc.venueId = venueId
                vc.venueDetailModel = venueModel
                self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
            }
            vc.buyNowOpenCallBack = { offer, venue, timing in
                let vc = INIT_CONTROLLER_XIB(BuyPackgeVC.self)
                vc.isFromActivity = false
                vc.type = "offers"
                vc.timingModel = timing
                vc.offerModel = offer
                vc.venue = venue
                vc.setCallback {
                    let controller = INIT_CONTROLLER_XIB(MyCartVC.self)
                    controller.modalPresentationStyle = .overFullScreen
                    self.parentViewController?.navigationController?.pushViewController(controller, animated: true)
                }
                self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
            }
            self.parentViewController?.presentAsPanModal(controller: vc)
        } else if _bannerList[indexPath.row].type == "ticket" {
            let vc = INIT_CONTROLLER_XIB(CustomTicketDetailVC.self)
            vc.ticketID = _bannerList[indexPath.row].ticketId
            vc.hidesBottomBarWhenPushed = true
            self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

