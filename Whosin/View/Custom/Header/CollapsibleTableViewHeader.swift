import UIKit

public protocol CollapsibleTableViewHeaderDelegate: AnyObject {
    func toggleSection(_ header: CollapsibleTableViewHeader, section: Int)
    func actionBtnCallBack(_ header: CollapsibleTableViewHeader, section: Int)
}

public class CollapsibleTableViewHeader: UITableViewHeaderFooterView {
    public let headerTitleLbl = UILabel()
    public let rightTitleLbl = UILabel()
    public let arrowImgView = UIImageView()
    public let barView = UIView()
    public let rightBtn = UIButton()
	weak public var delegate: CollapsibleTableViewHeaderDelegate?
    public var section: Int = 0

	private var _backgroundColor: UIColor?

	// --------------------------------------
	// MARK: Life Cycle
	// --------------------------------------

	init(reuseIdentifier: String?, collapsible: Bool, collapsed _: Bool, backgroundColor: UIColor = ColorBrand.brandGray, rightTitleColor: UIColor = UIColor.white, rightButtonColor: UIColor = UIColor.white, showRightButton: Bool = false) {
		super.init(reuseIdentifier: reuseIdentifier)
		let marginGuide = contentView.layoutMarginsGuide

		_backgroundColor = backgroundColor
		contentView.backgroundColor = _backgroundColor

		if collapsible {
			contentView.addSubview(arrowImgView)
			arrowImgView.image = UIImage(named: "icon_arrow_up")
			arrowImgView.tintColor = ColorBrand.white
			arrowImgView.translatesAutoresizingMaskIntoConstraints = false
			arrowImgView.widthAnchor.constraint(equalToConstant: 25).isActive = true
			arrowImgView.heightAnchor.constraint(equalToConstant: 25).isActive = true
			arrowImgView.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor).isActive = true
			arrowImgView.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
			addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CollapsibleTableViewHeader._tapHeader(_:))))
			// self.setCollapsed(collapsed, duration: 0)
		}

		contentView.addSubview(headerTitleLbl)
		headerTitleLbl.textColor = ColorBrand.white
        headerTitleLbl.font = FontBrand.tableHeaderFont
		headerTitleLbl.backgroundColor = ColorBrand.clear
		headerTitleLbl.translatesAutoresizingMaskIntoConstraints = false
		headerTitleLbl.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
		headerTitleLbl.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
		headerTitleLbl.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true

		contentView.addSubview(barView)
		barView.backgroundColor = ColorBrand.clear
		barView.frame = CGRect(x: UIScreen.main.bounds.width / 2 - 3, y: 0, width: 6, height: 36)
		contentView.addSubview(rightTitleLbl)
		rightTitleLbl.frame = CGRect(x: UIScreen.main.bounds.width / 2 + 20, y: 0, width: 150, height: 40)
		rightTitleLbl.textColor = rightTitleColor
		rightTitleLbl.font = FontBrand.labelFont
		rightTitleLbl.backgroundColor = ColorBrand.brandGray
		if showRightButton {
			contentView.addSubview(rightBtn)
			rightBtn.translatesAutoresizingMaskIntoConstraints = false
			rightBtn.widthAnchor.constraint(equalToConstant: 80).isActive = true
            rightBtn.heightAnchor.constraint(equalToConstant: 28).isActive = true
			rightBtn.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor).isActive = true
			if collapsible {
				rightBtn.trailingAnchor.constraint(equalTo: arrowImgView.leadingAnchor, constant: -8).isActive = true
			}
            rightBtn.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
			rightBtn.backgroundColor = rightButtonColor
			rightBtn.setTitleColor(.white, for: .normal)
            rightBtn.titleLabel?.font = FontBrand.buttonTitleFont
			rightBtn.addTarget(self, action: #selector(_tapAction(_:)), for: .touchUpInside)
			rightBtn.isHidden = !showRightButton
            self.rightBtn.layer.cornerRadius = 14
            
		} else {
			headerTitleLbl.trailingAnchor.constraint(equalTo: collapsible ? arrowImgView.trailingAnchor : marginGuide.trailingAnchor ).isActive = true
		}
	}

	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// --------------------------------------
	// MARK: Events
	// --------------------------------------

	@objc private func _tapHeader(_ gestureRecognizer: UITapGestureRecognizer) {
		guard let cell = gestureRecognizer.view as? CollapsibleTableViewHeader else {
			return
		}
		delegate?.toggleSection(self, section: cell.section)
	}

	@objc private func _tapAction(_ sender: UIButton) {
		delegate?.actionBtnCallBack(self, section: section)
	}

	// --------------------------------------
	// MARK: Public
	// --------------------------------------

    public func setCollapsed(_ collapsed: Bool, duration: CFTimeInterval = 0.2) {
		arrowImgView.rotate(collapsed ? .pi : 0.0, duration: duration)
	}

	override public func layoutSubviews() {
		super.layoutSubviews()
		barView.borders(for: [.left, .right], width: 0.5, color: ColorBrand.black.withAlphaComponent(0.3))
	}
}
