import UIKit

class CustomStatusView: UIView {
    
    private let statusIndicatorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        statusIndicatorView.backgroundColor = .clear
        addSubview(statusIndicatorView)
        NSLayoutConstraint.activate([
            statusIndicatorView.topAnchor.constraint(equalTo: topAnchor),
            statusIndicatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            statusIndicatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            statusIndicatorView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func setStatus(isLive: Bool) {
        statusIndicatorView.backgroundColor = isLive ? UIColor.green : UIColor.red
    }
}
