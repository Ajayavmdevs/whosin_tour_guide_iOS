import UIKit

@objc
public
protocol SearchInputTableViewHeaderDelegate: AnyObject {
	@objc optional func handleSearchEditBeginEvent(_ header: SearchInputTableViewHeader, section: Int, searchContent: String)
	@objc optional func handleSearchEditEndEvent(_ header: SearchInputTableViewHeader, section: Int, searchContent: String)
	@objc optional func handleSearchBtnEvent(_ header: SearchInputTableViewHeader, section: Int, searchContent: String)
}

public class SearchInputTableViewHeader: UITableViewHeaderFooterView {
	weak public var delegate: SearchInputTableViewHeaderDelegate?
    public var section: Int = 0
    public let searchBtn = UIButton()
    public let titleLbl = UILabel()
	private let searchBar = UISearchBar()
	private var _backgroundColor: UIColor?

	// --------------------------------------
	// MARK: Life Cycle
	// --------------------------------------

    init(reuseIdentifier: String?, placeholder: String = "search".localized(), backgroundColor: UIColor = ColorBrand.brandGray) {
		super.init(reuseIdentifier: reuseIdentifier)
		let marginGuide = contentView.layoutMarginsGuide

		_backgroundColor = backgroundColor
		contentView.backgroundColor = _backgroundColor

		contentView.addSubview(titleLbl)
		titleLbl.textColor = ColorBrand.white
		titleLbl.font = FontBrand.labelFont
		titleLbl.backgroundColor = ColorBrand.brandGray
		titleLbl.translatesAutoresizingMaskIntoConstraints = false
		titleLbl.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
		titleLbl.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
		titleLbl.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true

		contentView.addSubview(searchBtn)
		searchBtn.titleLabel?.textColor = ColorBrand.white
		searchBtn.titleLabel?.font = FontBrand.labelFont
		searchBtn.translatesAutoresizingMaskIntoConstraints = false
		searchBtn.widthAnchor.constraint(equalToConstant: 72).isActive = true
		searchBtn.heightAnchor.constraint(equalToConstant: 38).isActive = true
		searchBtn.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
		searchBtn.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
		searchBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SearchInputTableViewHeader._tapButton(_:))))

		contentView.addSubview(searchBar)
		searchBar.placeholder = placeholder
		searchBar.sizeToFit()
		searchBar.layer.cornerRadius = 10
		searchBar.clipsToBounds = true
		searchBar.backgroundColor = ColorBrand.white
		searchBar.translatesAutoresizingMaskIntoConstraints = false
		searchBar.heightAnchor.constraint(equalToConstant: 38).isActive = true
		searchBar.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
		searchBar.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
		searchBar.trailingAnchor.constraint(equalTo: searchBtn.leadingAnchor, constant: -24).isActive = true
	}

	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// --------------------------------------
	// MARK: Events
	// --------------------------------------

	@objc private func _tapButton(_: UITapGestureRecognizer) {
		delegate?.handleSearchBtnEvent?(self, section: section, searchContent: searchBar.text ?? kEmptyString)
	}
}
