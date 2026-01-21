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
        } else if _bannerList[indexPath.row].type == "ticket" {
            let vc = INIT_CONTROLLER_XIB(CustomTicketDetailVC.self)
            vc.ticketID = _bannerList[indexPath.row].ticketId
            vc.hidesBottomBarWhenPushed = true
            self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

