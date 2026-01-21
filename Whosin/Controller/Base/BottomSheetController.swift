import UIKit

class BottomSheetViewController: UIViewController {

    private var contentView: UIView!
    private var handleView: UIView!

    private var contentViewHeightConstraint: NSLayoutConstraint!
    private var contentViewBottomConstraint: NSLayoutConstraint!

    private let contentHeight: CGFloat = 500
    private let handleHeight: CGFloat = 20

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .white
        view.addSubview(contentView)

        handleView = UIView()
        handleView.translatesAutoresizingMaskIntoConstraints = false
        handleView.backgroundColor = .gray
        contentView.addSubview(handleView)

        contentViewHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: contentHeight)
        contentViewBottomConstraint = contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: contentHeight + handleHeight)

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentViewBottomConstraint,
            contentViewHeightConstraint,

            handleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            handleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            handleView.widthAnchor.constraint(equalToConstant: 50),
            handleView.heightAnchor.constraint(equalToConstant: handleHeight)
        ])

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        contentView.addGestureRecognizer(panGesture)
    }

    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)

        switch sender.state {
        case .began, .changed:
            let newConstant = contentViewBottomConstraint.constant - translation.y
            if newConstant >= -(contentHeight + handleHeight) && newConstant <= 0 {
                contentViewBottomConstraint.constant = newConstant
                sender.setTranslation(.zero, in: view)
            }
        case .ended:
            let midPoint = -contentHeight/2 - handleHeight
            if contentViewBottomConstraint.constant < midPoint {
                hideBottomSheet()
            } else {
                showBottomSheet()
            }
        default:
            break
        }
    }

    func showBottomSheet() {
        contentViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    func hideBottomSheet() {
        contentViewBottomConstraint.constant = -(contentHeight + handleHeight)
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.dismiss(animated: false, completion: nil)
        })
    }
}
