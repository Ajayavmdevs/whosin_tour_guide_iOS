import UIKit

class BannerAdsTableCell: UITableViewCell {

    // Large
    private let promotionBannerView = CustomPromotionBanner()
    var refreshTimer: Timer?

    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    static let identifier = String(describing: BannerAdsTableCell.self)
    class func height(_ size: String) -> CGFloat {
        kScreenWidth / Utils.parseRatio(size)
    }
    
    
    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    private func setupUI() {
            contentView.addSubview(promotionBannerView)
            promotionBannerView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            selectionStyle = .none
        }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    func pause() {
        promotionBannerView.pauseVideos()
    }
    
    func resume() {
        promotionBannerView.resumeVideos()
    }
    

    func setupData(_ model: PromotionalBannerItemModel) {
        promotionBannerView.setup(model)
    }
    
}
