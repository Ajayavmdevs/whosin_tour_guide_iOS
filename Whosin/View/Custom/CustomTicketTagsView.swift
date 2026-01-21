import UIKit
import Lightbox
import SnapKit

class CustomTicketTagsView: UIView {
    
    @IBOutlet weak var _collecitonView: UICollectionView!
    private let kCellIdentifier = String(describing: DaysCollectionCell.self)
    private var tags: [String] = []
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUi()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _setupUi()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _setup()
    }
    
    private func _setup() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        _collecitonView.decelerationRate = .fast
        _collecitonView.showsHorizontalScrollIndicator = false
        _collecitonView.showsVerticalScrollIndicator = false
        _collecitonView.register(UINib(nibName: "DaysCollectionCell", bundle: nil), forCellWithReuseIdentifier: "DaysCollectionCell")
        _collecitonView.delegate = self
        _collecitonView.dataSource = self
        _collecitonView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        _collecitonView.reloadData()
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: String(describing: DaysCollectionCell.self), kCellNibNameKey: String(describing: DaysCollectionCell.self), kCellClassKey: DaysCollectionCell.self, kCellHeightKey: DaysCollectionCell.height]]
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        if var view = Bundle.main.loadNibNamed("CustomTicketTagsView", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }
    }
    
    public func setupData(_ model: [String]) {
        tags = model
        _collecitonView.reloadData()
        _setup()
    }
    
    
}

extension CustomTicketTagsView: UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DaysCollectionCell", for: indexPath) as! DaysCollectionCell
        let object = tags[indexPath.row]
        cell.setupTags(object)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let currentDay = tags[indexPath.row]
        let currentDayWidth = currentDay.widthOfString(usingFont: FontBrand.SFsemiboldFont(size: 13))

        return CGSize(width: currentDayWidth + 20, height: 20)
    }

}
